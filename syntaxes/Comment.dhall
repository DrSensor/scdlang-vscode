let Map = https://prelude.dhall-lang.org/Map/Type sha256:210c7a9eba71efbb0f7a66b3dcf8b9d3976ffc2bc0e907aadfb6aa29c333e8ed ? https://prelude.dhall-lang.org/Map/Type
let List/map = https://prelude.dhall-lang.org/List/map sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680 ? https://prelude.dhall-lang.org/List/map
let List/toMap = λ(a: Type) -> λ(list: List a) ->
  let List/Index = { index: Natural, value: a }
  let List/Map = { mapKey: Text, mapValue: a }
  let list2map = λ(indexed: List/Index) -> { mapKey = Natural/show indexed.index, mapValue = indexed.value }
  let indexedList = List/indexed a list
  in List/map List/Index List/Map list2map indexedList

let Textmate = ./Prelude.dhall
  let Scope = Textmate.util.Scope
  let Scope/list2map = Textmate.util.Scope/list2map
  let Scope/from = Textmate.util.Scope/from
  let Scope/name = Textmate.util.Scope/name

let scope = {
  line-comment = Scope/from ["comment.line.double-slash"],
  block-comment = Scope/from ["punctuation.definition.comment"]
}

let begin = {
  line-comment = {
    begin = "(^[ \t]+)?((//)(?:\\s*(?=\\s|$))?)",
    beginCaptures = Scope/list2map 1 [
      Scope/name ["punctuation.whitespace.comment.leading"],
      Scope/name ["comment.line.double-slash"],
      Scope/name ["punctuation.definition.comment"]
    ]
  }
}

let line-comment/endMatch = λ(str: Text) -> begin.line-comment ∧ {
  end = "(?=${str})",
  contentName = Some scope.line-comment
} ∧ { name = None Text, endCaptures = None (Map Text Scope) }

let Match = < Partial | Full >
let block-comment/beginCaptures = λ(type: Match) ->
  let skip = merge { Partial = 1, Full = 0 } type
  let commentScope = { name= scope.block-comment }
  in λ(match: Text) -> λ(rootScopes: Text) -> ({
    name = Some rootScopes,
    begin = match,
    beginCaptures = Scope/list2map skip [commentScope],
    end = "\\*/",
    endCaptures = Some (Scope/list2map 0 [commentScope])
  } ∧ { contentName = None Text })

-- see https://github.com/microsoft/TypeScript-TmLanguage/blob/9b9b1303670a79752508bb8526f22f8ed61c22a8/TypeScript.YAML-tmLanguage#L2685-L2724
-- TODO: use `let inlineComment = \/\*([^\*]|(\*[^\/]))*\*\/` in all expressions
in {
  block-comment = {
    patterns = [
      block-comment/beginCaptures Match.Full "/\\*\\*(?!/)" "comment.block.documentation",
      block-comment/beginCaptures Match.Partial "(/\\*)(?:\\s*(?=\\s|(\\*/)))?" "comment.block"
    ]
  } : Textmate.pattern.BlockMatch,
  single-line-comment = {
    patterns = [
      line-comment/endMatch "$",
      line-comment/endMatch "^"
    ]
  } : Textmate.pattern.BlockMatch
}
