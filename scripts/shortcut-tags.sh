#!/usr/bin/env bash

# Verify that the only required argument has been provided
VERSION=$1
if [[ -z "${VERSION}" ]]; then
  >&2 printf "\nPass VERSION to suggest tags from, as the first argument. Ex:\n"
  >&2 printf "\t./%s  %s\n\n"   "$(basename "$0")"  "v1.0.1"
  exit 1
fi

SEMVER_REGEX="^[vV]?(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

# Verify that provided version conforms to SemVer pattern
if ! [[ "${VERSION}" =~ ${SEMVER_REGEX} ]]; then
  >&2 printf "\n\tERR: Not a valid SemVer tag provided. Aborting.\n\n"
  exit 1
fi

# Verify that provided tag doesn't exist already
if git tag | grep -q "^${VERSION}$"; then
  >&2 printf "\n\tERR: Tag already exists - human intervention needed :)\n\n"
  exit 1
fi

# Print a warning about found non-SemVer version, and list them
NON_SEMVER=$(git tag | grep -Ev "${SEMVER_REGEX}")
if [[ -n "${NON_SEMVER}" ]]; then
  >&2 printf "\n\tWARNING: The following tags are ignored, for not being SemVer compilant:\n"
  >&2 printf "\n%s\n\n" "${NON_SEMVER//$'\n'/,  }"
fi

# A convenience function that filter's out non-SemVer tags, sorts them correctly (newest first),
#   and optionally includes provided tag onto the list.
sorted_tags() {
  printf "%s\n%s\n" "$1" "$(git tag | grep -E "${SEMVER_REGEX}")"  | tr - \~ | sort -Vr | tr \~ -
}

# Start an array for possible positive matches
TAGS=()

# See where the provided version ranks in the global order.  Suggest "latest" if it ranks as the newest.
NUMBER_IN_TOTAL_ORDER=$(sorted_tags "${VERSION}" | grep -nm1 "^${VERSION}$" | cut -d: -f1)
if [[ ${NUMBER_IN_TOTAL_ORDER} -eq "1" ]]; then
  TAGS+=("latest")
fi

# See where it ranks among tags with the same MAJOR version.  Suggest ex. `v5`, if ranks the highest in the group.
MAJOR="$(echo "${VERSION}" | cut -d. -f-1)"
NUMBER_IN_MAJOR_ORDER=$(sorted_tags "${VERSION}" | grep "^${MAJOR}" | grep -nm1 "^${VERSION}$" | cut -d: -f1)
if [[ ${NUMBER_IN_MAJOR_ORDER} -eq "1" ]]; then
  TAGS+=("${MAJOR}")
fi

# See where it ranks among tags with the same MINOR version.  Suggest ex. `v4.2`, if ranks the highest in the group.
MINOR="$(echo "${VERSION}" | cut -d. -f-2)"
NUMBER_IN_MINOR_ORDER=$(sorted_tags "${VERSION}" | grep "^${MINOR}" | grep -nm1 "^${VERSION}$" | cut -d: -f1)
if [[ ${NUMBER_IN_MINOR_ORDER} -eq "1" ]]; then
  TAGS+=("${MINOR}")
fi

# Finally, and for completeness, add the original tag, and return the result.  Duplicate check has already run before.
# shellcheck disable=SC2145
echo "${TAGS[@]} ${VERSION}" | tr ' ' '\n'
