#!/bin/sh -e

#
## Given version, list of versions, or 'all', this script creates & pushes a relevant git-tag.
#

NAME="$(basename "$0")"

say()     { printf %b  "$*" >&2 ;}
log()     { say        "$*\n"   ;}
pad()     { say    "    $*"     ;}
arr()     { pad     "-> $*"     ;}
log_tab() { log      "\t$*"     ;}
err()     { log "\nERR: $*"     ;}
ok()      { log "OK${1:+: $1}"  ;}

if [ "$#" = '0' ]; then
	err "Required VERSION missing, ex: v5.0.0\n"
	log "Usage: $NAME all"
	log "       $NAME VERSION ...\n"
	exit 1
fi

if [ "$#" = '1' ] && [ "$1" != 'all' ] && ! grep -q "^ARG VERSION=v${1#v}" ./Dockerfile; then
	err 'Requested VERSION not present in Dockerfile.'
	log_tab "need: ARG VERSION=$1"
	log_tab "have: $(grep -Eo '^ARG VERSION=[^ ]+' ./Dockerfile)\n"
	exit 1
fi

# Verify there's no uncommitted changes
if ! git diff-files --quiet; then
	err 'Working directory not clean. Commit or stash to continue.\n'
	git status -s >&2
	log
	exit 1
fi

# Update git-tags from the remote
say 'Updating git-tag list... '
git fetch --tags
ok

list="$*"
if [ "$1" = 'all' ]; then
	list=$(git tag | sed -E 's|(v[^+]*).*|\1|p' | sort -Vu | tr '\n' ' ')
fi

log 'Starting release of:'
log_tab "$list\n"

sleep 5

for version in $list; do
	version="v${version#v}"
	log "Release of $version..."

	# Get last build number used for $version
	LAST="$(git tag | sed -n "s|^$version+build||p" | sort -rn | head -n 1)"

	# Increment it
	LAST="$((LAST+1))"

	# Construct the full $TAG, ex: `v0.7.7+build666`
	TAG="$version+build$LAST"
	arr "$TAG\n"

	arr 'Creating... '
	git tag -sa "$TAG" -m "$TAG"
	ok

	arr "Pushing...\n"
	git push origin "$TAG"
	pad 'OK\n\n'

	sleep 1
done

ok "All done"
