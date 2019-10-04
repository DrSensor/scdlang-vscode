let Prelude = https://prelude.dhall-lang.org/package.dhall sha256:771c7131fc87e13eb18f770a27c59f9418879f7e230ba2a50e46f4461f43ec69 ? https://prelude.dhall-lang.org/package.dhall
let Map = https://prelude.dhall-lang.org/Map/Type sha256:210c7a9eba71efbb0f7a66b3dcf8b9d3976ffc2bc0e907aadfb6aa29c333e8ed ? https://prelude.dhall-lang.org/Map/Type
let List/map = Prelude.List.map
let List/toMap = λ(a: Type) -> λ(list: List a) ->
  let List/Index = { index: Natural, value: a }
  let List/Map = { mapKey: Text, mapValue: a }
  let list2map = λ(indexed: List/Index) -> { mapKey = Natural/show indexed.index, mapValue = indexed.value }
  let indexedList = List/indexed a list
  in List/map List/Index List/Map list2map indexedList

let Textmate = ./Prelude.dhall
  let Target = Textmate.Target
  let Scope = Textmate.util.Scope
  let Scope/list2map = Textmate.util.Scope/list2map
  let Scope/from = Textmate.util.Scope/from
  let Scope/name = Textmate.util.Scope/name
  let Block = Textmate.pattern.Block
  let BlockMatch = Textmate.pattern.BlockMatch
  let Sublime = Textmate.pattern.Sublime

let scope = {
  line-comment = Scope/from ["comment.line.double-slash"],
  block-comment = Scope/from ["punctuation.definition.comment"]
}

let block-captures/on = λ(target: Target) -> λ(i: Natural) -> Scope/list2map i [ Scope/name target [scope.block-comment] ]

let line-comment = λ(target: Target) -> {
  match = "(^[ \t]+)?((//)(?:\\s*(?=\\s|$))?)",
  captures = Scope/list2map 1 [
    Scope/name target ["punctuation.whitespace.comment.leading"],
    Scope/name target ["comment.line.double-slash"],
    Scope/name target ["punctuation.definition.comment"]
  ]
}

--TODO: refactor (TextMate|Sublime)/*-comment to be generic and move it to Prelude.dhall
let Match = < Partial | Full >

let TextMate/line-comment = λ(terminate: Text) -> {
  name = None Text, contentName = Some scope.line-comment,
  begin = (line-comment Target.TextMate).match,
  beginCaptures = (line-comment Target.TextMate).captures,
  end = "(?=${terminate})",
  endCaptures = [] : Map Text Scope 
}

let Sublime/line-comment = λ(terminate: Text) -> line-comment Target.Sublime ∧ {
  push = [
    Sublime.Push.Meta (Sublime.Meta.Content {
      meta_content_scope = scope.line-comment
    }),
    Sublime.Push.Match {
      match = "(?=${terminate})", pop = True,
      captures = [] : Map Text Scope
    }
  ]
}

let TextMate/block-comment = λ(type: Match) ->
  let skip = merge { Partial = 1, Full = 0 } type
  in λ(beginMatch: Text) -> λ(rootScope: Text) -> λ(endMatch: Text) -> {
    name = Some rootScope, contentName = None Text,
    begin = beginMatch, end = endMatch,
    beginCaptures = block-captures/on Target.TextMate skip,
    endCaptures = block-captures/on Target.TextMate 0
  }

let Sublime/block-comment = λ(type: Match) ->
  let skip = merge { Partial = 1, Full = 0 } type
  in λ(beginMatch: Text) -> λ(rootScope: Text) -> λ(endMatch: Text) -> {
    match = beginMatch, captures = block-captures/on Target.Sublime skip,
    push = [
      Sublime.Push.Meta (Sublime.Meta.Root { meta_scope = rootScope }),
      Sublime.Push.Match {
        match = endMatch, pop = True,
        captures = block-captures/on Target.Sublime 0
      }
    ]
  }


let matches = {
  block-comment = λ(a: Type) -> λ(captures: Match -> Text -> Text -> Text -> a) -> [
    --TODO: hide the detail of the regex, only provide start (/\\*) and stop (\\*/) token 
    captures Match.Full "/\\*\\*(?!/)" "comment.block.documentation" "\\*/",
    captures Match.Partial "(/\\*)(?:\\s*(?=\\s|(\\*/)))?" "comment.block" "\\*/"
  ],
  line-comment = λ(a: Type) -> λ(captures: Text -> a) -> [ captures "$", captures "^" ]
}

-- see https://github.com/microsoft/TypeScript-TmLanguage/blob/9b9b1303670a79752508bb8526f22f8ed61c22a8/TypeScript.YAML-tmLanguage#L2685-L2724
-- TODO: use `let inlineComment = \/\*([^\*]|(\*[^\/]))*\*\/` in all expressions
in λ(target: Target) -> {
  block-comment = merge {
    Sublime = BlockMatch.Sublime (
      matches.block-comment Block.Push Sublime/block-comment
    ),
    TextMate = BlockMatch.TextMate {
      patterns = matches.block-comment Block.Captures TextMate/block-comment
    }
  } target,
  single-line-comment = merge {
    Sublime = BlockMatch.Sublime (
      matches.line-comment Block.Push Sublime/line-comment
    ),
    TextMate = BlockMatch.TextMate {
      patterns = matches.line-comment Block.Captures TextMate/line-comment
    }
  } target
}
