ARG UBUNTU_TAG="24.10"

ARG UBUNTU_CHISEL_VERSION="24.10"

# renovate: suite=oracular arch=amd64 versioning=loose depName=golang
ARG GOLANG_AMD64_VERSION="2:1.23~1"

# renovate: suite=oracular arch=amd64 versioning=loose depName=ca-certificates
ARG CACERTIFICATES_AMD64_VERSION="20240203"

# renovate: suite=oracular arch=amd64 versioning=loose depName=file
ARG FILE_AMD64_VERSION="1:5.45-3build1"

# renovate: suite=oracular arch=arm64 versioning=loose depName=golang
ARG GOLANG_ARM64_VERSION="2:1.23~1"

# renovate: suite=oracular arch=arm64 versioning=loose depName=ca-certificates
ARG CACERTIFICATES_ARM64_VERSION="20240203"

# renovate: suite=oracular arch=arm64 versioning=loose depName=file
ARG FILE_ARM64_VERSION="1:5.45-3build1"

FROM ubuntu:${UBUNTU_TAG} AS builder-linux-amd64
ARG GOLANG_AMD64_VERSION
ARG CACERTIFICATES_AMD64_VERSION
WORKDIR /builder
RUN apt-get update \
  -q \
  && apt-get install \
  -y \
  --no-install-recommends \
  golang=${GOLANG_AMD64_VERSION} \
  ca-certificates=${CACERTIFICATES_AMD64_VERSION}
ADD https://github.com/canonical/chisel.git .
WORKDIR /builder/cmd/chisel
RUN go install

FROM ubuntu:${UBUNTU_TAG} AS builder-linux-arm64
ARG GOLANG_ARM64_VERSION
ARG CACERTIFICATES_ARM64_VERSION
WORKDIR /builder
RUN apt-get update \
  -q \
  && apt-get install \
  -y \
  --no-install-recommends \
  golang=${GOLANG_ARM64_VERSION} \
  ca-certificates=${CACERTIFICATES_ARM64_VERSION}
ADD https://github.com/canonical/chisel.git .
WORKDIR /builder/cmd/chisel
RUN go install

FROM ubuntu:${UBUNTU_TAG} AS installer-linux-amd64
ARG UBUNTU_TAG
ARG UBUNTU_CHISEL_VERSION
ARG CACERTIFICATES_AMD64_VERSION
ARG FILE_AMD64_VERSION
WORKDIR /setup
COPY --from=builder-linux-amd64 /root/go/bin/chisel /usr/bin
RUN apt-get update \
  -q \
  && apt-get install \
  -y \
  --no-install-recommends \
  ca-certificates=${CACERTIFICATES_AMD64_VERSION} \
  file=${FILE_AMD64_VERSION}
ADD https://github.com/canonical/rocks-toolbox.git .
RUN mkdir -p /rootfs/var/lib/dpkg \
  && ./chisel-wrapper \
  --generate-dpkg-status /rootfs/var/lib/dpkg/status \
  -- \
  --release ubuntu-${UBUNTU_CHISEL_VERSION} \
  --root /rootfs/ \
  ca-certificates_data \
  tzdata_zoneinfo \
  libstdc++6_libs \
  base-files_release-info \
  base-files_base \
  base-files_chisel

FROM ubuntu:${UBUNTU_TAG} AS installer-linux-arm64
ARG UBUNTU_TAG
ARG CACERTIFICATES_ARM64_VERSION
ARG FILE_ARM64_VERSION
WORKDIR /setup
COPY --from=builder-linux-arm64 /root/go/bin/chisel /usr/bin
RUN apt-get update \
  -q \
  && apt-get install \
  -y \
  --no-install-recommends \
  ca-certificates=${CACERTIFICATES_ARM64_VERSION} \
  file=${FILE_ARM64_VERSION}
ADD https://github.com/canonical/rocks-toolbox.git .
RUN mkdir -p /rootfs/var/lib/dpkg \
  && ./chisel-wrapper \
  --generate-dpkg-status /rootfs/var/lib/dpkg/status \
  -- \
  --release ubuntu-${UBUNTU_CHISEL_VERSION} \
  --root /rootfs/ \
  ca-certificates_data \
  tzdata_zoneinfo \
  libstdc++6_libs \
  base-files_release-info \
  base-files_base \
  base-files_chisel

FROM installer-${TARGETOS}-${TARGETARCH} AS installer

FROM scratch
COPY --from=installer /rootfs /