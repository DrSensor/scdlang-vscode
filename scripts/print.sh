#!/bin/sh

if which bat 2>/dev/null; then
  BAT_PAGER='' bat $@
else
  docker-compose run --rm bat $@
fi
