FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

ENV FLUTTER_SUPPRESS_ANALYTICS=true
ENV CI=true

RUN apt-get update && apt-get install -y \
	build-essential \
	cmake \
	ninja-build \
	pkg-config \
	libgtk-3-dev \
	clang \
	lld-18 \
	libsecret-1-dev \
	libwebkit2gtk-4.1-dev \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev && \
	rm -rf /var/lib/apt/lists/*

COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

COPY . .

RUN flutter build linux --release


FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
	libgtk-3-0 \
	libwebkit2gtk-4.1-0 \
	libgstreamer1.0-0 \
	libgstreamer-plugins-base1.0-0 \
	libsecret-1-0 \
	xvfb && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/build/linux/x64/release/bundle/ .
COPY --from=builder /app/openapi/ ./openapi/

LABEL org.opencontainers.image.source=https://github.com/Congiuntivo/cams-authoring-server

ENV HOST=0.0.0.0
ENV PORT=8080

EXPOSE 8080

CMD ["sh", "-c", "rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 && Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp & export DISPLAY=:99 && exec ./study_protocol_authoring_server"]
