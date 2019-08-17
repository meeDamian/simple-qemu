FROM meedamian/simple-qemu-test:latest AS builder

#RUN apt-get update
#RUN apt-get -y install git python gcc make pkg-config libglib2.0-dev zlib1g-dev libpixman-1-dev
#
#RUN git clone  -b v4.1.0  https://github.com/qemu/qemu.git
#
#WORKDIR qemu/
#
#RUN ./configure --static --target-list=arm-linux-user
#RUN make
#
#RUN cp arm-linux-user/qemu-arm /qemu-arm-static
#RUN cp scripts/qemu-binfmt-conf.sh /qemu-binfmt-conf.sh
#
#COPY register.sh /register.sh
#
#RUN chmod +x /qemu-binfmt-conf.sh /register.sh


RUN /register.sh --debian

FROM arm32v6/alpine

COPY --from=builder /qemu-arm-static /usr/bin/
COPY --from=builder /qemu-binfmt-conf.sh /
COPY --from=builder /register.sh /

RUN /usr/bin/qemu-arm-static /register.sh
