#!/usr/bin/env bash

set -eo pipefail

VERSION=$1
ONLY_MASTER=$2

if [[ -z "$1" ]]; then
  >&2 printf "\nVersion to be built needs to be provided to this script as first argument\n\n"
  exit 1
fi

if ! git diff-index --quiet HEAD; then
  >&2 printf "\nWorking directory has to be clean, currently it isn't:\n%s\n\n" "$(git status --porcelain)"
  exit 1
fi

echo "${VERSION}" > ./QEMU_VERSION
git add ./QEMU_VERSION

./scripts/generate-workflows.sh
git add ./.github/workflows

git commit -m "Trigger build of ${VERSION}"
git push origin master


if [[ "${ONLY_MASTER}" == "true" ]]; then
  exit 0
fi

git tag -sa "${VERSION}" -m "${VERSION}"
git push origin "${VERSION}"
