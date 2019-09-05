#!/usr/bin/env node
const { join } = require("path")
const { argv, cwd, stdout } = process

function readYaml(filePath) {
  const text = require("fs").readFileSync(filePath, "utf8")
  return require("js-yaml").safeLoad(text)
}

function inspectPlist(object) {
  const { build } = require("plist")
  stdout.write(build(object))
}

const file = join(cwd(), argv[2])

const yaml = readYaml(file)
inspectPlist(yaml)
