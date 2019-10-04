let Prelude = https://prelude.dhall-lang.org/package.dhall sha256:771c7131fc87e13eb18f770a27c59f9418879f7e230ba2a50e46f4461f43ec69 ? https://prelude.dhall-lang.org/package.dhall
  let List/concat = Prelude.List.concat
  let Map/map = Prelude.Map.map

let tmLanguage = ./Scdlang.tmLanguage.dhall
let pattern = (./Prelude.dhall).pattern
  let Include = pattern.Include
  let Include/fromMap = pattern.Include/fromMap

let target = (./Prelude.dhall).Target.Sublime
in tmLanguage ⫽ {
  patterns = {=},
  repository = {=},
  fileTypes = [] : List Text,
  scopeName = None Text
} ⫽ {
  scope = tmLanguage.scopeName,
  file_extensions = tmLanguage.fileTypes,
  contexts = {
    main = List/concat Include [
      Include/fromMap pattern.LineMatch  "" toMap (./Transition.dhall target) "",
      Include/fromMap pattern.BlockMatch "" toMap (./Comment.dhall target)    ""
    ]
  } ⫽ ./Transition.dhall target ∧ ./Comment.dhall target
}
