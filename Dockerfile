FROM ghcr.io/linuxserver/baseimage-alpine:edge AS builder

COPY autotier.patch "/build/"

RUN apk add --no-cache --update-cache \
        fuse3-dev \
        boost1.81-dev \
        boost1.81-static \
        libtbb-dev \
        git \
        make \
        g++ \
        rocksdb-dev \
 && mkdir -p /build \
 && cd /build \
 && git clone --recursive https://github.com/45drives/lib45d \
 && cd /build/lib45d \
 && make -j8 \
 && make install DEVEL=1 \
 && cd /build \
 && git clone --recursive https://github.com/45drives/autotier \
 && cd /build/autotier \
 && git apply /build/autotier.patch \
 && make -j8 \
 && make install

FROM ghcr.io/jefflessard/plex-alpine:10

RUN apk --no-cache --update-cache add \
    fuse3 \
    boost1.81-filesystem \
    boost1.81-serialization \
    boost1.81-system \
    libtbb \
    lz4-libs \
    snappy \
    liburing

COPY --from=builder "/opt/45drives/autotier/*" "/usr/bin/"
COPY autotier.conf /etc/
COPY init-autotier.sh /custom-cont-init.d/

ENV AUTOTIER_PATH=/tmp/autotier AUTOTIER_QUOTA=512MiB