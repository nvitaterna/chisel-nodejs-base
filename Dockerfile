ARG UBUNTU_TAG="oracular-20250225@sha256:aadf9a3f5eda81295050d13dabe851b26a67597e424a908f25a63f589dfed48f"

FROM ubuntu:${UBUNTU_TAG} AS setup
ARG TARGETARCH

# renovate-chisel: depName=canonical-chisel-releases
ARG UBUNTU_CHISEL_VERSION="24.10"

# renovate-apt-docker: arch=amd64 versioning=loose depName=golang
ARG GOLANG_amd64_VERSION="2:1.23~1"
# renovate-apt-docker: arch=arm64 versioning=loose depName=golang
ARG GOLANG_arm64_VERSION="2:1.23~1"

# renovate-apt-docker: arch=amd64 versioning=loose depName=ca-certificates
ARG CACERTIFICATES_amd64_VERSION="20240203"
# renovate-apt-docker: arch=arm64 versioning=loose depName=ca-certificates
ARG CACERTIFICATES_arm64_VERSION="20240203"

# renovate-apt-docker: arch=amd64 versioning=loose depName=file
ARG FILE_amd64_VERSION="1:5.45-3build1"
# renovate-apt-docker: arch=arm64 versioning=loose depName=file
ARG FILE_arm64_VERSION="1:5.45-3build1"

# install dependencies
RUN GOLANG_VERSION=$(eval "echo \$GOLANG_${TARGETARCH}_VERSION") \
  && CACERTIFICATES_VERSION=$(eval "echo \$CACERTIFICATES_${TARGETARCH}_VERSION") \
  && FILE_VERSION=$(eval "echo \$FILE_${TARGETARCH}_VERSION") \
  && apt-get update \
  -q \
  && apt-get install \
  -y \
  --no-install-recommends \
  golang=$GOLANG_VERSION \
  ca-certificates=$CACERTIFICATES_VERSION \
  file=${FILE_VERSION}

# build chisel
WORKDIR /builder
ADD https://github.com/canonical/chisel.git .
WORKDIR /builder/cmd/chisel
RUN go install
RUN ln -sf /root/go/bin/chisel /usr/bin/chisel

# create chiseled rootfs
WORKDIR /setup
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

FROM scratch
COPY --from=setup /rootfs /
