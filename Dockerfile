FROM debian AS builder

RUN apt-get update
RUN apt-get -y install git python gcc make pkg-config libglib2.0-dev zlib1g-dev libpixman-1-dev

RUN git clone  -b v4.1.0  https://github.com/qemu/qemu.git

WORKDIR qemu/

RUN ./configure --static --target-list=arm-linux-user
RUN make

RUN cp arm-linux-user/qemu-arm /qemu-arm-static
RUN cp scripts/qemu-binfmt-conf.sh /qemu-binfmt-conf.sh

COPY register.sh /register.sh

RUN chmod +x /qemu-binfmt-conf.sh /register.sh

RUN /register.sh

FROM arm32v6/alpine

COPY --from=builder /usr/bin/qemu-arm-static /usr/bin/

RUN ls
