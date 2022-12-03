FROM mcr.microsoft.com/vscode/devcontainers/base:debian

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        debhelper \
        dh-virtualenv \
        fakeroot \
        devscripts \
        build-essential \
        ruby \
        squashfs-tools \
        rpm \
    && gem install fpm \
    && curl -fL https://getcli.jfrog.io/v2 | sh \
    && mv jfrog /usr/local/bin/
