let Text/concatMapSep = https://prelude.dhall-lang.org/Text/concatMapSep

let Textmate = ./Prelude.dhall
let Scope/from = Textmate.util.Scope/from

let lang = Textmate.scopeLanguage
let State = < From | Into | Loop >
let Event = < Internal | External | Loop >

in {
  naming = {
    PascalCase = "[A-Z]\\w*",
    camelCase = "[a-z]\\w*"
  },

  scope = {
    language = lang,
    state = λ(type: State) -> merge {
      From = Scope/from ["meta.state.from",      "entity.name.class"],
      Into = Scope/from ["meta.state.into",      "entity.other.inherited-class"],
      Loop = Scope/from ["meta.state.into.loop", "storage.type.inherited-class"]
    } type,

    event = λ(type: Event) -> merge {
      Internal = Scope/from ["meta.event.internal", "entity.name.tag"],
      External = Scope/from ["meta.event.external", "entity.name.class"],
      Loop     = Scope/from ["meta.event.loop",     "storage.type.class"]
    } type,
    guard  = Scope/from ["meta.guard",  "entity.other.inherited-class"],
    action = Scope/from ["meta.action", "support.function"],

    operator = {
      arrow = Scope/from ["meta.arrow", "keyword.operator"],
      at    = Scope/from ["meta.at",    "keyword.operator"],
      pipe  = Scope/from ["meta.pipe",  "keyword.operator"]
    }
  },

  type = {
    State = State,
    Event = Event
  }
}
