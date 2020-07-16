#!/bin/sh -e

cd stats/

# Get only slowest, and fastest durations for each arch
bound32="$(sort -n -- *32*duration | awk 'NR==1; END{print}')"
bound64="$(sort -n -- *64*duration | awk 'NR==1; END{print}')"

duration() {
	if ! diff="$(cat "$1-duration")" || [ -n "${diff##*[!0-9]*}" ]; then
		echo "$diff"; return
	fi

	BB=
	if echo "$2" | grep -q "$diff"; then
		BB='**'
	fi

	secs=$((   diff                  % 60))
	mins=$(($((diff / 60          )) % 60))
	hrs=$(( $((diff / 60 / 60     )) % 24))
	days=$((   diff / 60 / 60 / 24))

	[ "$days" = '0' ] && days=
	[ "$hrs"  = '0' ] && hrs=

	dur="$(printf '%s%s%02dm:%02ds' "$days${days:+d }" "$hrs${hrs:+h:}" "$mins" "$secs")"
	echo "$BB${dur#0}$BB"
}
version() {
	case "$1" in
	master) ver="$(sed  -nE 's|^ARG VERSION=(.*)$|\1|p' Dockerfile)/git" ;;
	os)     ver="$(grep -oE '(\.?[0-9]*){3}' os-qemu | head -n1)/os"     ;;
	*)      ver="$1" ;;
	esac

	echo "v${ver#v}"
}

line() { printf '|%-17s|%12s|%12s\n' "$1" "$2" "$3" ;}
row()  { line " ${1:--} " " ${2:--} " " ${3:--} "   ;}
result() {
	row "**$(version "$1")**" \
		"$(duration "$1-arm32v7" "$bound32")" \
		"$(duration "$1-arm64v8" "$bound64")"
}

# shellcheck disable=SC2016
(
	commit="$(sort -u -- *-commit | head -n1)"

	printf '### Perf check (%s)\n\n' "$APP"
	printf 'Source: [`%s@%s`](https://github.com/%s/tree/%s)\n' "$REPO" "$(echo "$commit" | cut -c-7)" "$REPO" "$commit"
	printf 'Trigger: `%s`\n' "${{ github.event_name }}"
	printf 'Baseline: **%s** (no emulation)\n\n' "$(duration metal)"

	row    qemu  arm32v7  arm64v8
	line   ----  ------:  ------: | tr ' ' -

	result os
	result master
	for ver in $(find -- * -name 'v*duration' | cut -d- -f1 | uniq); do
		result "${ver%%-*}"
	done

	echo
) | tee all-stats

echo ::set-env name=RESULTS::"$(sed -z 's/\n/\\n/g' all-stats)"
