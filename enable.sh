#!/bin/sh

set -e

VERSION= # set in Dockerfile during build
NAME="$(basename "$0")";
GH_URL=https://github.com/meeDamian/simple-qemu

show_version() { echo "$NAME ${VERSION:-unknown}"; }
show_help() {
  cat << EOF >&2
$(show_version)

Simplify binfmt_misc registrations with kernel.

Usage: $NAME [--reset] [binfmt flags]

  "binfmt_misc" (from 'MISCellaneous BINary ForMaTs') is a tool to "teach" kernel about custom
  binary formats: how to handle and where to pass matching binaries for execution/processing.
  In this script, "binfmt_misc" is used to request kernel to route execution of all binaries
  with matching (non-native CPU) signatures to appropriate 'qemu' binary for emulation.

Options:

  -h, --help, help      Show this help message
  -H, --help-binfmt     Show qemu-binfmt-conf.sh help
      --reset           De-register all binary formats registered for emulation before proceeding
  -v, --version         Show version, and exit

github: $GH_URL

EOF
}

BINFMT_SH=/usr/local/bin/qemu-binfmt-conf.sh

case "${1#--}" in
	-v|version)     show_version;        exit 0 ;;
	-h|help)        show_help;           exit 0 ;;
	-H|help-binfmt) "$BINFMT_SH" --help; exit 0 ;;
esac

# Exit, if [host's] kernel doesn't have support for `binfmt_misc`.
cd /proc/sys/fs/binfmt_misc/ 2>/dev/null || {
	>&2 echo "ERR: No binfmt_misc support in kernel. Try running [on host]:"
	>&2 echo "    /sbin/modprobe binfmt_misc"
	exit 1
}

# If `binfmt_misc` is disabled, try to enable.
if [ ! -f register ]; then
	mount binfmt_misc  -t binfmt_misc  "$(pwd)" || {
		>&2 echo "ERR: binfmt_misc support in kernel present, but not enabled"
		>&2 echo "    and enabling it failed."
		exit 1
	}

	# Change to just mounted location (previous has been mounted-over).
	cd "$(pwd)"
fi

# If `--reset` passed as 1st argument, disable all currently registered binary formats (starting with `qemu-`).
if [ "$1" = "--reset" ]; then
	shift  # Remove `--reset` flag from the list of passed arguments (`$@`)

	for format in qemu-*; do
		[ -e "$format" ] || continue            # Suppress err on empty `pwd`
		[ -f "$format" ] && echo -1 > "$format" # Sending '-1' to registered fmt, disables it
	done
fi

# Replace current shell with a call registering all available `qemu` binaries.
# shellcheck disable=SC2068
exec "$BINFMT_SH"  --qemu-suffix "-static"  $@
