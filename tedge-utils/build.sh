#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR" || exit 1

COMMON=(
    --force
)

VERSION=0.1.0

fpm \
    -s dir -t deb \
    --name tedge-utils \
    --license agpl3 \
    --version "$VERSION" \
    --architecture all \
    --description "Tedge utilities" \
    --url "https://github.com/reubenmiller/thin-edge-playground" \
    --maintainer "Reuben Miller <reuben.miller@softwareag.com>" \
    --depends "tedge >= 0.8.0" \
    --deb-systemd tedge-start.service \
    --deb-systemd-enable \
    "${COMMON[@]}" \
    ./usr \
    ./etc

DEB_FILE="./tedge-utils_${VERSION}_all.deb"

echo "Buiding apk (from deb)"
fpm -s deb -t apk "${COMMON[@]}" "$DEB_FILE"

echo "Buiding rpm (from deb)"
fpm -s deb -t rpm "${COMMON[@]}" "$DEB_FILE"

echo "Building tar (from deb)"
fpm -s deb -t tar "${COMMON[@]}" "$DEB_FILE"

echo "Building zip (from deb)"
fpm -s deb -t zip "${COMMON[@]}" "$DEB_FILE"

popd || exit 2
