meedamian/simple-qemu
=====================

![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/meeDamian/simple-qemu) ![](https://github.com/meeDamian/simple-qemu/workflows/Build%20%26%20deploy%20qemu%20on%20a%20git%20tag%20push/badge.svg)

This project aims to make cross-compilation, and running programs compiled for a different CPU architecture _simple_.

Currently the only **host** architecture supported is `amd64` (AKA `x86_64`), and architectures that can be emulated are:

1. `arm` (AKA `arm32v7`)
1. `aarch64` (AKA `arm64v8`, `arm64`)
1. `riscv32`
1. `riscv64`


Simple tags
-----------

* `v4.1.0`, `v4.1`, `v4`, `latest`
* `v4.1.0-arm`, `v4.1.0-arm32v7`, `v4.1-arm`, `v4.1-arm32v7`, `v4-arm`, `v4-arm32v7`, `arm`, `arm32v7`
* `v4.1.0-aarch64`, `v4.1.0-arm64v8`, `v4.1-aarch64`, `v4.1-arm64v8`, `v4-aarch64`, `v4-arm364v8`, `aarch64`, `arm64v8`
* `v4.1.0-riscv32`, `v4.1-riscv32`, `v4-riscv32`, `riscv32`
* `v4.1.0-riscv64`, `v4.1-riscv64`, `v4-riscv64`, `riscv64`
* `v4.1.0-enable`, `v4.1-enable`, `v4-enable`, `enable`

* `v4.0.0`, `v4.0`
* `v4.0.0-arm`, `v4.0.0-arm32v7`, `v4.0-arm`, `v4.0-arm32v7`
* `v4.0.0-aarch64`, `v4.0.0-arm64v8`, `v4.0-aarch64`, `v4.0-arm64v8`
* `v4.0.0-riscv32`, `v4.0-riscv32`
* `v4.0.0-riscv64`, `v4.0-riscv64`
* `v4.0.0-enable`, `v4.0-enable`

* `v3.1.1`, `v3.1`, `v3`
* `v3.1.1-arm`, `v3.1.1-arm32v7`, `v3.1-arm`, `v3.1-arm32v7`, `v3-arm`, `v3-arm32v7`
* `v3.1.1-aarch64`, `v3.1.1-arm64v8`, `v3.1-aarch64`, `v3.1-arm64v8`, `v3-aarch64`, `v3-arm64v8`
* `v3.1.1-riscv32`, `v3.1-riscv32`, `v3-riscv32`
* `v3.1.1-riscv64`, `v3.1-riscv64`, `v3-riscv64`
* `v3.1.1-enable`, `v3.1-enable`, `v3-enable`

* `v3.1.0`
* `v3.1.0-arm`, `v3.1.0-arm32v7`
* `v3.1.0-aarch64`, `v3.1.0-arm64v8`
* `v3.1.0-riscv32`
* `v3.1.0-riscv64`
* `v3.1.0-enable`


### Image categories

There are 3 distinct categories of images above:

1. An image that contains binaries for [all architectures].  Tagged with a version alone, ex: `:v4.1.0`, or `:latest`.
1. An enable-emulation only image.  It contains no `qemu` binaries, but can be used to enable emulation for use with your own `qemu` binary.  Tagged with the keyword `enable`, ex: `:v4.1.0-enable`, or `:enable`.
1. A single-architecture image.  These images contain only a single architecture and emulation enable script.  Tagged with the name of the architecture, ex: `v4.1.0-arm`, or `aarch64`.

[all architectures]: ./built-architectures.txt


Usage
=====

The simplest way to run an image built for a different architecture is to run:

```shell script
# Enable emulation on the host system
docker run --rm --privileged meedamian/simple-qemu -p yes
 
# Verify it worked
docker run --rm arm32v7/alpine uname -m
```

If you want to emulate build on your amd64 machine, then:

```shell script
# Enable emulation on the host system
docker run --rm --privileged meedamian/simple-qemu -p yes
```

And then in your `Dockerfile` specify exact base architecture, you want to use:

```Dockerfile
FROM arm32v7/alpine:3.10

# Everything written here will be run on an emulated architecture
```

It's that _simple_ :).

> **Note:** To learn what architectures are available for the given base image you can use `docker manifest inspect` command, for example:
>
> ```shell script
> $ docker manifest inspect alpine | jq -r '.manifests[].platform | .os + "/" + .architecture + " " +.variant'
> linux/amd64
> linux/arm v6
> linux/arm v7
> linux/arm64 v8
> linux/386
> linux/ppc64le
> linux/s390x
>```

## Bugs and feedback

If you discover a bug please report it [here](https://github.com/meeDamian/simple-qemu/issues/new).  Express gratitude [here](https://donate.meedamian.com).

Mail me at bugs@meedamian.com, or on twitter [@meeDamian](http://twitter.com/meedamian).


## License

MIT @ [Damian Mee](https://meedamian.com)
