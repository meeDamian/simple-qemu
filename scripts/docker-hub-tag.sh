#!/usr/bin/env bash

set -eo pipefail

# The source tag of images.  This will be used as the base of the first argument to `docker tag`.
BASE_TAG=$1

# The destination tag of the image.  This will be used as the base of the second argument to `docker tag`.
SLUG=$2

# The version-tag currently being added, ex `v4.1.0`.
TAG=$3

# All possible image variants as a space-separated string.  Aliases are accepted in a form of: `name:alias`.
#   Example string: `"enable arm:arm32v6 aarch64:arm64 riscv64"`
VARIANTS=$4

# This function creates requested Docker Tags, or just prints the commands if `DRY_RUN=1` is set.
tag() {
  CMD="docker tag  ${BASE_TAG}:$1  ${SLUG}:$2"
  if [[ -n "${DRY_RUN}" ]]; then
    echo "${CMD}"
    return 0
  fi

  ${CMD}
}

# Get short-tag recommendations based on `git tag` output.
SUGGESTED_TAGS=$(./scripts/shortcut-tags.sh "${TAG}")

# Always tag the all-in image with it's own specific version.
tag "${TAG}" "${TAG}"

# Attach our specific ${TAG} to the suggested tags.
for suggestion in ${TAG} ${SUGGESTED_TAGS}; do

  # If it's the latest version, tag the all-in image as such.
  if [[ ${suggestion} == "latest" ]]; then
    tag "${TAG}" "latest"
  fi

  # Cross match each suggested version with a possible variant
  for variant in ${VARIANTS}; do
    variant_base=$(echo "${variant}" | cut -d: -f1)

    # Variants can be provided with aliases, ex: `arm:arm32v7`.  This loops takes care of that.
    for alias in $(echo "${variant}" | tr ':' ' '); do

      # If it's the latest version, tag each variant with a plain tag, ex: `:arm32v7`, or `:aarch64`.
      if [[ "${suggestion}" == "latest" ]]; then
        tag "${variant_base}" "${alias}"
        continue
      fi

      # For a shortened version, just prepend it to the variant name, ex: `:v4.1-arm`
      tag "${variant_base}" "${suggestion}-${alias}"
    done
  done
done
