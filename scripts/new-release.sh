#!/usr/bin/env sh

set -e

#
## Given version, this script creates & pushes a relevant git-tag.
#

# required version
VERSION=$1

# Make sure $VERSION is provided before proceeding
if [ -z "$VERSION" ]; then
  >&2 printf "\nERR: version missing:  version needs to be passed as the first argument.  Try:\n"
  >&2 printf "\t./%s  %s\n\n"   "$(basename "$0")"  "v4.2.0"
  exit 1
fi

# Verify there's no uncommitted changes
if ! git diff-files --quiet; then
  >&2 printf "\nERR: working directory not clean.  Commit, or stash changes to continue.\n\n"
  exit 1
fi

# Make sure specified $VERSION is present in Dockerfile
if ! grep -q "$VERSION" ./Dockerfile; then
  >&2 printf "\nERR: Requested version not present in Dockerfile. Make sure that's what you want to do.\n\n"
  exit 1
fi

# Update git-tags from the remote
git fetch --tags

# Get last build number used for $VERSION
LAST=$(git tag | sed -n "s|^$VERSION+build||p" | sort -rn | head -n 1)

# Increment it
LAST=$((LAST+1))

# Construct the full $TAG, ex: `v0.7.7+build666`
TAG="$VERSION+build$LAST"

printf "Creating tag: %s…\t" "$TAG"
git tag -sa "$TAG" -m "$TAG"
echo "done"

printf "Pushing tag: %s…\t" "$TAG"
git push origin "$TAG"
echo "All done"
