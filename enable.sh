#!/bin/sh

set -e

# Make sure emulation support (binfmt_misc) is available in the kernel
if [ ! -d /proc/sys/fs/binfmt_misc ]; then
    echo "No binfmt support in the kernel."
    echo "  Try: '/sbin/modprobe binfmt_misc' from the host"
    exit 1
fi

# Make sure it's mounted
if [ ! -f /proc/sys/fs/binfmt_misc/register ]; then
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
fi

# If `--reset` is provided, then find all `qemu-*` binaries present in the system, and disable them.
#   A command to disable a single qemu architecture (ex. `qemu-arm-static`) would be:
#     echo -1 > /proc/sys/fs/binfmt_misc/qemu-arm-static
#
if [ "${1}" = "--reset" ]; then
    find /proc/sys/fs/binfmt_misc -type f -name 'qemu-*' -exec sh -c 'echo -1 > {}' \;

    # Removes `--reset` from the list of arguments passed to this script (`$@`)
    shift
fi

# Register all qemu binaries with a suffix of `-static`, and consume any remaining params passed to the script
exec /usr/bin/qemu-binfmt-conf.sh --qemu-suffix "-static" --qemu-path /usr/bin/  "$@"
