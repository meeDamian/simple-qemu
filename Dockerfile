# This Dockerfile builds `qemu` from source, and then offers 3 alternative `--target`s for packaging:
#   1. `enable`         - contains no `qemu` binaries, only the enable script
#   2. `single`         - contains a single `qemu` binary (for emulation of a single architecture), and the enable script
#   3. `comprehensive`  - contains all built `qemu` binaries as well as the enable script

ARG VERSION=v3.1.1


FROM debian:buster-slim AS builder

ARG VERSION

# Install deps
RUN apt-get update && \
    apt-get -y install gpg git python gcc make pkg-config libglib2.0-dev zlib1g-dev libpixman-1-dev flex bison

ENV KEYS E1A5C593CD419DE28E8315CF3C2525ED14360CDE \
         CEACC9E15534EBABB82D3FA03353C9CEF108B584 \
         16ACFD5FBD34880E584ECD2975E9CA927C18C076 \
         8695A8BFD3F97CDAAC35775A9CA4ABB381AB73C8

# Try to fetch key from keyservers listed below.  On first success terminate with `exit 0`.  If loop is not interrupted,
#   it means all attempts failed, and `exit 1` is called.
RUN for srv in  keyserver.ubuntu.com  hkp://p80.pool.sks-keyservers.net:80  ha.pool.sks-keyservers.net  keyserver.pgp.com  pgp.mit.edu; do \
        timeout 9s  gpg  --keyserver "$srv"  --recv-keys $KEYS  >/dev/null 2<&1 && \
            { echo "OK:  $srv" && exit 0; } || \
            { echo "ERR: $srv fail=$?"; } ; \
    done && exit 1

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
#   Note: put it as far down as possible, so that stuff above doesn't get invalidated when this file changes
COPY built-architectures.txt /

# Remove all comments, new lines, etc from the file.  Only leave the essence.
RUN sed -i  -e 's/\s*#.*$//'  -e '/^\s*$/d'  /built-architectures.txt

RUN echo "Target architectures to be built: $(cat /built-architectures.txt | tr '\n' ' ')"

# Configure output binaries to rely on no external dependencies (static), and only build for specified architectures
RUN ./configure  --static  --target-list=$(cat /built-architectures.txt | xargs -I{} echo "{}-linux-user" | tr '\n' ',' | head -c-1)

# Do the compiling thing
RUN make -j$(($(nproc) + 1))

RUN mkdir /binaries/

RUN for arch in $(cat /built-architectures.txt); do \
        cp  "/qemu/$arch-linux-user/qemu-$arch"  "/binaries/qemu-$arch-static"; \
    done

# Print sizes before stripping
RUN du -sh /binaries/*

RUN strip /binaries/*

# Print sizes after stripping
RUN du -sh /binaries/*



#
## What follows is 3 Dockerfile stages/targets used to build different final Docker images
#

#
## 1. This image has no `qemu` binaries in it.  It can be used to register/enable qemu on the host system, as well as
#   allows for interactions with qemu-provided `qemu-binfmt-conf.sh` script
#   See more: https://github.com/qemu/qemu/blob/v4.2.0/scripts/qemu-binfmt-conf.sh#L172-L215
FROM busybox:1.31 AS enable

LABEL maintainer="Damian Mee (@meeDamian)"

# Copy-in the `enable.sh` script
COPY enable.sh /usr/bin/enable-qemu

# Verify that copied `enable` script is what's expected
RUN echo "94f44d6db8057ec67d825b5f34114d5574070fcdbcbde10f2ece515c85581504  /usr/bin/enable-qemu" | sha256sum -c -

# Copy-in the qemu-provided `binfmt` script
COPY  --from=builder /qemu/scripts/qemu-binfmt-conf.sh  /usr/bin/

# Make sure both are executable
RUN chmod +x  /usr/bin/qemu-binfmt-conf.sh  /usr/bin/enable-qemu

ENTRYPOINT ["enable-qemu"]



#
## 2. This image contains a single-architecture `qemu` binary, as well as all scripts necessary for set it up
#
FROM enable AS single

# Capture `ARCH` that has to be passed to container via `--build-arg`.
ARG ARCH

# Make sure that exactly one architecture is provided to ARCH=
RUN test ! -z "$ARCH" || (printf '\nSingle target architecture (ARCH) has to be provided\n\tex: docker build --build-arg="ARCH=arm-linux-user" … .\n\n' && exit 1)

# Copy the qemu binary for the selected architecture to the
COPY  --from=builder /binaries/qemu-$ARCH-static  /usr/bin/



#
## 3. This image bundles-in all just built `qemu` binaries, and scripts necessary for set it up
#
FROM enable AS comprehensive

# Copy, and bundle together all built qemu binaries
COPY  --from=builder /binaries/qemu-*-static  /usr/bin/
