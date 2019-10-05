# Task runner for developing Scdlang syntax highlighting

## watch
### watch view (cmd) (file)
> Print without close

```sh
watchexec -c "mask view $cmd $file" -w syntaxes
```

## view

### view dhall (file)
> Print file.dhall in flat format

This will print post-processed *.dhall file without variable and function

```sh
if which dhall 2>/dev/null; then
  dhall --file $file
else
  docker-compose run --rm --user $(id --user) dhall --file $file
fi
```

### view bat (file)
> Print syntect highlighting result

```sh
cp dist/syntect/*.bin $HOME/.cache/bat/
./scripts/print.sh $file
```

### view bat (file)
> Print syntect highlighting result

```sh
./scripts/print.sh $file
```

## prepare
> Prepare the ingredients for various tasks 🍳

```sh
mask prepare dist
mask prepare docker
```

## prepare dist
```sh
mkdir -p dist/rules
mkdir -p dist/syntect/{syntaxes,themes}
```

## prepare docker
```sh
docker-compose up --no-start
```

<!--TODO: ## prepare import @wait-for https://github.com/dhall-lang/dhall-haskell/issues/1356-->

## build
> Please run `prepare build` before running this tasks ⚠

### build dhall (extension)

```sh
if which dhall 2>/dev/null; then
  dhall --file syntaxes/Scdlang.$extension.dhall > dist/Scdlang.$extension.dhall
else
  docker-compose run --rm --user $(id --user) dhall --file syntaxes/Scdlang.$extension.dhall > dist/Scdlang.$extension.dhall
fi

[ $? -eq 0 ] && ./scripts/print.sh dist/Scdlang.$extension.dhall
```

#### build dhall encode (extension)
> Generate textmate grammar to be used in VSCode

```sh
if which dhall 2>/dev/null; then
  ./scripts/dhall-encode.sh --input syntaxes/Scdlang.$extension.dhall --output dist/Scdlang.DHALL-$extension.bin
else
  docker-compose run --rm --user $(id --user) dhall-encode
fi
```

#### build dhall type (extension)
> Generate textmate grammar to be used in VSCode

```sh
if which dhall 2>/dev/null; then
  dhall type --file syntaxes/Scdlang.$extension.dhall > dist/Scdlang.$extension.schema.dhall
else
  docker-compose run --rm --user $(id --user) --entrypoint=bash dhall -c "dhall type --file syntaxes/Scdlang.$extension.dhall > dist/Scdlang.$extension.schema.dhall"
fi

[ $? -eq 0 ] && ./scripts/print.sh dist/Scdlang.$extension.schema.dhall
```

### build vscode
> Generate textmate grammar to be used in VSCode

```sh
run_and_inspect() { $1 && ./scripts/print.sh dist/Scdlang.tmLanguage.json; }

if which dhall-to-json 2>/dev/null; then
  run_and_inspect "dhall-to-json --file syntaxes/Scdlang.tmLanguage.dhall --pretty --output dist/Scdlang.tmLanguage.json --omitEmpty"
else
  run_and_inspect "docker-compose run --rm --user $(id --user) dhall-json"
fi
```

### build textmate
> Generate textmate grammar in plist format

```sh
[ -f dist/Scdlang.tmLanguage.json ] || mask build vscode >/dev/null
if ./scripts/json2plist.js dist/Scdlang.tmLanguage.json > dist/Scdlang.tmLanguage; then
  ./scripts/print.sh dist/Scdlang.tmLanguage -l xml
fi
```

### build sublime
> Generate sublime-syntax grammar

```sh
# [ -f dist/Scdlang.tmLanguage ] || ./scripts/automate-sublime.sh dist/Scdlang.tmLanguage dist/Scdlang.sublime-syntax

run_and_inspect() { $1 && ./scripts/print.sh dist/Scdlang.sublime-syntax; }

if which dhall-to-json 2>/dev/null; then
  run_and_inspect "./scripts/dhall2yaml.sh --omitEmpty --file syntaxes/Scdlang.sublime-syntax.dhall dist/Scdlang.sublime-syntax"
else
  run_and_inspect "docker-compose run --rm --user $(id --user) dhall-yaml"
fi
```

### build syntect
> Generate dump file for syntect

```sh
# [ "$(ls -A dist/rules)" ] || mask build textmate
linkto() { [ -f $1 ] || ln dist/Scdlang.sublime-syntax $1; }
hardlink() { linkto dist/syntect/syntaxes/Scdlang.sublime-syntax; }
[ -f dist/Scdlang.sublime-syntax ] && hardlink || (mask build sublime >/dev/null; hardlink)

run_and_inspect() { $1 && ./scripts/print.sh examples/one-liner.scl; }

if bat cache --clear 2>/dev/null; then
  run_and_inspect "bat cache --build --source dist/syntect/"
  cp $HOME/.cache/bat/*.bin dist/syntect/
else
  run_and_inspect "docker-compose run --rm --user $(id --user) packdump"
fi
```

### build clear
> Remove all artifacts

```sh
rm dist/syntect/*.bin
rm dist/syntect/*/*
rm dist/Scdlang.*
```

## cleanup
> Cleanup all build tools 🧹

```sh
docker-compose down -v --rmi all --remove-orphans
```