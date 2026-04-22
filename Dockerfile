FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

ENV FLUTTER_SUPPRESS_ANALYTICS=true
ENV HOST=0.0.0.0
ENV PORT=8080
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
	libgstreamer-plugins-base1.0-dev \
	xvfb && \
	rm -rf /var/lib/apt/lists/*

COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

COPY . .

EXPOSE 8080

CMD ["sh", "-lc", "rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 && Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp & export DISPLAY=:99 && exec flutter run -d linux"]
