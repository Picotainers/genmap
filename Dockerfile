FROM debian:bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    cmake \
    git \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/cpina/genmap.git /src/genmap && \
    cmake -S /src/genmap -B /src/genmap/build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /src/genmap/build -j"$(nproc)" && \
    install -m 0755 /src/genmap/build/bin/genmap /usr/local/bin/genmap

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libstdc++6 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/genmap /usr/local/bin/genmap
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/genmap"]
