let Prelude = ./Prelude.dhall
let Syntax = ./Syntax.dhall

let State = Syntax.type.State

let Pair = Prelude.util.Pair
let Pair/entry = Prelude.util.Pair/entry
let capture = Prelude.pattern.capture

let Direction = < Left | Right | Both >
let stateName = Syntax.naming.PascalCase

let transition-from = λ(leftState: Optional Text) ->
    let emptyPair = [] : List Pair
    let Pair/from = λ(type: State) -> λ(match: Text)
      -> [Pair/entry match (Syntax.scope.state type)]
  in λ(symbol: { regex: Text, loop: Bool }) ->
    let State/Into = if symbol.loop then State.Loop else State.Into
  in λ(arrow: Direction) ->
    let rhs = merge { Left = State.From, Right = State/Into, Both = State/Into } arrow
    let lhs = merge { Left = State/Into, Right = State.From, Both = State/Into } arrow
    let firstPair = Optional/fold Text leftState (List Pair) (Pair/from lhs) emptyPair
  in λ(scope: Text) -> capture scope "\\s*" (firstPair # [
      Pair/entry symbol.regex (Syntax.scope.operator.arrow),
      Pair/entry stateName    (Syntax.scope.state rhs)
  ])

let normal-transition = λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from (Some stateName) { regex = symbol, loop = False } arrow scope

let loop-transition = λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from (Some stateName) { regex = symbol, loop = True } arrow scope

let self-transition = λ(arrow: Direction) -> λ(symbol: Text) -> λ(scope: Text)
  -> transition-from (None Text) { regex = symbol, loop = True } arrow scope

in toMap {
  transition-into   = normal-transition Direction.Right "-+>>?"     "transition.normal",
  transition-from   = normal-transition Direction.Left  "<?<-+"     "transition.normal",
  toggle-transition = normal-transition Direction.Both  "<-+>"      "transition.toggle",
  self-transition   = self-transition   Direction.Right "-+>>|>-+>" "transition.loop",
  loop-from         = loop-transition   Direction.Left  "<<-+|<-+<" "transition.loop",
  loop-into         = loop-transition   Direction.Right "-+>>"      "transition.loop"
}
