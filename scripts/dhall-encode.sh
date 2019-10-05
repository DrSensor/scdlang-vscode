#!/usr/bin/env bash

help() {
  echo "Usage: dhall-encode [ -c type|resolve|text ] -I input.dhall -O output.dhall
    -I <FILE>         Read expression from FILE
    -O <FILE>         Write encoded expression into FILE
    -c <SUBCOMMAND>   Encode output from \`dhall SUBCOMMAND\`
  " >&2
}

[[ $# -eq 0 || ! $1 == "-"* ]] && help
for arg in "$@"
do
    case $arg in
        -I|--input)
          INPUT=$2
          shift
        ;;
        -c|--command)
          COMMAND=$2
          shift
        ;;
        -O|--output)
          OUTPUT="$2"
          shift
        ;;
        *)
          shift
        ;;
    esac
done

dhall $COMMAND --file $INPUT | dhall encode > $OUTPUT
