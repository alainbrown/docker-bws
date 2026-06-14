# Stage 1: Builder
# Use rust:alpine as the base image so the resulting binary
# is compiled against musllibc, maximizing compatibility with our docker:latest runtime image.
FROM rust:alpine AS builder

# Install Alpine packages required to compile bws and its dependencies
RUN apk add --no-cache \
    musl-dev \
    gcc \
    g++ \
    make \
    openssl-dev \
    pkgconfig

# Compile bws from source using Cargo.
RUN cargo install bws

# Verify the build locally within the builder stage
RUN bws --version

# Stage 2: Runtime
# docker:latest is based on Alpine, making it highly compatible
FROM docker:latest

# Install minimal runtime libraries that bws might dynamically link against
RUN apk add --no-cache libgcc openssl

# Copy only the compiled binary from the builder stage
COPY --from=builder /usr/local/cargo/bin/bws /usr/local/bin/bws

# Verify the binary runs correctly and is compatible with this environment
RUN bws --version

# Add sensible OCI metadata
LABEL org.opencontainers.image.title="docker-bws"
LABEL org.opencontainers.image.description="Docker CLI image with Bitwarden Secrets Manager CLI (bws)"
