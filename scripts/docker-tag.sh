#!/usr/bin/env bash

# No validation.  YOLO.
SLUG=$1
TAG=$2


# Run a simple tag-recommending heuristic
SUGGESTED_TAGS=$(./scripts/shortcut-tags.sh "${TAG}")

# For each individual type of image
for image_type in $(docker images "${SLUG}" --format "{{.Tag}}"); do

  # All-in images are tagged with version alone, so can be handle, and done here already
  if [[ "${image_type}" == "${TAG}" ]]; then
    echo "${SUGGESTED_TAGS}" | xargs -I %  docker tag  "${SLUG}:${image_type}"  "${SLUG}:%"
    continue
  fi

  # For each image_type, go through all suggestions, and…
  for partial_version in ${SUGGESTED_TAGS}; do
    # skip `latest` prefix, as plain `:arm` is simple, and clear enough compared to `:latest-arm`
    if [[ "${partial_version}" == "latest" ]]; then
      continue
    fi

    # If was suggested by he script earlier, tags like: `:v1-aarch64`, or `:v5.0-arm` are created here
    docker tag  "${SLUG}:${image_type}"  "${SLUG}:${partial_version}-${image_type}"
  done

  # Create a tag with a full version, and exact qemu architecture
  docker tag  "${SLUG}:${image_type}"  "${SLUG}:${TAG}-${image_type}"
done
