let Text/concatMapSep = https://prelude.dhall-lang.org/Text/concatMapSep
let List/map = https://prelude.dhall-lang.org/List/map
let lang = "scl"

let Scope = { name: Text }
let Scope/from = λ(scopes: List Text) ->
  let scopes = List/reverse Text scopes
  let suffixEach = λ(scope: Text) -> scope++".${lang}"
  in Text/concatMapSep " " Text suffixEach scopes

let Pair = { match: Text, scope: Text }
let Pair/entry = λ(match: Text) -> λ(scope: Text) -> { match = match, scope = scope }

let Include = { include: Text }
let Include/entry = λ(repo: Text) -> { include = "#"++repo }
let Include/from = λ(repos: List Text)
  -> List/map Text Include Include/entry repos

let pattern = {
  LineMatch = { match: Text, captures: List Scope }
}

{-assert :
capture "root.scope" "\\s" [
  pair "[A-Z][0-9]+" "child1.scope"
  pair "[a-z]\w*"    "child2.scope"
] === {
  match: "([A-Z][0-9]+)\\s([A-Z][0-9]+)",
  captures: [
    { name = "child1.scope" }
    { name = "child2.scope" }
  ]
} -}
let capture = λ(rootScope: Text) -> λ(separator: Text)
  -> λ(pairs: List Pair) ->
    let matchFrom = λ(pair: Pair) -> "(${pair.match})"
    let captureFrom = λ(pair: Pair) -> { name = pair.scope }
    let firstCapture = [{ name = "meta.${rootScope}.${lang}" }]
    in {
      match = Text/concatMapSep separator Pair matchFrom pairs,
      captures = firstCapture # List/map Pair Scope captureFrom pairs
    }

in {
  scopeLanguage = lang,
  util = {
    Pair = Pair,
      Pair/entry = Pair/entry,
    Scope = Scope,
      Scope/from = Scope/from
  },
  pattern = {
    Include = Include,
      Include/entry = Include/entry,
      Include/from = Include/from,
    capture = capture
  } ⫽ pattern
}
