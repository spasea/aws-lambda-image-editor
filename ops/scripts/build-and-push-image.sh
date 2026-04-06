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

image_ref="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"

echo "Building ${image_ref}"
echo "This is a scaffold script. Build and push steps are added in a later patch."
