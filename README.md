# calculator

A new Flutter project.

## Running with Docker

The Docker image builds the web version of the app and serves it with nginx.

```sh
docker build -t calculator .
docker run --rm -p 8080:80 calculator
```

Then open http://localhost:8080.

The Flutter version used for the build is set by `FLUTTER_VERSION` in the
`Dockerfile`; override it with `--build-arg FLUTTER_VERSION=<version>`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
