let Map/keys = https://prelude.dhall-lang.org/Map/keys
let List/map = https://prelude.dhall-lang.org/List/map

let Prelude = ./Prelude.dhall
let Transition = ./Transition.dhall

let pattern = Prelude.pattern

-- TODO: make feature-request for Text.lowercase
in {
  name = "Scdlang",
  scopeName = "source.scdlang",
  fileTypes = ["scl", "scdl", "fsm", "hfsm", "statecharts"],
  patterns = pattern.Include/list (Map/keys Text pattern.OneLine Transition),
  repository = Transition
}
