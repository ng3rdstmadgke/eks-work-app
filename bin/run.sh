#!/bin/bash

MODE=${1:-"dev"}

PROJECT_DIR=$(cd $(dirname $0)/..; pwd)
cd $PROJECT_DIR

if [ "$MODE" = "dev" ]; then
  docker-compose -f docker-compose-dev.yml build
  docker-compose -f docker-compose-dev.yml up --force-recreate
  exit
else
  docker-compose -f docker-compose-prd.yml build
  docker-compose -f docker-compose-prd.yml up --force-recreate
fi