# Build stage
FROM debian:bookworm AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .

# Build for the current architecture
# We use the static versions for better portability within the container
RUN cd airupnp && make HOST=linux PLATFORM=$(uname -m) -j$(nproc) && \
    cp ../bin/airupnp-linux-$(uname -m)-static /usr/bin/airupnp
RUN cd aircast && make HOST=linux PLATFORM=$(uname -m) -j$(nproc) && \
    cp ../bin/aircast-linux-$(uname -m)-static /usr/bin/aircast

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libssl3 \
    ca-certificates \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries from builder stage
COPY --from=builder /usr/bin/airupnp /usr/bin/airupnp
COPY --from=builder /usr/bin/aircast /usr/bin/aircast
RUN chmod +x /usr/bin/airupnp /usr/bin/aircast

COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
