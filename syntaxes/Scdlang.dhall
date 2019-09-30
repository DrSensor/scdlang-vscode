let Prelude = https://prelude.dhall-lang.org/package.dhall sha256:771c7131fc87e13eb18f770a27c59f9418879f7e230ba2a50e46f4461f43ec69 ? https://prelude.dhall-lang.org/package.dhall
  let Map = https://prelude.dhall-lang.org/Map/Type sha256:210c7a9eba71efbb0f7a66b3dcf8b9d3976ffc2bc0e907aadfb6aa29c333e8ed ? https://prelude.dhall-lang.org/Map/Type
  let Map/keys = Prelude.Map.keys

let Transition = ./Transition.dhall
let Comment = ./Comment.dhall
let Textmate = ./Prelude.dhall
  let pattern = Textmate.pattern

let keys = λ(a: Type) -> λ(b: Map Text a) -> Map/keys Text a b
let pattern = {
  transition = pattern.Include/from (keys pattern.LineMatch (toMap Transition)),
  comment = pattern.Include/from ["comment", "single-line-comment-consuming-line-ending"]
}

-- TODO: make feature-request for Text.lowercase
in {
  name = "Scdlang",
  scopeName = "source.scdlang",
  fileTypes = ["scl", "scdl", "fsm", "hfsm", "statecharts"],
  repository = Transition ∧ Comment,
  patterns = pattern.comment # pattern.transition
}
