#!/bin/bash

PUSH=$1

APP_NAME="eks-work-app"
PROJECT_ROOT="$(cd $(dirname $0)/..; pwd)"
AWS_REGION="ap-northeast-1"

cd $PROJECT_ROOT

set -ex
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

IMAGE_PREFIX="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"
docker build --rm -f docker/nginx/Dockerfile -t "${IMAGE_PREFIX}/nginx:latest" .
docker build --rm -f docker/backend/Dockerfile -t "${IMAGE_PREFIX}/backend:latest" .
docker build --rm -f docker/frontend/Dockerfile -t "${IMAGE_PREFIX}/frontend:latest" .

if [ "$PUSH" = "push" ]; then
  aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

  VERSION=$(date +"%Y%m%d%H%M%S")
  docker tag "${IMAGE_PREFIX}/nginx:latest" "${IMAGE_PREFIX}/nginx:${VERSION}"
  docker tag "${IMAGE_PREFIX}/backend:latest" "${IMAGE_PREFIX}/backend:${VERSION}"
  docker tag "${IMAGE_PREFIX}/frontend:latest" "${IMAGE_PREFIX}/frontend:${VERSION}"

  docker push "${IMAGE_PREFIX}/nginx:latest"
  docker push "${IMAGE_PREFIX}/backend:latest"
  docker push "${IMAGE_PREFIX}/frontend:latest"
  docker push "${IMAGE_PREFIX}/nginx:${VERSION}"
  docker push "${IMAGE_PREFIX}/backend:${VERSION}"
  docker push "${IMAGE_PREFIX}/frontend:${VERSION}"
fi