# Task runner for developing Scdlang syntax highlighting

## prepare
> Prepare the ingredients for various tasks 🍳

```sh
mkdir -p dist/rules
```

## build
> Please run `prepare build` before running this tasks ⚠

### build vscode
> Generate textmate grammar to be used in VSCode

```sh
pnpx js-yaml syntaxes/Scdlang.YAML-tmLanguage > dist/Scdlang.tmLanguage.json
```

### build textmate
> Generate textmate grammar in plist format

```sh
./scripts/yaml2plist.js syntaxes/Scdlang.YAML-tmLanguage > dist/Scdlang.tmLanguage
for rule in syntaxes/rules/*.YAML-tmPreferences; do
  ./scripts/yaml2plist.js "$rule" > dist/rules/$(basename "${rule%.*}").tmPreferences
done
```

### build clear
> Remove all artifacts

```sh
rm dist/**/*
rm dist/Scdlang.*
```