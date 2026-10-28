ARG UBUNTU_TAG="resolute-20261024.1@sha256:8cdfd1908ab55af6d1ce8fdacb24951ad31873f500489cc03378393798ce301c"

FROM ubuntu:${UBUNTU_TAG} AS setup
ARG TARGETARCH

# renovate-chisel: depName=canonical-chisel-releases
ARG UBUNTU_CHISEL_VERSION="26.10"

# renovate-apt-docker: arch=amd64 versioning=loose depName=golang
ARG GOLANG_amd64_VERSION="2:1.26~1"
# renovate-apt-docker: arch=arm64 versioning=loose depName=golang
ARG GOLANG_arm64_VERSION="2:1.26~1"

# renovate-apt-docker: arch=amd64 versioning=loose depName=ca-certificates
ARG CACERTIFICATES_amd64_VERSION="20260816ubuntu0.26.04.1"
# renovate-apt-docker: arch=arm64 versioning=loose depName=ca-certificates
ARG CACERTIFICATES_arm64_VERSION="20260816ubuntu0.26.04.1"

# renovate-apt-docker: arch=amd64 versioning=loose depName=file
ARG FILE_amd64_VERSION="1:5.46-5build2"
# renovate-apt-docker: arch=arm64 versioning=loose depName=file
ARG FILE_arm64_VERSION="1:5.46-5build2"

# renovate-apt-docker: arch=amd64 versioning=loose depName=libatomic1
ARG LIBATOMIC_amd64_VERSION="16-20260322-1ubuntu1"
# renovate-apt-docker: arch=arm64 versioning=loose depName=libatomic1
ARG LIBATOMIC_arm64_VERSION="16-20260322-1ubuntu1"

# install dependencies
RUN GOLANG_VERSION=$(eval "echo \$GOLANG_${TARGETARCH}_VERSION") \
  && CACERTIFICATES_VERSION=$(eval "echo \$CACERTIFICATES_${TARGETARCH}_VERSION") \
  && FILE_VERSION=$(eval "echo \$FILE_${TARGETARCH}_VERSION") \
  && LIBATOMIC_VERSION=$(eval "echo \$LIBATOMIC_${TARGETARCH}_VERSION") \
  && apt-get update \
  -q \
  && apt-get install \
  -y \
  --no-install-recommends \
  golang=$GOLANG_VERSION \
  ca-certificates=$CACERTIFICATES_VERSION \
  file=${FILE_VERSION} \
  libatomic1=$LIBATOMIC_VERSION

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
  libatomic1_libs

FROM scratch
COPY --from=setup /rootfs /
WORKDIR /home
COPY <<EOF /etc/passwd
node:x:1000:1000:node:/home/node:
EOF
COPY <<EOF /etc/group
node:x:1000:
EOF
USER node
WORKDIR /home/node