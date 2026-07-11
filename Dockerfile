FROM debian:bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    cmake \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ARG GENMAP_VERSION=v1.3.0
RUN wget -q -O /tmp/genmap.tar.gz \
        "https://github.com/cpina/genmap/archive/refs/tags/${GENMAP_VERSION}.tar.gz" \
    && tar -xzf /tmp/genmap.tar.gz -C /tmp \
    && cmake -S /tmp/genmap-${GENMAP_VERSION#v} -B /tmp/genmap-build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /tmp/genmap-build -j"$(nproc)" \
    && install -m 0755 /tmp/genmap-build/bin/genmap /usr/local/bin/genmap \
    && rm -rf /tmp/genmap.tar.gz /tmp/genmap-*/

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libstdc++6 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/genmap /usr/local/bin/genmap
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/genmap"]
