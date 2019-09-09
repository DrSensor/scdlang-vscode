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
      From = Scope/from ["meta.state.from", "entity.name.class"],
      Into = Scope/from ["meta.state.into", "entity.other.inherited-class"],
      Loop = Scope/from ["meta.state.into", "storage.type.inherited-class"]
    } type,

    operator = {
      arrow = Scope/from ["meta.arrow", "keyword.operator"]
    }
  },

  type = {
    State = State
  }
}
