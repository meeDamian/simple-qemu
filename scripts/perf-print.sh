#!/bin/sh -e

cd stats/

# Get only slowest, and fastest durations for each arch
bound32="$(sort -n -- *32*duration | awk 'NR==1; END{print}')"
bound64="$(sort -n -- *64*duration | awk 'NR==1; END{print}')"

duration() {
	if ! diff="$(cat "$1-duration")" || echo "$diff" | grep -vq '^[0-9]*$' ; then
		echo "${diff:--}"; return
	fi

	secs=$((   diff                  % 60))
	mins=$(($((diff / 60          )) % 60))
	hrs=$(( $((diff / 60 / 60     )) % 24))
	days=$((   diff / 60 / 60 / 24))

	[ "$days" = '0' ] && days=
	[ "$hrs"  = '0' ] && hrs=

	dur="$(printf '%s%s%02dm:%02ds' "$days${days:+d }" "$hrs${hrs:+h:}" "$mins" "$secs")"
	dur="${dur#0}"

	if [ -n "$2" ]; then
		if echo "$2" | grep -q "^$diff$"; then
			dur="**$dur**"
		fi

		dur="$(printf '%17s' "$dur")"
	fi

	echo "$dur"
}

ver()   { printf '%-24s' "**v${1#v}**"     ;}
dur32() { duration "$1-arm32v7" "$bound32" ;}
dur64() { duration "$1-arm64v8" "$bound64" ;}


commit="$(sort -u -- *-commit | head -n1)"

ver_os="$(grep -oE '(\.?[0-9]*){3}' os-qemu | head -n1)/apt-get"
ver_git="$(sed -nE 's|^ARG VERSION=(.*)$|\1|p' ../Dockerfile)/[master][src]"
versions="$(find -- * -name 'v*duration' | cut -d- -f1 | uniq)"

cat <<EOF | tee all-stats
### Perf check ($APP)

Source: [\`$REPO:$(echo "$commit" | cut -c-7)\`][src]
Trigger: \`${GITHUB_EVENT_NAME:-unknown}\`
Baseline: **$(duration metal)** (no emulation)

| qemu version             |           arm32v7 |           arm64v8
|-------------------------:|:-----------------:|:-----------------:
| $(ver "$ver_os"        ) | $(dur32 os      ) | $(dur64 os)
| $(ver "$ver_git"       ) | $(dur32 master  ) | $(dur64 master)
$(for v in $versions; do
echo "| $(ver "$v") | $(dur32 "$v") | $(dur64 "$v")"
done)

[src]: https://github.com/$REPO/tree/$commit
EOF
