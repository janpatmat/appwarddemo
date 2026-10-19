# syntax=docker/dockerfile:1

# ---- Build stage: compile the Flutter app for the web ----
FROM debian:bookworm-slim AS build

# Keep in sync with the Flutter version in .metadata.
ARG FLUTTER_VERSION=3.47.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Cloning (rather than downloading the release tarball) works on both amd64 and arm64 hosts.
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"

RUN flutter config --no-analytics \
    && flutter precache --web

WORKDIR /app

# Resolve dependencies in their own layer so code changes don't re-download packages.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
# Bundle CanvasKit into the build instead of loading it from Google's CDN at runtime.
RUN flutter build web --release --no-web-resources-cdn

# ---- Runtime stage: serve the static build with nginx ----
FROM nginx:1.30-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s CMD wget -q --spider http://127.0.0.1/ || exit 1
