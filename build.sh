#!/bin/bash

# Install Flutter
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

# Enable web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build for web
flutter build web --release
