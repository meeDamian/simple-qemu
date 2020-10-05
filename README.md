meedamian/simple-qemu
=====================

[![action_img]][action_url] [![lasttag_img]][lasttag_url] [![pulls_img]][hub] [![size_img]][hub]

[action_img]: https://github.com/meeDamian/simple-qemu/workflows/Check%20master%20or%20PR/badge.svg
[action_url]: https://github.com/meeDamian/simple-qemu/actions?query=workflow%3A%22Check+master+or+PR%22

[lasttag_url]: https://github.com/meedamian/simple-qemu/releases/latest
[lasttag_img]: https://badgen.net/github/tag/meedamian/simple-qemu

[size_img]: https://badgen.net/docker/size/meedamian/simple-qemu/arm64?icon=docker&label=size%20%28arm64%29
[pulls_img]: https://badgen.net/docker/pulls/meedamian/simple-qemu?icon=docker&label=pulls
[hub]: https://hub.docker.com/r/meedamian/simple-qemu

This project aims to make cross-compilation, and running programs and images built for a different CPU architecture _simple_.

Currently, the only **host** architecture supported is `amd64` (AKA `x86_64`), while the architectures that can be emulated are:

1. `i386` (AKA `x86`, `i686`)
1. `arm` (AKA `arm32v7`)
1. `aarch64` (AKA `arm64v8`, `arm64`)
1. `riscv32`
1. `riscv64`


### Image categories

There are 3 distinct categories of images below:

1. An image containing binaries for [all architectures].  Tagged with a version alone, ex: `:v5.0.0`, or `:latest`.
1. An enable-emulation-only image.  It contains no `qemu` binaries, but can be used to enable emulation for use with your own `qemu` binary.  Tagged with the keyword `enable`, ex: `:v5.0.0-enable`, or `:enable`.
1. A single-architecture image.  These images contain a single architecture plus a script to enable emulation.  Tagged with the name of the architecture, ex: `v5.0.0-arm`, or `aarch64`.

[all architectures]: ./built-architectures.txt



Simple tags
-----------

For a complete list of available tags see: [`r/meedamian/simple-qemu/tags`](https://hub.docker.com/r/meedamian/simple-qemu/tags)

### v5.1.0
* `v5.1.0`        , `v5.1`        , `v5`        , `latest`
* `v5.1.0-arm`    , `v5.1-arm`    , `v5-arm`    , `arm`     (or: `arm32v7`)
* `v5.1.0-aarch64`, `v5.1-aarch64`, `v5-aarch64`, `aarch64` (or: `arm64v8` & `arm64`)
* `v5.1.0-riscv32`, `v5.1-riscv32`, `v5-riscv32`, `riscv32`
* `v5.1.0-riscv64`, `v5.1-riscv64`, `v5-riscv64`, `riscv64`
* `v5.1.0-enable` , `v5.1-enable` , `v5-enable` , `enable`

### v5.0.1
* `v5.0.1`        , `v5.0`
* `v5.0.1-arm`    , `v5.0-arm`     (or: `-arm32v7`)
* `v5.0.1-aarch64`, `v5.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v5.0.1-riscv32`, `v5.0-riscv32`
* `v5.0.1-riscv64`, `v5.0-riscv64`
* `v5.0.1-enable` , `v5.0-enable`

### v4.2.1
* `v4.2.1`, `v4.2`, `v4`
* `v4.2.1-arm`, `v4.2-arm`, `v4-arm` (or: `-arm32v7`)
* `v4.2.1-aarch64`, `v4.2-aarch64`, `v4-aarch64` (or: `-arm64v8` & `-arm64`)
* `v4.2.1-riscv32`, `v4.2-riscv32`, `v4-riscv32`
* `v4.2.1-riscv64`, `v4.2-riscv64`, `v4-riscv64`
* `v4.2.1-enable`, `v4.2-enable`, `v4-enable`

### v4.1.1
* `v4.1.1`, `v4.1`
* `v4.1.1-arm`, `v4.1-arm` (or: `-arm32v7`)
* `v4.1.1-aarch64`, `v4.1-aarch64`  (or: `-arm64v8` & `-arm64`)
* `v4.1.1-riscv32`, `v4.1-riscv32`
* `v4.1.1-riscv64`, `v4.1-riscv64`
* `v4.1.1-enable`, `v4.1-enable`

### v4.0.1
* `v4.0.1`, `v4.0`
* `v4.0.1-arm`, `v4.0-arm` (or: `-arm32v7`)
* `v4.0.1-aarch64`, `v4.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v4.0.1-riscv32`, `v4.0-riscv32`
* `v4.0.1-riscv64`, `v4.0-riscv64`
* `v4.0.1-enable`, `v4.0-enable`

### v3.1.1
* `v3.1.1`, `v3.1`, `v3`
* `v3.1.1-arm`, `v3.1-arm`, `v3-arm` (or: `-arm32v7`)
* `v3.1.1-aarch64`, `v3.1-aarch64`, `v3-aarch64` (or: `-arm64v8` & `-arm64`)
* `v3.1.1-riscv32`, `v3.1-riscv32`, `v3-riscv32`
* `v3.1.1-riscv64`, `v3.1-riscv64`, `v3-riscv64`
* `v3.1.1-enable`, `v3.1-enable`, `v3-enable`


<details>
    <summary>Older versions here</summary>

### v5.0.0
* `v5.0.0`
* `v5.0.0-arm`     (or: `-arm32v7`)
* `v5.0.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v5.0.0-riscv32`
* `v5.0.0-riscv64`
* `v5.0.0-enable`

### v4.2.0
* `v4.2.0`
* `v4.2.0-arm` (or: `-arm32v7`)
* `v4.2.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v4.2.0-riscv32`
* `v4.2.0-riscv64`
* `v4.2.0-enable`

### v4.1.0
* `v4.1.0`
* `v4.1.0-arm` (or: `-arm32v7`)
* `v4.1.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v4.1.0-riscv32`
* `v4.1.0-riscv64`
* `v4.1.0-enable`

### v4.0.0
* `v4.0.0`
* `v4.0.0-arm` (or: `-arm32v7`)
* `v4.0.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v4.0.0-riscv32`
* `v4.0.0-riscv64`
* `v4.0.0-enable`

### v3.1.0
* `v3.1.0`
* `v3.1.0-arm` (or: `-arm32v7`)
* `v3.1.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v3.1.0-riscv32`
* `v3.1.0-riscv64`
* `v3.1.0-enable`

</details>


Usage
=====

First, enabling emulation needs to be coordinated with host's kernel:

```shell script
docker run --rm --privileged meedamian/simple-qemu -p yes
```

Once that's done, two things become possible:


#### Running

To run image built for a different CPU architecture:

```shell script
docker run --rm  arm32v7/alpine  uname -m
```

Alternatively ([`buildx`][buildx] style):

```shell script
docker run --rm  --platform=linux/arm/v7  alpine  uname -m
```


#### Extending

To build _`FROM`_ different CPU architecture image:

```dockerfile
FROM arm32v7/alpine

# Everything written here will be run on an emulated architecture
``` 

Alternatively ([`buildx`][buildx] style):

```dockerfile
FROM --platform=linux/arm/v7 alpine

# Everything written here will be run on an emulated architecture
``` 

It's that _simple_ :).

[buildx]: https://github.com/docker/buildx#buildx

> **Note:** To learn what architectures are available for the given base image you can use `docker manifest inspect` command, for example:
>
> ```shell script
> $ docker manifest inspect alpine | jq -r '.manifests[].platform | .os + "/" + .architecture + "/" + .variant'
> linux/amd64
> linux/arm/v6
> linux/arm/v7
> linux/arm64/v8
> linux/386
> linux/ppc64le
> linux/s390x
>```



Performance
------------

Depending on `qemu` version used, the speed of emulation can vary from _hardly bearable_ all the way to nightmarishly slow.

For daily generated speed comparisons see: https://github.com/lncm/docker-bitcoind/issues/9


Bugs and feedback
------------------

If you discover a bug please report it [here](https://github.com/meeDamian/simple-qemu/issues/new).  Express gratitude [here](https://hodl.studio).

Mail me at bugs@meedamian.com, or on twitter [@meeDamian](http://twitter.com/meedamian).


License
--------

MIT @ [Damian Mee](https://meedamian.com)
