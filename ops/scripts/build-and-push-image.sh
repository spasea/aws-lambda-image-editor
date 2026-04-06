#!/usr/bin/env bash
set -euo pipefail

# Example:
# AWS_PROFILE=example \
# AWS_REGION=eu-west-1 \
# AWS_ACCOUNT_ID=123456789012 \
# ECR_REPO=example-image-editor \
# IMAGE_TAG=dev \
# bash ops/scripts/build-and-push-image.sh

: "${AWS_PROFILE:?AWS_PROFILE is required}"
: "${AWS_REGION:?AWS_REGION is required}"
: "${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID is required}"
: "${ECR_REPO:?ECR_REPO is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"

DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"
image_ref="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"

aws ecr get-login-password \
  --profile "${AWS_PROFILE}" \
  --region "${AWS_REGION}" \
  | docker login \
      --username AWS \
      --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker buildx build \
  --platform "${DOCKER_PLATFORM}" \
  --file ops/services/image-editor-lambda/Dockerfile \
  --tag "${image_ref}" \
  --push \
  .

echo "Pushed ${image_ref}"
