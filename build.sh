#!/bin/bash
VERSION=0.0.1
docker build --progress=plain -t nvitaterna/chisel-nodejs-base:${VERSION} .
docker push nvitaterna/chisel-nodejs-base:${VERSION}
docker push nvitaterna/chisel-nodejs-base:latest