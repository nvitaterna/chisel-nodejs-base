# chisel-nodejs-base

Base chisel image for creating nodejs distroless images.

This docker image:

1. Builds and installs chisel using go.
2. Builds a chiseled rootfs with required dependencies.
3. Creates a final stage from scratch with the previously generated rootfs.
