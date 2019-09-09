let Text/concatMapSep = https://prelude.dhall-lang.org/Text/concatMapSep

let Prelude = ./Prelude.dhall
let Scope/from = Prelude.util.Scope/from

let lang = Prelude.scopeLanguage
let State = < From | Into | Loop >

in {
  naming = {
    PascalCase = "[A-Z]\\w*",
    camelCase = "[a-z]\\w*"
  },

  scope = {
    language = lang,
    state = λ(type: State) -> merge {
      From = Scope/from ["entity.name.class", "meta.state.from"],
      Into = Scope/from ["entity.other.inherited-class", "meta.state.into"],
      Loop = Scope/from ["entity.other.inherited-class", "markup.italic", "meta.state.into"]
    } type,

    operator = {
      arrow = Scope/from ["keyword.operator", "meta.arrow"]
    }
  },

  type = {
    State = State
  }
}
