#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR" || exit 1

COMMON=(
    --force
)

NAME=c8y-xmas-plugin
VERSION=0.0.34

rm -f *.deb
find . -name ".DS_Store" -delete

fpm \
    -s dir -t deb \
    --name "$NAME" \
    --license agpl3 \
    --version "$VERSION" \
    --architecture all \
    --description "Cumulocity xmas vending machine plugin" \
    --url "https://github.com/reubenmiller/thin-edge-playground" \
    --maintainer "Reuben Miller <reuben.miller@softwareag.com>" \
    --depends "tedge >= 0.8.0" \
    --deb-no-default-config-files \
    --config-files etc/xmas/state \
    --after-install postinst \
    --post-uninstall postrm \
    --before-install preinst \
    "${COMMON[@]}" \
    ./usr \
    ./etc

popd || exit 2
