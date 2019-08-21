FROM debian:10-slim AS builder

# Install deps
RUN apt-get update && \
    apt-get -y install gpg git python gcc make pkg-config libglib2.0-dev zlib1g-dev libpixman-1-dev flex bison && \
    rm -rf /var/lib/apt/lists/*

# Capture `QEMU_VERSION=` passed to `docker build` via `--build-arg`.
#   If version is not provided, exit - we don't want to build some random binary.
ARG QEMU_VERSION
RUN test ! -z "${QEMU_VERSION}"  || (printf "\nQemu version has to be provided\n\tex: docker build --build-arg QEMU_VERSION=v4.1.0 .\n\n" && exit 1)

# Import keys used to verify git tag later.  Used keys obtained using:
#   git tag | xargs -I{} git verify-tag {} 2>&1 | grep 'Primary key fingerprint' | cut -d: -f 2 | tr -d ' ' | sort | uniq -c | sort -rh
RUN set -ex \
  && for key in \
    E1A5C593CD419DE28E8315CF3C2525ED14360CDE \
    CEACC9E15534EBABB82D3FA03353C9CEF108B584 \
    16ACFD5FBD34880E584ECD2975E9CA927C18C076 \
    8695A8BFD3F97CDAAC35775A9CA4ABB381AB73C8 \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "${key}" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "${key}" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "${key}" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "${key}" ; \
  done

RUN gpg --list-keys

# Fetch a minimal source clone of the specified qemu version
#   Note: using the official repo for source pull, but mirror is available on github too: github.com/qemu/qemu
#   For future reference, this is qemu download index: https://download.qemu.org/
RUN git clone  -b ${QEMU_VERSION}  --depth=1  https://git.qemu.org/git/qemu.git

# All building happens in this directory
WORKDIR /qemu/

# Verify that pulled release has been signed by any of the keys imported above
RUN git verify-tag ${QEMU_VERSION}

# Copy the list of all architectures we want to build into the container
#   Note: put it as far down as possible, so that stuff above doesn't get invalidated everytime this file changes
COPY built-architectures.txt /

# Delete comments, spaces, and empty lines from the file
RUN grep -o '^[^#]*' /built-architectures.txt | awk NF | tr -d ' ' > /built-architectures.txt

# Configure output binaries to rely on no external dependencies (static), and only build for specified architectures
RUN ./configure  --static  --target-list=$(cat /built-architectures.txt | xargs -I{} echo "{}-linux-user" | tr '\n' ',' | head -c-1)

# make :)
RUN make

# Copy and rename all built qemu binaries to root `/`
RUN for arch in $(cat /built-architectures.txt); do \
        cp "/qemu/${arch}-linux-user/qemu-${arch}" "/qemu-${arch}-static"; \
    done

RUN ls -lh /qemu-*-static


## What follows here is 3 different Dockerfile stages used to build 3 different Docker images
#

## 1. This image has no `qemu` binaries embeded in it.  It can be used to register/enable qemu on the host system,
#   as well as allows for interactions with qemu provided `qemu-binfmt-conf.sh` script.
#   See more: https://github.com/qemu/qemu/blob/6894576347a71cdf7a1638650ccf3378cfa2a22d/scripts/qemu-binfmt-conf.sh#L168-L211
FROM busybox:1.31 AS enable

# Copy the `enable.sh` script to the image
COPY enable.sh /

# Copy the qemu-provided `binfmt` script to the image
COPY --from=builder  /qemu/scripts/qemu-binfmt-conf.sh /qemu-binfmt-conf.sh

# Make sure they're both executable
RUN chmod +x /qemu-binfmt-conf.sh /enable.sh

ENTRYPOINT ["/enable.sh"]


## 2. This image contains all `qemu` binaries that were supported by this repo at the time of tagging.
#   Note that it builds on top of stage #1, so everything done there is also available here.
FROM enable AS latest

# Copy, and bundle together all built qemu binaries
COPY --from=builder  /qemu-*-static  /

ENTRYPOINT ["/enable.sh"]


## 3. This image contains a single-architecture qemu binary, as well as all the necessary setup goodies
#   Note that it builds on top of stage #1, so everything done there is also available here.
FROM enable AS single

# Capture `ARCH` that has to be passed to container via `--build-arg`.
ARG ARCH

# Make sure that exactly one architecture is provided to ARCH=
RUN test ! -z "${ARCH}" || (printf "\nSingle target architecture (ARCH) has to be provided\n\tex: docker build --build-arg QEMU_VERSION=v4.1.0 --build-arg ARCH=arm-linux-user .\n\n" && exit 1)

# Copy the qemu binary for the selected architecture to the
COPY --from=builder  /qemu-${ARCH}-static  /

ENTRYPOINT ["/enable.sh"]



