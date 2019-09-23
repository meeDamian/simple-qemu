simple-qemu
============

While the automated build process is documented throughout the repository, this file aims to gather together, and briefly describe all parts of the process.

Files
------

First, the overview of the file structure:

```
$ tree -I '.git|.dockerignore' -aFL 2
.
├── .github/
│   ├── templates/
│   └── workflows/
├── BUILD.md
├── Dockerfile
├── QEMU_VERSION
├── README.md
├── built-architectures.txt
├── enable.sh
└── scripts/
    ├── README.md
    ├── docker-hub-tag.sh*
    ├── generate-workflows.sh*
    ├── github-registry-tag.sh*
    ├── shortcut-tags.sh*
    └── trigger-new-version-build.sh*
```

### `.github/templates/` & `.github/workflows/`

This directory exists only because of current Github Actions limitations - impossibility of creating conditional _jobs_.

The goal is having two _workflows_:

1. Build and test on any push
1. Build, test, and deploy to Docker Hub & Github Releases on git-tag push

The way to achieve it is:

1. Put each _job_ into a separate file (files starting with `_`, [ex: `_build-job.yml`])
1. Define each _workflow_ as a sequence of _job_ references ([`push-to-master.yml`], [`push-of-tag.yml`])
1. Create a [simple script] generating actual _workflows_ by binding these two together

[ex: `_build-job.yml`]: .github/templates/_build-job.yml
[`push-to-master.yml`]: .github/templates/push-to-master.yml
[`push-of-tag.yml`]: .github/templates/push-of-tag.yml
[simple script]: scripts/generate-workflows.sh

### `QEMU_VERSION`

Defines the [version of qemu] to be built.  In case of git-tag push, both [have to be the same].

[version of qemu]: https://github.com/qemu/qemu/releases
[have to be the same]: https://github.com/meeDamian/simple-qemu/blob/1c4591f7709984522ce52db984d55ad487ee7640/.github/workflows/push-of-tag.yml#L146-L149

### `built-architectures.txt`

Defines guest architectures to be build.  This is where you add a new line, if you want new arch built, and supported.  For the list of available architectures, consult [the file], or [qemu's `./configure`].

[the file]: ./built-architectures.txt
[qemu's `./configure`]: https://github.com/qemu/qemu/blob/master/configure

### `enable.sh`

Script registering qemu binaries with the kernel of the host.  This file is [copied] into the build image, and later used as an [entrypoint].

[copied]: https://github.com/meeDamian/simple-qemu/blob/1c4591f7709984522ce52db984d55ad487ee7640/Dockerfile#L78
[entrypoint]: https://github.com/meeDamian/simple-qemu/blob/1c4591f7709984522ce52db984d55ad487ee7640/Dockerfile#L86

### `scripts/`

A collection of scripts used by the built process.  More detailed description available [here].

[here]: scripts/README.md

The Process
------------

Assuming the release of `v9.9.9`.

1. Run `scripts/trigger-new-version-build.sh v9.9.9`, which:
    1. Makes sure `QEMU_VERSION` contains version being released
    1. Makes sure all `.github/workflows/*` are up-to-date
    1. Pushes _trigger commit_, and git-tag to Github
1. `.github/workflows/push-of-tag.yml` gets triggered by tag push
1. Job `build` _builds_ all variants of images, and upon successful completion:
    1. Uploads all Docker images as build artifacts into `images/`
    1. Extracts `qemu` binaries from built images, and uploads them as build artifacts into `binaries/`
    1. Prints `sha256` sums of all
1. Job `test` detects success of `build`, and:
    1. Downloads and docker-loads all `images/` from build artifacts
    1. It runs `uname -a` on all possible emulated architectures
    1. Verifies that git-tag, and contents of `QEMU_VERSION` match
1. Job `docker-hub-push` detects success of `test`, and:
    1. Downloads and docker-loads all `images/` from build artifacts
    1. Docker-tags all images (including all convenience tags like `:v9`, or `:v9.9-arm64`)
    1. Lists all images for future reference
    1. Logs in to Docker Hub
    1. Pushes all tagged images
    1. Updates `README.md` to Docker Hub
1. Job `githu-registry-push` detects success of `test`, and:
    1. Irrelevant for now, as pushing many images at once is borked
1. Job `github-release` detects success of `test`, and:
    1. Downloads and docker-loads all `binaries/` from build artifacts
    1. Prints their checksums
    1. Uploads them to Github Release


