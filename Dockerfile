# syntax=docker/dockerfile:1

FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

ARG GENMAP_REPO=https://github.com/cpockrandt/genmap.git
ARG GENMAP_REF=genmap-v1.3.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      git \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${GENMAP_REF}" "${GENMAP_REPO}" /src/genmap && \
    cd /src/genmap && \
    git -c url."https://github.com/".insteadOf=git://github.com/ submodule update --init --recursive --depth 1

WORKDIR /src/genmap
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DGENMAP_NATIVE_BUILD=OFF && \
    cmake --build build --target genmap -j"$(nproc)" && \
    cmake --install build --prefix /opt/genmap

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      libgomp1 \
      libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/genmap /opt/genmap
ENV PATH="/opt/genmap/bin:${PATH}"

WORKDIR /data
ENTRYPOINT ["genmap"]
