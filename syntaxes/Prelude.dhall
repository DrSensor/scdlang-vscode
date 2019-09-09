let _ = {=}
  let Text/concatSep = https://prelude.dhall-lang.org/Text/concatSep
  let Text/concatMapSep = https://prelude.dhall-lang.org/Text/concatMapSep
  let Text/defaultMap = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Text/defaultMap
  let Text/default = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Text/default
  let List/map = https://prelude.dhall-lang.org/List/map
  let List/filter = https://prelude.dhall-lang.org/List/filter
  let not = https://prelude.dhall-lang.org/Bool/not
  let Optionla/null = https://prelude.dhall-lang.org/Optional/null
let lang = "scl"

let Scope = { name: Text }
  let Scope/from = λ(scopes: List Text) ->
    let scopes = List/reverse Text scopes
    let suffixEach = λ(scope: Text) -> scope++".${lang}"
    in Text/concatMapSep " " Text suffixEach scopes

let Include = { include: Text }
  let Include/entry = λ(repo: Text) -> { include = "#"++repo }
  let Include/from = λ(repos: List Text)
    -> List/map Text Include Include/entry repos

let pattern = {
  LineMatch = { match: Text, captures: List Scope }
}

let Pair = { match: Optional Text, scope: Text, optional: Bool }
  let Pair/Index = { index: Natural, value: Pair }

  let Pair/optional = λ(match: Text) -> λ(scope: Text)
    -> { match = Some match, scope = scope, optional = True }
  let Pair/required = λ(match: Text) -> λ(scope: Text)
    -> (Pair/optional match scope) ⫽ { optional = False }

  let Pair/getMatch = λ(pair: Pair) ->
    let putBracket = λ(match: Text) ->
      let opt = if pair.optional then "?" else ""
      in "(${match})${opt}"
    in Text/defaultMap Text putBracket pair.match

  let Pair/filterMatch = λ(pairs: List Pair) ->
    let someMatch = λ(pair: Pair) -> not (Optionla/null Text pair.match)
    in List/filter Pair someMatch pairs

  --#region Pair/group
  let group = λ(match: { optional: Bool, separator: Text }) -> λ(pairs: List Pair) ->
      let transform = λ(pair: Pair/Index) ->
        let regex = if Natural/isZero pair.index
          then Some "?:${Text/concatMapSep match.separator Pair Pair/getMatch (Pair/filterMatch pairs)}"
          else None Text
        in pair.value ⫽ { match = regex, optional = match.optional }
    in List/map Pair/Index Pair transform (List/indexed Pair pairs)

  let Pair/group/required = λ(separator: Text) -> λ(pairs: List Pair)
    -> group { optional = False, separator = separator } pairs
  let Pair/group/optional = λ(separator: Text) -> λ(pairs: List Pair)
    -> group { optional = True, separator = separator } pairs
  --#endregion Pair/group

let capture =
  {-assert : capture "root.scope" "\\s"
  [ pair "[A-Z][0-9]+" "child1.scope"
  , pair "[a-z]\w*"    "child2.scope"
  ] ===
  { match: "([A-Z][0-9]+)\\s([A-Z][0-9]+)"
  , captures: [ { name = "child1.scope" }
              , { name = "child2.scope" } ] } -}
  let captureFrom = λ(pair: Pair) -> { name = pair.scope }
  in λ(rootScope: Text) ->
    let firstCapture = [{ name = "meta.${rootScope}.${lang}" }]
  in λ(separator: Text) -> λ(pairs: List Pair) -> {
    match = Text/concatMapSep separator Pair Pair/getMatch (Pair/filterMatch pairs),
    captures = firstCapture # List/map Pair Scope captureFrom pairs
  }

in {
  scopeLanguage = lang,
  util = {
    Pair = Pair,
      Pair/required = Pair/required,
      Pair/optional = Pair/optional,
      Pair/group          = Pair/group/required,
      Pair/group/required = Pair/group/required,
      Pair/group/optional = Pair/group/optional,
    Scope = Scope,
      Scope/from = Scope/from
  },
  pattern = {
    Include = Include,
      Include/entry = Include/entry,
      Include/from  = Include/from,
    capture = capture
  } ∧ pattern
}
