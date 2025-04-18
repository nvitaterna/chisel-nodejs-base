ARG UBUNTU_RELEASE=24.10
ARG GOLANG_VERSION=2:1.23~1
ARG CACERTIFICATES_VERSION=20240203
ARG FILE_VERSION=1:5.45-3build1

FROM ubuntu:${UBUNTU_RELEASE} AS builder
ARG GOLANG_VERSION
ARG CACERTIFICATES_VERSION
WORKDIR /builder
RUN apt-get update \
  -q \
  && apt-get install \
  -y \
  --no-install-recommends \
  golang=${GOLANG_VERSION} \
  ca-certificates=${CACERTIFICATES_VERSION}
ADD https://github.com/canonical/chisel.git .
WORKDIR /builder/cmd/chisel
RUN go install

FROM ubuntu:${UBUNTU_RELEASE} AS installer
ARG UBUNTU_RELEASE
ARG CACERTIFICATES_VERSION
ARG FILE_VERSION
WORKDIR /setup
COPY --from=builder /root/go/bin/chisel /usr/bin
RUN apt-get update \
  -q \
  && apt-get install \
  -y \
  --no-install-recommends \
  ca-certificates=${CACERTIFICATES_VERSION} \
  file=${FILE_VERSION}
ADD https://github.com/canonical/rocks-toolbox.git .
RUN mkdir -p /rootfs/var/lib/dpkg \
  && ./chisel-wrapper \
  --generate-dpkg-status /rootfs/var/lib/dpkg/status \
  -- \
  --release ubuntu-${UBUNTU_RELEASE} \
  --root /rootfs/ \
  ca-certificates_data \
  tzdata_zoneinfo \
  libstdc++6_libs \
  base-files_release-info \
  base-files_base \
  base-files_chisel

FROM scratch
COPY --from=installer /rootfs /