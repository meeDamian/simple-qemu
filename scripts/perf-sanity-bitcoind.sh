#!/bin/sh -e

# shellcheck disable=SC2086
run() {
	ENTRYPOINT="${1:-$APP}"; shift
	ARGS=${*:-"--version"}

	printf '\n$ %s %s\n'  "$ENTRYPOINT"  "$ARGS" >&2
	docker run --rm  --entrypoint "$ENTRYPOINT"  "$APP"  $ARGS
}

run  uname -a
run  bitcoind
run  bitcoin-cli
run  bitcoin-tx --help | head -n 1

# If version higher, or equal than v0.18.0, also run `bitcoin-wallet` binary
if [ "${MINOR#0.}" -ge "18" ]; then
	run  bitcoin-wallet --help | head -n 1
fi
