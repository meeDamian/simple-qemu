FROM debian AS builder

RUN apt-get update

RUN apt-get -y install wget tar xz-utils python gcc make pkg-config libglib2.0-dev zlib1g-dev libpixman-1-dev

RUN wget -q https://download.qemu.org/qemu-4.1.0.tar.xz
RUN tar -xJf qemu-4.1.0.tar.xz

WORKDIR qemu-4.1.0/

RUN ./configure --static --target-list=arm-linux-user
RUN make

RUN cp arm-linux-user/qemu-arm  /usr/bin/qemu-arm-static



FROM arm32v6/alpine

COPY --from=builder /usr/bin/qemu-arm-static /usr/bin/

RUN ls
