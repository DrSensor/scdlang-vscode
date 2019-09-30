let Prelude = https://prelude.dhall-lang.org/package.dhall sha256:771c7131fc87e13eb18f770a27c59f9418879f7e230ba2a50e46f4461f43ec69 ? https://prelude.dhall-lang.org/package.dhall
  let Map = https://prelude.dhall-lang.org/Map/Type sha256:210c7a9eba71efbb0f7a66b3dcf8b9d3976ffc2bc0e907aadfb6aa29c333e8ed ? https://prelude.dhall-lang.org/Map/Type
  let Text/defaultMap = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Text/defaultMap sha256:a35c0e1db25e9223223b0beba0fcefeba7cd06a0edfa3994ccc9f82f6b86ff79 ? https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Text/defaultMap
  let Text/concatMapSep = Prelude.Text.concatMapSep
  let List/map = Prelude.List.map
  let List/filter = Prelude.List.filter
  let not = Prelude.Bool.not
  let Optionla/null = Prelude.Optional.null
let lang = "scl"

let Scope = { name: Text }
  let Scope/Index = { index: Natural, value: Scope }
  let Scope/Map = { mapKey: Text, mapValue: Scope }
  let Scope/from = λ(scopes: List Text) ->
    let scopes = List/reverse Text scopes
    let suffixEach = λ(scope: Text) -> scope++".${lang}"
    in Text/concatMapSep " " Text suffixEach scopes
  let Scope/name = λ(scopes: List Text) -> { name = Scope/from scopes }
  let Scope/list2map = λ(captures: List Scope) ->
    let pair2map = λ(scope: Scope/Index) -> { mapKey = Natural/show scope.index, mapValue = scope.value }
    let indexedCaptures = List/indexed Scope captures
    in List/map Scope/Index Scope/Map pair2map indexedCaptures

let Include = { include: Text }
  let Include/entry = λ(repo: Text) -> { include = "#"++repo }
  let Include/from = λ(repos: List Text)
    -> List/map Text Include Include/entry repos

let pattern = {
  LineMatch = { match: Text, captures: Map Text Scope }
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
  in λ(separator: Text) -> λ(pairs: List Pair) -> 
    let captures = (firstCapture # List/map Pair Scope captureFrom pairs)
  in {
    match = Text/concatMapSep separator Pair Pair/getMatch (Pair/filterMatch pairs),
    captures = Scope/list2map captures
  }

let capture/begin = λ(rootScope: Text) -> λ(separator: Text) -> λ(pairs: List Pair) ->
  let captured = capture rootScope separator pairs
  in { begin = captured.match, beginCaptures = captured.captures }

let capture/end = λ(rootScope: Text) -> λ(separator: Text) -> λ(pairs: List Pair) ->
  let captured = capture rootScope separator pairs
  in { end = captured.match, endCaptures = captured.captures }

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
      Scope/from = Scope/from,
      Scope/name = Scope/name,
      Scope/list2map = Scope/list2map,
      Scope/Index = Scope/Index,
      Scope/Map = Scope/Map
  },
  pattern = {
    Include = Include,
      Include/entry = Include/entry,
      Include/from  = Include/from,
    capture = capture,
      capture/begin = capture/begin,
      capture/end = capture/end
  } ∧ pattern
}
