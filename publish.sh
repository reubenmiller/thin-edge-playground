#!/bin/bash

set -e

export CI=true
PUBLISH_URL=https://thinedgeio.jfrog.io/artifactory
PUBLISH_REPO=stable

DISTRIBUTION=stable
COMPONENTS=main
ARCH=all

SOURCE_PATH="${1:-.}"

if [ -z "$PUBLISH_TOKEN" ]; then
    echo "Publishing token environment variable not set. name=PUBLISH_TOKEN"
    exit 1
fi

jfrog rt upload \
    --url "${PUBLISH_URL}/${PUBLISH_REPO}" \
    --access-token "${PUBLISH_TOKEN}" \
    --deb "${DISTRIBUTION}/${COMPONENTS}/${ARCH}" \
    --flat \
    "${SOURCE_PATH}/**_${ARCH}.deb" \
    "/pool/"
