# Task runner for developing Scdlang syntax highlighting

## run
### run syntect (file)
> Print syntect highlighting result

```sh
./target/release/examples/print $file dist/newlines.packdump
```

## prepare
> Prepare the ingredients for various tasks 🍳

```sh
mkdir -p dist/rules
cargo build --release --examples
docker-compose up --no-start
```

## build
> Please run `prepare build` before running this tasks ⚠

### build vscode
> Generate textmate grammar to be used in VSCode

```sh
if which dhall-to-json 2>/dev/null; then
  if dhall-to-json --file syntaxes/Scdlang.dhall --pretty --output dist/Scdlang.tmLanguage.json; then
    BAT_PAGER='' bat dist/Scdlang.tmLanguage.json
  fi
else
  docker-compose run --rm --user $(id --user) dhall-json
fi
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

### build syntect
> Generate dump file for syntect

```sh
[ "$(ls -A dist/rules)" ] || mask build textmate
[ -f dist/Scdlang.sublime-syntax ] || mask build sublime
docker-compose run --rm --user $(id --user) packdump
```

### build clear
> Remove all artifacts

```sh
rm dist/**/*
rm dist/Scdlang.*
rm dist/*.*dump
```

## cleanup
> Cleanup all build tools 🧹

```sh
docker-compose down -v --rmi all --remove-orphans
cargo clean
```