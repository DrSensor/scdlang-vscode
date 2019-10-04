let Prelude = https://prelude.dhall-lang.org/package.dhall sha256:771c7131fc87e13eb18f770a27c59f9418879f7e230ba2a50e46f4461f43ec69 ? https://prelude.dhall-lang.org/package.dhall
  let Text/default = Prelude.Text.default
  let List/null = Prelude.List.null
  let List/empty = λ(a: Type) -> [] : List a
  let Optional/null = Prelude.Optional.null
  let Text/head = λ(text: List Text) -> Text/default (List/head Text text)
  let Text/head/empty = λ(text: List Text) -> Optional/null Text (List/head Text text)
  let Text/last = λ(text: List Text) -> Text/default (List/last Text text)
  let Text/last/empty = λ(text: List Text) -> Optional/null Text (List/last Text text)

let Syntax = ./Syntax.dhall
  let State = Syntax.type.State
  let Event = Syntax.type.Event
  let state  = Syntax.naming.PascalCase
  let event  = Syntax.naming.PascalCase
  let guard  = Syntax.naming.camelCase
  let action = Syntax.naming.camelCase

let Textmate = ./Prelude.dhall
  let Target = Textmate.Target
  let LineMatch = Textmate.pattern.LineMatch
  let Pair = Textmate.util.Pair
    let Pair/required = Textmate.util.Pair/required
    let Pair/optional = Textmate.util.Pair/optional
    let Pair/group = Textmate.util.Pair/group
    let Pair/group/required = Textmate.util.Pair/group/required
    let Pair/group/optional = Textmate.util.Pair/group/optional
  let capture/from = Textmate.pattern.capture/from

let Direction = < Left | Right | Both >
let Pair/stateFrom = λ(type: State) -> λ(match: Text)
  -> [Pair/required match (Syntax.scope.state type)]

let event = λ(type: Event) -> [
    Pair/required "@"                   (Syntax.scope.operator.at)
  ] # Pair/group "" [
    Pair/optional event                 (Syntax.scope.event type),
    Pair/optional "?:\\[(${guard})\\]"  (Syntax.scope.guard)
  ]
  let event/optional = λ(type: Event) -> Pair/group/optional "\\s*" (event type)
  let event/required = λ(type: Event) -> Pair/group/required "\\s*" (event type)

let action = [
    Pair/required "\\|>"  (Syntax.scope.operator.pipe),
    Pair/optional action  (Syntax.scope.action)
  ]
  let action/optional = Pair/group/optional "\\s*" action
  let action/required = Pair/group/required "\\s*" action

let internal-transition/withState = λ(target: Target) -> λ(withState: Bool) -> λ(brackets: List Text) ->
  let currentScope = if List/null Text brackets
    then Syntax.scope.state State.From
    else Syntax.scope.state State.Loop
  let pairState = if withState then [Pair/required state currentScope] else List/empty Pair
  let bracket/open = if Text/head/empty brackets
    then List/empty Pair
    else [Pair/required (Text/head brackets) "keyword.operator"]
  let bracket/close = if Natural/odd (List/length Text brackets)
    then List/empty Pair
    else [Pair/required (Text/last brackets) "keyword.operator"]
  in λ(scope: Text) ->
    let matches = capture/from target 0 scope "\\s*" (pairState # bracket/open 
      # event/required Event.Internal
      # action/required
    # bracket/close)
  in merge {
    TextMate = LineMatch.TextMate matches,
    Sublime = LineMatch.Sublime [matches]
  } target

let transition-from = λ(target: Target) -> λ(leftState: Optional Text) -> λ(type: Event) ->
  let State/Into = merge
    { Loop = State.Loop, External = State.Into, Internal = State.From } type
  in λ(regex: Text) -> λ(arrow: Direction) ->
    let rhs = merge { Left = State.From, Right = State/Into, Both = State/Into } arrow
    let lhs = merge { Left = State/Into, Right = State.From, Both = State/Into } arrow
    let firstPair = Optional/fold Text leftState
      (List Pair) (Pair/stateFrom lhs) (List/empty Pair)
  in λ(scope: Text) ->
    let matches = capture/from target 0 scope "\\s*" (firstPair # [
      Pair/required regex (Syntax.scope.operator.arrow),
      Pair/required state (Syntax.scope.state rhs)
    ] # event/optional type # action/optional)
  in merge {
    TextMate = LineMatch.TextMate matches,
    Sublime = LineMatch.Sublime [matches]
  } target

let normal-transition = λ(target: Target) -> λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from target (Some state) Event.External symbol arrow scope

let loop-transition = λ(target: Target) -> λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from target (Some state) Event.Loop symbol arrow scope

let self-transition = λ(target: Target) -> λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from target (None Text) Event.Loop symbol arrow scope

let internal-transition/currentState = λ(target: Target) -> λ(currentState: Bool) -> λ(scope: Text)
  -> internal-transition/withState target currentState (List/empty Text) scope

let internal-transition/noTarget = λ(target: Target) -> λ(arrow: Text) -> λ(scope: Text)
  -> internal-transition/withState target False [arrow] scope

let internal-transition/withTarget = λ(target: Target) -> λ(brackets: List Text) -> λ(scope: Text)
  -> internal-transition/withState target True brackets scope

in λ(target: Target) -> {
  transition-into   = normal-transition target Direction.Right "-+>"       "transition.normal",
  transition-from   = normal-transition target Direction.Left  "<-+"       "transition.normal",
  toggle-transition = normal-transition target Direction.Both  "<-+>"      "transition.toggle",
  self-transition   = self-transition   target Direction.Right "-+>>"      "transition.loop",
  loop-from         = loop-transition   target Direction.Left  "<<-+|<-+<" "transition.loop",
  loop-into         = loop-transition   target Direction.Right "-+>>"      "transition.loop",
  state-internal-transition  = internal-transition/currentState target True          "transition.internal",
  parent-internal-transition = internal-transition/currentState target False         "transition.internal",
  skipper-transition         = internal-transition/withTarget   target ["<-+<", ">"] "transition.internal",
  root-internal-transition   = internal-transition/noTarget     target "<-+<"        "transition.internal"
}
