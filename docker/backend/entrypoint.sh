#!/bin/bash
set -ex
DEBUG=${1}

cd /opt/app
poetry install
if [ -n "$DEBUG" ]; then
  poetry run uvicorn main:app --host 0.0.0.0 --port 8000 --reload
else
  poetry run uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2
fi