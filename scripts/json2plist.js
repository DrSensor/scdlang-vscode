#!/usr/bin/env node
const { join, dirname } = require("path")
const { readFileSync, writeFileSync } = require("fs")
const { argv, cwd, stdout } = process

function readYaml(filePath) {
  const text = readFileSync(filePath, "utf8")
  return JSON.parse(text)
}

function inspectPlist(object) {
  const tmLanguage = require("plist").build(object)
  if (stdout.isTTY || argv[3] === "-")
    writeFileSync(`${dirname(argv[2])}/Scdlang.tmLanguage`, tmLanguage)
  else stdout.write(tmLanguage)
}

const file = join(cwd(), argv[2])

const yaml = readYaml(file)
inspectPlist(yaml)
