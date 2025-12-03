#!/bin/bash
set -e  # Exit on error

echo "🚀 Starting PawGram build process..."

# Check if Flutter is already installed
if [ -d "flutter" ]; then
  echo "✅ Flutter already installed, skipping clone..."
else
  echo "📦 Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter --version

# Enable web support
echo "🌐 Enabling Flutter web..."
flutter config --enable-web --no-analytics

# Get dependencies
echo "📚 Getting dependencies..."
flutter pub get

# Build for web
echo "🏗️ Building for web (this may take a few minutes)..."
flutter build web --release

echo "✅ Build completed successfully!"
echo "📁 Output directory: build/web"
