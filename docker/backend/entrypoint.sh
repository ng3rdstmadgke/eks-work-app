#!/bin/bash

set -ex

cd /opt/app
poetry install
poetry run uvicorn main:app --host 0.0.0.0 --port 8000 $@