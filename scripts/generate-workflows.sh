#!/usr/bin/env bash

# This is a temporary measure for until Github doesn't support either:
#   * referencing jobs in a different file, or
#   * adding conditions to entire jobs (as opposed to only workflow, or step granularity, that exists now)

#
# IMPORTANT: All templates to be inserted need to have correct indentation!
#
SED="sed"

# On MacOS `sed` is a bit _sad_, that's why `gsed` is used instead.
if [[ -n $(command -v gsed) ]]; then
  SED="gsed"
fi

for template in ./.github/templates/[^_]* ; do
  file=$(basename "${template}")

  cp -f "${template}" .github/workflows/

  for placeholder in $(grep -o  '{{.*}}'  "${template}" | tr -d '{ }'); do
    ${SED} -i -e "/{{ ${placeholder} }}/r .github/templates/${placeholder}"  -e "//d"  ".github/workflows/${file}"
  done
done
