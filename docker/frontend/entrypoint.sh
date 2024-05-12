#!/bin/bash
set -ex
DEBUG=${1}

cd /opt/app
if [ -n "$DEBUG" ]; then
  npm install
  npm run dev
else
  node /opt/app/.output/server/index.mjs
fi