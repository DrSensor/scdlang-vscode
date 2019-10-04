let Prelude = https://prelude.dhall-lang.org/package.dhall sha256:771c7131fc87e13eb18f770a27c59f9418879f7e230ba2a50e46f4461f43ec69 ? https://prelude.dhall-lang.org/package.dhall
  let Map = https://prelude.dhall-lang.org/Map/Type sha256:210c7a9eba71efbb0f7a66b3dcf8b9d3976ffc2bc0e907aadfb6aa29c333e8ed ? https://prelude.dhall-lang.org/Map/Type
  let Map/keys = Prelude.Map.keys
  let Text/defaultMap = Prelude.Text.defaultMap
  let Text/concatMapSep = Prelude.Text.concatMapSep
  let List/map = Prelude.List.map
  let List/filter = Prelude.List.filter
  let not = Prelude.Bool.not
  let Optionla/null = Prelude.Optional.null
let lang = "scl" --TODO: replace with env:LANG as Text
let Target = < TextMate | Sublime >

let Scope = < TextMate: { name: Text } | Sublime: Text >
  let Scope/Index = { index: Natural, value: Scope }
  let Scope/Map = { mapKey: Text, mapValue: Scope }
  let Scope/from = λ(scopes: List Text) ->
    let scopes = List/reverse Text scopes
    let suffixEach = λ(scope: Text) -> scope++".${lang}"
    in Text/concatMapSep " " Text suffixEach scopes
  let Scope/name = λ(target: Target) -> λ(scopes: List Text)
    -> merge {
      TextMate = Scope.TextMate { name = Scope/from scopes },
      Sublime = Scope.Sublime (Scope/from scopes)
    } target
  let Scope/list2map = λ(startpos: Natural) ->
    let pair2map = λ(scope: Scope/Index) -> {
      mapKey = Natural/show (scope.index + startpos),
      mapValue = scope.value
    }
    in λ(captures: List Scope) ->
      let indexedCaptures = List/indexed Scope captures
    in List/map Scope/Index Scope/Map pair2map indexedCaptures

let Include = { include: Text }
  let Include/entry = λ(prefix: Text) -> λ(repo: Text) -> λ(suffix: Text)
    -> { include = prefix++repo++suffix }
  let Include/from = λ(prefix: Text) -> λ(repos: List Text) -> λ(suffix: Text) ->
    let map = λ(repo: Text) -> Include/entry prefix repo suffix
    in List/map Text Include map repos
  let Include/fromMap = λ(a: Type) -> λ(prefix: Text) -> λ(b: Map Text a) -> λ(suffix: Text)
    -> Include/from prefix (Map/keys Text a b) suffix


let pattern =
  let Captures = Map Text Scope
  let Match = { match: Text, captures: Captures }
  ------ TextMate ------
  let BlockCaptures = {
    name: Optional Text, contentName: Optional Text,
    begin: Text, beginCaptures: Captures,
    end: Text, endCaptures: Captures
  }
  ------ Sublime Text ------
  let Meta = <
    Root: { meta_scope: Text } |
    Content: { meta_content_scope: Text } |
    Prototype: { meta_include_prototype: Bool } |
    Clear: { clear_scopes: Bool }
  >
  let Push = < Meta: Meta | Match: Match ⩓ { pop: Bool } >
  let BlockPush = Match ⩓ { push: List Push }
  --------------------------
  in {
    LineMatch = < TextMate: Match | Sublime: List Match >,
    BlockMatch = <
      TextMate: { patterns: List BlockCaptures } |
      Sublime: List BlockPush
    >,
    Block = { Captures = BlockCaptures, Push = BlockPush },
    Sublime = { Meta = Meta, Push = Push }
  }


let Pair = { match: Optional Text, scope: Text, optional: Bool }
  let Pair/Index = { index: Natural, value: Pair }

  let Pair/optional = λ(match: Text) -> λ(scope: Text)
    -> { match = Some match, scope = scope, optional = True }
  let Pair/required = λ(match: Text) -> λ(scope: Text)
    -> (Pair/optional match scope) ⫽ { optional = False }

  let Pair/getMatch = λ(pair: Pair) ->
    let putBracket = λ(match: Text)
      -> "(${match})" ++ (if pair.optional then "?" else "")
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

let capture/from = λ(target: Target) -> λ(startpos: Natural) ->
  let captureFrom = λ(pair: Pair) -> Scope/name target [pair.scope]
  in λ(rootScope: Text) ->
    let firstCapture = [Scope/name target ["meta.${rootScope}.${lang}"]]
  in λ(separator: Text) -> λ(pairs: List Pair) -> 
    let captures = (firstCapture # List/map Pair Scope captureFrom pairs)
  in {
    match = Text/concatMapSep separator Pair Pair/getMatch (Pair/filterMatch pairs),
    captures = Scope/list2map startpos captures
  }

let capture/begin = λ(target: Target) -> λ(startpos: Natural) -> λ(rootScope: Text) -> λ(separator: Text) -> λ(pairs: List Pair) ->
  let captured = capture/from target startpos rootScope separator pairs
  in { begin = captured.match, beginCaptures = captured.captures }

let capture/end = λ(target: Target) -> λ(startpos: Natural) -> λ(rootScope: Text) -> λ(separator: Text) -> λ(pairs: List Pair) ->
  let captured = capture/from target startpos rootScope separator pairs
  in { end = captured.match, endCaptures = captured.captures }

in {
  scopeLanguage = lang,
  Target = Target,
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
      Include/fromMap = Include/fromMap,
    capture/from = capture/from,
      capture/begin = capture/begin,
      capture/end = capture/end
  } ∧ pattern
}
