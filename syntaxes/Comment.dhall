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

let begin = {
  line-comment = {
    begin = "(^[ \t]+)?((//)(?:\\s*(?=\\s|$))?)",
    beginCaptures = Scope/list2map [
      Scope/name ["punctuation.whitespace.comment.leading"],
      Scope/name ["comment.line.double-slash"],
      Scope/name ["punctuation.definition.comment"]
    ]
  }
}

let scope = {
  line-comment = Scope/from ["comment.line.double-slash"],
  block-comment = Scope/from ["punctuation.definition.comment"]
}

let line-comment/endMatch = λ(str: Text) -> begin.line-comment ∧ {
  end = "(?=${str})",
  contentName = scope.line-comment
}

in {
  comment = {
    patterns = [
      line-comment/endMatch "$"
    ]
  },
  single-line-comment-consuming-line-ending = line-comment/endMatch "^"
}
