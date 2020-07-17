#!/bin/sh -e

cd stats/

# Get only slowest, and fastest durations for each arch
min32max="$(sort -n -- *32*duration | awk 'NR==1; END{print}')"
min64max="$(sort -n -- *64*duration | awk 'NR==1; END{print}')"

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

# shellcheck disable=SC2086
single() { sort -u -- $1 | head -n1; }

version_apt="$(   single    'apt-*-qemu-version')"
version_slim="$(  single   'slim-*-qemu-version')"
version_master="$(single 'master-*-qemu-version')"
commit_master="$( single 'master-*-qemu-commit' )"
commit_slim="$(   single   'slim-*-qemu-commit' )"
commit_app="$(    single        "*-$APP-commit" )"

commit_app_short="$(echo "$commit_app" | cut -c-7)"

ver()   { printf '%-24s' "**v${1#v}**${2:+/$2}" ;}
dur32() { duration "$1-arm32v7" "$min32max"     ;}
dur64() { duration "$1-arm64v8" "$min64max"     ;}

apt="$(ver "$version_apt" "apt-get")"
slim="$(ver "$version_slim" "[slim]")"
master="$(ver "$version_master" "[master]")"
versions="$(find -- * -name 'v*duration' | cut -d- -f1 | uniq | tac)"

cat <<EOF | tee all-stats
### Perf check ($APP)

Source: [\`$REPO:$commit_app_short\`][app]
Trigger: \`${GITHUB_EVENT_NAME:-unknown}\`
Baseline: **$(duration baseline)** (no emulation)

| qemu version             |           arm32v7 |           arm64v8
|-------------------------:|:-----------------:|:-----------------:
| $apt | $(dur32 apt) | $(dur64 apt)
| $master | $(dur32 master) | $(dur64 master)
| $slim | $(dur32 slim) | $(dur64 slim)
$(for v in $versions; do
	echo "| $(ver "$v") | $(dur32 "$v") | $(dur64 "$v")"
done)

[app]: https://github.com/$REPO/tree/$commit_app
[master]: https://github.com/$QEMU/tree/$commit_master
[slim]: https://github.com/$QEMU/tree/$commit_slim
EOF
