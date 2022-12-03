#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR" || exit 1

COMMON=(
    --force
)

NAME=c8y-remoteaccess-plugin
VERSION=0.0.13

rm -f *.deb
find . -name ".DS_Store" -delete

fpm \
    -s dir -t deb \
    --name "$NAME" \
    --license agpl3 \
    --version "$VERSION" \
    --architecture all \
    --description "Cumulocity remote access plugin" \
    --url "https://github.com/reubenmiller/thin-edge-playground" \
    --maintainer "Reuben Miller <reuben.miller@softwareag.com>" \
    --depends "tedge >= 0.8.0" \
    --depends "python3-paho-mqtt" \
    --depends "python3-websocket >= 0.57.0" \
    --depends "python3-certifi" \
    --deb-no-default-config-files \
    --after-install postinst \
    --post-uninstall postrm \
    "${COMMON[@]}" \
    ./usr \
    ./etc

# DEB_FILE="./${NAME}_${VERSION}_all.deb"

# echo "Buiding apk (from deb)"
# fpm -s deb -t apk "${COMMON[@]}" "$DEB_FILE"

# echo "Buiding rpm (from deb)"
# fpm -s deb -t rpm "${COMMON[@]}" "$DEB_FILE"

# echo "Building tar (from deb)"
# fpm -s deb -t tar "${COMMON[@]}" "$DEB_FILE"

# echo "Building zip (from deb)"
# fpm -s deb -t zip "${COMMON[@]}" "$DEB_FILE"

popd || exit 2
