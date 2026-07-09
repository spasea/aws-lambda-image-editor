#!/usr/bin/env bash
set -euo pipefail

# Example:
# AWS_PROFILE=example \
# AWS_REGION=eu-west-1 \
# AWS_ACCOUNT_ID=123456789012 \
# ECR_REPO=example-image-editor \
# bash ops/scripts/build-and-push-image.sh

: "${AWS_PROFILE:?AWS_PROFILE is required}"
: "${AWS_REGION:?AWS_REGION is required}"
: "${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID is required}"
: "${ECR_REPO:?ECR_REPO is required}"

if [[ -z "${IMAGE_TAG:-}" ]]; then
  IMAGE_TAG="git-$(git rev-parse --short=12 HEAD)"
fi

DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"
image_ref="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
registry_ref="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

aws ecr get-login-password \
  --profile "${AWS_PROFILE}" \
  --region "${AWS_REGION}" \
  | docker login \
      --username AWS \
      --password-stdin "${registry_ref}"

docker buildx build \
  --platform "${DOCKER_PLATFORM}" \
  --provenance=false \
  --sbom=false \
  --file ops/services/image-editor-lambda/Dockerfile \
  --tag "${image_ref}" \
  --push \
  .

image_digest="$(
  aws ecr describe-images \
    --profile "${AWS_PROFILE}" \
    --region "${AWS_REGION}" \
    --repository-name "${ECR_REPO}" \
    --image-ids imageTag="${IMAGE_TAG}" \
    --query 'imageDetails[0].imageDigest' \
    --output text
)"

immutable_image_uri="${registry_ref}/${ECR_REPO}@${image_digest}"

echo "Pushed ${image_ref}"
echo "Digest ${image_digest}"
echo "Immutable image URI ${immutable_image_uri}"
