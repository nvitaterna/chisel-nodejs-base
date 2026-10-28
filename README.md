# chisel-nodejs-base

> **This repository is archived.** The chisel base is now built inside
> [nvitaterna/nodejs-distroless](https://github.com/nvitaterna/nodejs-distroless)
> (the `base` stage of its `Dockerfile`), so it no longer needs a separate
> image. The `nvitaterna/chisel-nodejs-base` Docker Hub image is not updated
> anymore; its last tag is `0.3.1` (Ubuntu 26.04 LTS).

Base chisel image for creating nodejs distroless images.

This docker image:

1. Builds and installs chisel using go.
2. Builds a chiseled rootfs with required dependencies.
3. Creates a final stage from scratch with the previously generated rootfs.
