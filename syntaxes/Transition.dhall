let Syntax = ./Syntax.dhall
  let State = Syntax.type.State
  let Event = Syntax.type.Event
  let state = Syntax.naming.PascalCase
  let event = Syntax.naming.PascalCase
  let guard = Syntax.naming.camelCase

let Prelude = ./Prelude.dhall
  let Pair = Prelude.util.Pair
    let Pair/required = Prelude.util.Pair/required
    let Pair/optional = Prelude.util.Pair/optional
    let Pair/group = Prelude.util.Pair/group
    let Pair/group/optional = Prelude.util.Pair/group/optional
  let capture = Prelude.pattern.capture

let Direction = < Left | Right | Both >

let event = λ(type: Event) -> Pair/group/optional "\\s*" [
  Pair/required "@"                   (Syntax.scope.operator.at),
  Pair/optional event                 (Syntax.scope.event type),
  Pair/optional "?:\\[(${guard})\\]"  (Syntax.scope.guard)
]

let transition-from =
  let Pair/from = λ(type: State) -> λ(match: Text)
    -> [Pair/optional match (Syntax.scope.state type)]
  let emptyPair = [] : List Pair
  in λ(leftState: Optional Text) -> λ(type: Event) ->
    let State/Into =
      merge { Loop = State.Loop, External = State.Into, Internal = State.From } type
  in λ(regex: Text) -> λ(arrow: Direction) ->
    let rhs = merge { Left = State.From, Right = State/Into, Both = State/Into } arrow
    let lhs = merge { Left = State/Into, Right = State.From, Both = State/Into } arrow
    let firstPair = Optional/fold Text leftState (List Pair) (Pair/from lhs) emptyPair
  in λ(scope: Text) -> capture scope "\\s*" (firstPair # [
      Pair/required regex (Syntax.scope.operator.arrow),
      Pair/optional state (Syntax.scope.state rhs)
  ] # event type)

let normal-transition = λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from (Some state) Event.External symbol arrow scope

let loop-transition = λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from (Some state) Event.Loop symbol arrow scope

let self-transition = λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from (None Text) Event.Loop symbol arrow scope

in {
  transition-into   = normal-transition Direction.Right "-+>"     "transition.normal",
  transition-from   = normal-transition Direction.Left  "<-+"     "transition.normal",
  toggle-transition = normal-transition Direction.Both  "<-+>"      "transition.toggle",
  self-transition   = self-transition   Direction.Right "-+>>|>-+>" "transition.loop",
  loop-from         = loop-transition   Direction.Left  "<<-+|<-+<" "transition.loop",
  loop-into         = loop-transition   Direction.Right "-+>>"      "transition.loop"
}
