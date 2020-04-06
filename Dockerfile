FROM ubuntu:19.10

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
