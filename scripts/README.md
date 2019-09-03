This folder contains the following scripts:

## `./docker-tag.sh`

This script calls [`./shortcut-tags.sh`], and based on the output creates all recommended short-version tags for all built images (`:enable`, `:v4.1.0`, and all single-arch images).

This script **does not** override newer tags with older version. Example, if `v4.1.0` exists, and tag `v4.0.5` is requested, this script only creates the following version tags: `v4.0.5`, `v4.0`. Notably, `:latest`, and `:v4` **are not** be created, as that would override a higher version with an lower one. 


## `./generate-workflows.sh`

This is a (I hope temporary) workaround for Github Actions lack of flexibility, namely: it's not possible to have conditional jobs, only workflows, and steps.

What that translates to is that currently the only two ways to have only partially different workflows (pushes to master, and pushes of tags), are:

1. Completely duplicate the `build`, and `test` jobs in separate workflow files.  I don't want to do this, as there's a lot happening there, and I don't want to have two copies of that.
1. Attach conditional statement to every single step in `docker-hub`, and `github-release` jobs.  That's a lot of pointless lines of code added, just to avoid deployments while avoiding a build fail :/

The way this script works, is:

* It puts every job in a separate file, located in `.github/templates/`, and starting with `_`,
* It defines workflows by simply injecting the job files into general templates. Located in the same directory, but without the `_` prefix.  Example template looks like this:

```yaml
name: Build & deploy qemu on a git tag push

{{ _do-not-edit.txt }}

on:
  push:
    tags:
      - '*'

jobs:
  {{ _build-job.yml }}

  {{ _test-job.yml }}

  {{ _docker-push.yml }}

  {{ _github-release.yml }}
```

Which I hope is quite self-explanatory.

After each change to template files, `./scripts/generate-workflows.sh` is called, which updates the files GH uses to run the builds.

## `./shortcut-tags.sh`

This script takes a semver version tag as an argument, and by comparing it with already existing semver-compliant tags, suggests shortcut version to create.  

## `./trigger-new-version-build.sh`

This script is meant to be run on a developer machine, and helps with a release of a new `qemu` version.
