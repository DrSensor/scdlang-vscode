#!/bin/sh

rm --force $2; touch $2
subl $1

sleep 2; subl --command convert_syntax
sleep 1; subl --command select_all
subl --command copy

sleep 1; subl $2
sleep 1; subl --command paste
subl --command save

sleep 1; subl --command exit
sleep 0.5; rm ~/.config/sublime-text-3/Local/* # clean session
