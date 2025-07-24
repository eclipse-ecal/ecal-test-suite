#!/bin/bash

TAG_PREFIX="$1"

if [ -z "$TAG_PREFIX" ]; then
  echo "[ERROR] Usage: $0 <tag_prefix>"
  exit 1
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="${SCRIPT_DIR}/.."
DOCKERFILE_DIR="${CASE_DIR}/docker"
CONTEXT_DIR="${CASE_DIR}"

build_image() {
  TAG=$1
  echo "[INFO] Building image: ${TAG}"
  docker build -t "${TAG}" -f "${DOCKERFILE_DIR}/Dockerfile" "${BASE_DIR}"
  if [ $? -ne 0 ]; then
    echo "[ERROR] Build failed for ${TAG}!"
    exit 1
  fi
}

build_image "${TAG_PREFIX}_network_udp"

echo "[✓] All images built successfully!"
