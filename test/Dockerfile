# exports the official node binary, to smoke test the base image with
# (see the Test step in .github/workflows/pr-build-check.yml)
FROM node:24.22.1-slim@sha256:be8204d4bd327363357f532187b752ff62759c31bedf98e9e18fc08c9cbd605c AS node

FROM scratch
COPY --from=node /usr/local/bin/node /node
