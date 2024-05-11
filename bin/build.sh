#!/bin/bash


OPTIONS=""
APP_NAME="eks-work-app"
PROJECT_ROOT="$(cd $(dirname $0)/..; pwd)"

cd $PROJECT_ROOT

set -e

docker build $OPTIONS --rm -f docker/nginx/Dockerfile -t "${APP_NAME}/nginx:latest" .
docker build $OPTIONS --rm -f docker/backend/Dockerfile -t "${APP_NAME}/backend:latest" .