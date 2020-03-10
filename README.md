meedamian/simple-qemu
=====================

![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/meeDamian/simple-qemu) ![](https://github.com/meeDamian/simple-qemu/workflows/Build%20%26%20deploy%20on%20git%20tag%20push/badge.svg)

This project aims to make cross-compilation, and running programs and images built for a different CPU architecture _simple_.

Currently the only **host** architecture supported is `amd64` (AKA `x86_64`), while the architectures that can be emulated are:

1. `arm` (AKA `arm32v7`)
1. `aarch64` (AKA `arm64v8`, `arm64`)
1. `riscv32`
1. `riscv64`


### Image categories

There are 3 distinct categories of images below:

1. An image containing binaries for [all architectures].  Tagged with a version alone, ex: `:v4.2.0`, or `:latest`.
1. An enable-emulation-only image.  It contains no `qemu` binaries, but can be used to enable emulation for use with your own `qemu` binary.  Tagged with the keyword `enable`, ex: `:v4.2.0-enable`, or `:enable`.
1. A single-architecture image.  These images contain a single architecture plus a script to enable emulation.  Tagged with the name of the architecture, ex: `v4.2.0-arm`, or `aarch64`.

[all architectures]: ./built-architectures.txt



Simple tags
-----------

For a complete list of available tags see: [`r/meedamian/simple-qemu/tags`](https://hub.docker.com/r/meedamian/simple-qemu/tags)

### v4.2.0
* `v4.2.0`, `v4.2`, `v4`, `latest`
* `v4.2.0-arm`, `v4.2-arm`, `v4-arm`, `arm` (or: `arm32v7`)
* `v4.2.0-aarch64`, `v4.2-aarch64`, `v4-aarch64`, `aarch64` (or: `arm64v8` & `arm64`)
* `v4.2.0-riscv32`, `v4.2-riscv32`, `v4-riscv32`, `riscv32`
* `v4.2.0-riscv64`, `v4.2-riscv64`, `v4-riscv64`, `riscv64`
* `v4.2.0-enable`, `v4.2-enable`, `v4-enable`, `enable`

### v4.1.1
* `v4.1.1`, `v4.1`
* `v4.1.1-arm`, `v4.1-arm` (or: `-arm32v7`)
* `v4.1.1-aarch64`, `v4.1-aarch64`  (or: `-arm64v8` & `-arm64`)
* `v4.1.1-riscv32`, `v4.1-riscv32`
* `v4.1.1-riscv64`, `v4.1-riscv64`
* `v4.1.1-enable`, `v4.1-enable`

### v4.1.0
* `v4.1.0`
* `v4.1.0-arm` (or: `-arm32v7`)
* `v4.1.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v4.1.0-riscv32`
* `v4.1.0-riscv64`
* `v4.1.0-enable`

### v4.0.1
* `v4.0.1`, `v4.0`
* `v4.0.1-arm`, `v4.0-arm` (or: `-arm32v7`)
* `v4.0.1-aarch64`, `v4.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v4.0.1-riscv32`, `v4.0-riscv32`
* `v4.0.1-riscv64`, `v4.0-riscv64`
* `v4.0.1-enable`, `v4.0-enable`

### v4.0.0
* `v4.0.0`
* `v4.0.0-arm` (or: `-arm32v7`)
* `v4.0.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v4.0.0-riscv32`
* `v4.0.0-riscv64`
* `v4.0.0-enable`

### v3.1.1
* `v3.1.1`, `v3.1`, `v3`
* `v3.1.1-arm`, `v3.1-arm`, `v3-arm` (or: `-arm32v7`)
* `v3.1.1-aarch64`, `v3.1-aarch64`, `v3-aarch64` (or: `-arm64v8` & `-arm64`)
* `v3.1.1-riscv32`, `v3.1-riscv32`, `v3-riscv32`
* `v3.1.1-riscv64`, `v3.1-riscv64`, `v3-riscv64`
* `v3.1.1-enable`, `v3.1-enable`, `v3-enable`

### v3.1.0
* `v3.1.0`
* `v3.1.0-arm` (or: `-arm32v7`)
* `v3.1.0-aarch64` (or: `-arm64v8` & `-arm64`)
* `v3.1.0-riscv32`
* `v3.1.0-riscv64`
* `v3.1.0-enable`


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
FROM arm32v7/alpine:3.11

# Everything written here will be run on an emulated architecture
```

It's that _simple_ :).

> **Note:** To learn what architectures are available for the given base image you can use `docker manifest inspect` command, for example:
>
> ```shell script
> $ docker manifest inspect alpine | jq -r '.manifests[].platform | .os + "/" + .architecture + " " + .variant'
> linux/amd64
> linux/arm v6
> linux/arm v7
> linux/arm64 v8
> linux/386
> linux/ppc64le
> linux/s390x
>```


Performance
------------

> **NOTE:** For an up-to-date comparison of various `qemu` versions see this issue: https://github.com/lncm/docker-bitcoind/issues/9

**Emulation can be nightmarishly slow.**  [Here's] a (not very scientific) comparison.  It uses a [random project] of mine, and compares it again't baseline (no emulation), and another project I know of ([`multiarch/qemu-user-static`]).


<table>
    <thead>
    <tr>
        <th rowspan="2"><code>qemu</code> version</th>
        <th rowspan="2">emulated<br/>architecture</th>
        <th colspan="2">time</th>
    </tr>
    <tr>
        <th><a href="#meedamiansimple-qemu"><code>simple-qemu</code></a></th>
        <th><a href="https://github.com/multiarch/qemu-user-static"><code>qemu-user-static</code></a></th>
    </tr>
    </thead>
    <tbody align="center">
    <tr>
        <td colspan="2">baseline (<code>amd64</code>)</td>
        <td colspan="2"><b>1m 56s</b></td>
    </tr>
    <tr>
        <td rowspan="2">v3.1.1</td>
        <td>arm32v7</td>
        <td>24m 5s</td>
        <td><b>22m 19s</b></td>
    </tr>
    <tr>
        <td>arm64v8</td>
        <td><b>23m 6s</b></td>
        <td>23m 27s</td>
    </tr>
    <tr>
        <td rowspan="2">v4.1.0</td>
        <td>arm32v7</td>
        <td><b>24m 36s</b></td>
        <td>25m 34s</td>
    </tr>
    <tr>
        <td>arm64v8</td>
        <td>33m 30s</td>
        <td><b>32m 23s</b></td>
    </tr>
    </tbody>
</table>


[Here's]: https://github.com/meeDamian/docker-berkeleydb/commit/9e87d11314c2522726497f0c6059e61a31298e7f/checks
[`multiarch/qemu-user-static`]: https://github.com/multiarch/qemu-user-static
[random project]: https://github.com/lncm/docker-berkeleydb/


Bugs and feedback
------------------

If you discover a bug please report it [here](https://github.com/meeDamian/simple-qemu/issues/new).  Express gratitude [here](https://hodl.studio).

Mail me at bugs@meedamian.com, or on twitter [@meeDamian](http://twitter.com/meedamian).


License
--------

MIT @ [Damian Mee](https://meedamian.com)
