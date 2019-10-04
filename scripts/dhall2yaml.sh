#!/usr/bin/env bash

dhall-to-yaml "${@:1:$#-1}" | tr -d "'" > "${@:$#}"
