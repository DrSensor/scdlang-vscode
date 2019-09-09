let Map = https://prelude.dhall-lang.org/Map/Type
let Map/keys = https://prelude.dhall-lang.org/Map/keys
let List/map = https://prelude.dhall-lang.org/List/map

let Prelude = ./Prelude.dhall
let Transition = ./Transition.dhall

let pattern = Prelude.pattern
let keys = λ(a: Type) -> λ(b: Map Text a) -> Map/keys Text a b

-- TODO: make feature-request for Text.lowercase
in {
  name = "Scdlang",
  scopeName = "source.scdlang",
  fileTypes = ["scl", "scdl", "fsm", "hfsm", "statecharts"],
  repository = Transition,
  patterns =
    let Transition = toMap Transition
    in pattern.Include/from (keys pattern.LineMatch Transition)
}
