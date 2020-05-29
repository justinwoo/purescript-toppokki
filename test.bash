#!/usr/bin/env nix-shell
#!nix-shell shell.nix -i bash

yarn
bower install

yarn build
node -e "require('./output/Test.Main').main()"
