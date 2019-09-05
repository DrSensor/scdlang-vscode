# Task runner for developing Scdlang syntax highlighting

## prepare
> Prepare the ingredients for various tasks 🍳

```sh
mkdir -p dist/rules
docker-compose up --no-start
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

### build sublime
> Generate sublime-syntax grammar

```sh
[ -f dist/Scdlang.tmLanguage ] || mask build textmate
docker-compose run --rm --user $(id --user) convert_syntax
# ./scripts/automate-sublime.sh dist/Scdlang.tmLanguage dist/Scdlang.sublime-syntax
```

### build clear
> Remove all artifacts

```sh
rm dist/**/*
rm dist/Scdlang.*
```

## cleanup
> Cleanup all build tools 🧹

```sh
docker-compose down -v --rmi all --remove-orphans
```