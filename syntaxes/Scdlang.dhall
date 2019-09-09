let _ = {=}
  let Map = https://prelude.dhall-lang.org/Map/Type
  let Map/keys = https://prelude.dhall-lang.org/Map/keys

let Transition = ./Transition.dhall
let Prelude = ./Prelude.dhall
  let pattern = Prelude.pattern

let keys = λ(a: Type) -> λ(b: Map Text a) -> Map/keys Text a b

-- TODO: make feature-request for Text.lowercase
in {
  name = "Scdlang",
  scopeName = "source.scdlang",
  fileTypes = ["scl", "scdl", "fsm", "hfsm", "statecharts"],
  repository = Transition,
  patterns = pattern.Include/from (keys pattern.LineMatch (toMap Transition))
}
