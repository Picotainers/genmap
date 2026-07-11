FROM debian:bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    cmake \
    git \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ENV GIT_TERMINAL_PROMPT=0
RUN git clone --depth 1 https://github.com/cpockrandt/genmap.git /src/genmap && \
    git -C /src/genmap submodule update --init --recursive && \
    cmake -S /src/genmap -B /src/genmap/build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /src/genmap/build -j"$(nproc)" && \
    install -m 0755 /src/genmap/build/bin/genmap /usr/local/bin/genmap

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/genmap /usr/local/bin/genmap
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/genmap"]
CMD ["--help"]
