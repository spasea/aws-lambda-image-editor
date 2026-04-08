# Ops

This directory contains packaging and release helpers for the Lambda image.

- `services/image-editor-lambda/Dockerfile`: AWS Lambda container image build.
- `scripts/build-and-push-image.sh`: local helper for build and push to ECR. If
  `IMAGE_TAG` is omitted, the script uses `git-<shortsha>` from the current
  commit and prints the immutable `repo@sha256:...` URI for Terraform.

The Lambda source code remains in the repository root (`handler.js`, `src/`, `package.json`).
