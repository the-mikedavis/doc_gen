#! /bin/bash

set -e

if [[ $# -eq 0 ]]; then
  echo 'Supply a tag as the first argument!'
  exit 1
fi

mix deps.get
mix bless
cd assets
./node_modules/.bin/webpack -p
cd ..
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release --env=prod
~/go/bin/ghr "$1" _build/prod/rel/doc_gen/releases/*/*.tar.gz
