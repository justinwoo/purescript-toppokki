#! /usr/bin/env nix-shell
#! nix-shell shell.nix -i bash

set -e

bower install
yarn

pulp build --include test

node ./test/index.mjs
