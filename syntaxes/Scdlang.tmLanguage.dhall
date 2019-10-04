let Prelude = https://prelude.dhall-lang.org/package.dhall sha256:771c7131fc87e13eb18f770a27c59f9418879f7e230ba2a50e46f4461f43ec69 ? https://prelude.dhall-lang.org/package.dhall
  let List/concat = Prelude.List.concat

let pattern = (./Prelude.dhall).pattern
  let Include = pattern.Include
  let Include/fromMap = pattern.Include/fromMap

-- TODO: make feature-request for Text.lowercase
let target = (./Prelude.dhall).Target.TextMate
in {
  name = "Scdlang",
  scopeName = "source.scdlang",
  fileTypes = ["scl", "scdl", "fsm", "hfsm", "statecharts"],
  patterns = List/concat Include [
    Include/fromMap pattern.LineMatch  "#" toMap (./Transition.dhall target) "",
    Include/fromMap pattern.BlockMatch "#" toMap (./Comment.dhall target) ""
  ],
  repository = ./Transition.dhall target ∧ ./Comment.dhall target
}
