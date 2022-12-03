#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$SCRIPT_DIR" || exit 1

COMMON=(
    --force
)

NAME=c8y-plugin-notifier
VERSION=0.0.1

rm -f *.deb
find . -name ".DS_Store" -delete

fpm \
    -s dir -t deb \
    --name "c8y-plugin-notifier" \
    --license agpl3 \
    --version "0.0.1" \
    --architecture all \
    --description "Cumulocity plugin notifier" \
    --url "https://github.com/reubenmiller/thin-edge-playground" \
    --maintainer "Reuben Miller <reuben.miller@softwareag.com>" \
    --depends "python3-paho-mqtt" \
    --deb-systemd plugin-change-notifier.service \
    --deb-systemd-enable \
    --after-install postinst \
    "${COMMON[@]}" \
    ./usr

popd || exit 2
