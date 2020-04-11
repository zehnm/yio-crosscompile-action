FROM ubuntu:19.10

ARG BUILD_DATE
ARG VERSION
ARG BUILD_REVISION
# https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.authors="business@markuszehnder.ch"
LABEL org.opencontainers.image.url="https://github.com/zehnm/yio-crosscompile-action"
LABEL org.opencontainers.image.source="https://github.com/zehnm/yio-crosscompile-action.git"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$BUILD_REVISION
LABEL org.opencontainers.image.title="YIO remote cross compile GitHub Action"
LABEL org.opencontainers.image.description="GitHub action for cross compiling a YIO remote project for RPi0"

ENV BUILDROOT_SDK_VERSION=v0.2.0  
ENV BUILDROOT_SDK_BASE_URL=https://github.com/YIO-Remote/remote-os/releases/download
ENV BUILDROOT_SDK_NAME=arm-buildroot-linux-gnueabihf_sdk-buildroot
ENV TOOLCHAIN_PATH /opt/$BUILDROOT_SDK_NAME

RUN apt-get update -q \
    && apt-get install --no-install-recommends -y \
    build-essential \
    # required for https download from github
    ca-certificates \
    # file: required for Buildroot relocate-sdk.sh
    file \
    git \
    gzip \
    make \
    tar \
    wget \
    && apt-get clean

# install Buildroot SDK for the YIO remote
RUN mkdir -p /opt \
    && wget -qO- $BUILDROOT_SDK_BASE_URL/${BUILDROOT_SDK_VERSION}/${BUILDROOT_SDK_NAME}.tar.gz | tar -xz -C /opt \
    && /opt/${BUILDROOT_SDK_NAME}/relocate-sdk.sh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
