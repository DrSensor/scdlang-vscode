#!/usr/bin/env node
const { join } = require("path")
const { argv, cwd, stdout } = process

function readYaml(filePath) {
  const text = require("fs").readFileSync(filePath, "utf8")
  return JSON.parse(text)
}

function inspectPlist(object) {
  const { build } = require("plist")
  stdout.write(build(object))
}

const file = join(cwd(), argv[2])

const yaml = readYaml(file)
inspectPlist(yaml)
