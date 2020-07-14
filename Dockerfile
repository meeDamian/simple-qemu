# This Dockerfile builds `qemu` from source, and offers 3 alternative variants (`--target`s):
#   1. `enable`         - `qemu-enable` script alone (useful with own qemu binaries)
#   2. `single`         - A single `qemu` binary (can emulate one CPU-arch only)
#   3. `comprehensive`  - Contains `qemu` binaries for all built architectures

ARG VERSION=v5.0.0


FROM debian:buster-slim AS builder

ARG VERSION

RUN apt-get update && \
    apt-get -y install gpg git python gcc make pkg-config libglib2.0-dev zlib1g-dev libpixman-1-dev flex bison

ENV KEYS E1A5C593CD419DE28E8315CF3C2525ED14360CDE \
         CEACC9E15534EBABB82D3FA03353C9CEF108B584 \
         16ACFD5FBD34880E584ECD2975E9CA927C18C076 \
         8695A8BFD3F97CDAAC35775A9CA4ABB381AB73C8

RUN timeout 16s  gpg  --keyserver keyserver.ubuntu.com  --recv-keys $KEYS

# Print imported keys, but also ensure there's no other keys in the system
RUN gpg --list-keys | tail -n +3 | tee /tmp/keys.txt && \
    gpg --list-keys $KEYS | diff - /tmp/keys.txt

# Fetch a minimal source clone of the specified qemu version
#   Note: using the official repo for source pull, but mirror is available on github too: github.com/qemu/qemu
#   For future reference, this is qemu download index: https://download.qemu.org/
RUN git clone  -b "$VERSION"  --depth=1  https://git.qemu.org/git/qemu.git

# All building happens in this directory
WORKDIR /qemu/

# Verify that pulled release has been signed by any of the keys imported above
RUN git verify-tag "$VERSION"

# Copy the list of all architectures we want to build into the container
COPY built-architectures.txt /
# Remove all comments, new lines, etc from the file.  Leave the essence only.
RUN sed -i  -e 's/\s*#.*$//'  -e '/^\s*$/d'  /built-architectures.txt
RUN printf 'Target architectures to be built: %s\n' "$(cat /built-architectures.txt | tr '\n' ' ')"

# Configure output binaries to be static (no external deps), and only build what's listed in `/built-architectures.txt`
RUN ./configure --static \
        --target-list=$(cat /built-architectures.txt \
            | xargs -I% echo "%-linux-user" \
            | tr '\n' ',' \
            | head -c-1)

# Do the compiling thing
RUN make -j$(($(nproc) + 1))

RUN mkdir /binaries/
WORKDIR   /binaries/

RUN for arch in $(cat /built-architectures.txt); do \
        cp "/qemu/$arch-linux-user/qemu-$arch" "qemu-$arch-static"; \
    done

# Strip and print size before & after
RUN du -sh *
RUN strip  *
RUN du -sh *

# Copy-in, and verify the `enable.sh` script
COPY enable.sh qemu-enable
RUN echo "cde32e4bd50b71bf79a90ed32d4a19e9ec908d404c308c33ed799138e7c7fd27  qemu-enable" | sha256sum -c -
RUN sed -Ei "s|^(VERSION)=|\1=$VERSION|" qemu-enable
RUN chmod +x qemu-enable

# Copy, verify, and apply patch on qemu-provided script
#   original file: https://github.com/qemu/qemu/blob/master/scripts/qemu-binfmt-conf.sh
WORKDIR /qemu/scripts/
ENV BINFMT qemu-binfmt-conf.sh
COPY $BINFMT.patch .
RUN echo "71490acd7e73ea0f82f050a34794eb53c72de4ee7c1023e6bd7450e36f0ddfdd  $BINFMT.patch" | sha256sum -c -
RUN patch "$BINFMT" "$BINFMT.patch"
RUN chmod +x "$BINFMT"


#
## What follows is 3 Dockerfile stages/targets used to build different final Docker images
#

#
## 1. First image has no `qemu` binaries in it.  It can be used to register/enable qemu on the host system, as well as
#   allows for interactions with qemu-provided `qemu-binfmt-conf.sh` script
#   See more: https://github.com/qemu/qemu/blob/v4.2.0/scripts/qemu-binfmt-conf.sh#L172-L215
FROM busybox:1.32 AS enable
LABEL maintainer="Damian Mee (@meeDamian)"
WORKDIR /usr/local/bin/

# Copy-in necessary scripts
COPY --from=builder /qemu/scripts/qemu-binfmt-conf.sh /binaries/qemu-enable  ./

ENTRYPOINT ["/usr/local/bin/qemu-enable"]


#
## 2. This image contains a single-architecture `qemu` binary, as well as all scripts necessary for set it up
#
FROM enable AS single
ARG ARCH
RUN test -n "$ARCH" || { echo "ARCH not provided as build-arg"; exit 1 ;}
COPY --from=builder /binaries/qemu-${ARCH}-static .


#
## 3. This image bundles-in all just built `qemu` binaries, and scripts necessary for set it up
#
FROM enable AS comprehensive
COPY --from=builder /binaries/qemu-*-static .
