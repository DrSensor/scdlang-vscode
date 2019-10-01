# Change Log

All notable changes to the "scdlang" extension will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.

## [Unreleased]

## [0.1.1] - 2019-10-05
### Added
- add encoded dhall value for generated:
  - TextMate grammar ([Scdlang.DHALL-tmLanguage.bin]) and
  - Sublime grammar  ([Scdlang.DHALL-sublime-syntax.bin])
- add dhall schema for generated:
  - TextMate grammar ([Scdlang.tmLanguage.schema.dhall]) and
  - Sublime grammar  ([Scdlang.sublime-syntax.schema.dhall])

### Changed
- Now [Scdlang.sublime-syntax] generated [directly from dhall](syntaxes/Scdlang.sublime-syntax.dhall)

[Scdlang.sublime-syntax]: https://github.com/DrSensor/scdlang-vscode/releases/download/v0.1.1/Scdlang.sublime-syntax
[Scdlang.DHALL-tmLanguage.bin]: https://github.com/DrSensor/scdlang-vscode/releases/download/v0.1.1/Scdlang.DHALL-tmLanguage.bin
[Scdlang.DHALL-sublime-syntax.bin]: https://github.com/DrSensor/scdlang-vscode/releases/download/v0.1.1/Scdlang.DHALL-sublime-syntax.bin
[Scdlang.tmLanguage.schema.dhall]: https://github.com/DrSensor/scdlang-vscode/releases/download/v0.1.1/Scdlang.tmLanguage.schema.dhall
[Scdlang.sublime-syntax.schema.dhall]: https://github.com/DrSensor/scdlang-vscode/releases/download/v0.1.1/Scdlang.sublime-syntax.schema.dhall

## [0.1.0] - 2019-10-01
### Added
- support block & line comment
- granular highlighting (each token have different color/scope)
- highlight transition with arrow (colors/scopes are base on arrow direction and type)
- highlight internal-transition
- highlight event & action

[Unreleased]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/v0.1.1
[0.1.0]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/v0.1.0