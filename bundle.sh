#!/bin/sh
# Builds XTerm.app next to this script.
set -e
cd "$(dirname "$0")"
swift build -c release
APP=XTerm.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp .build/release/XTerm "$APP/Contents/MacOS/XTerm"
cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>XTerm</string>
  <key>CFBundleIdentifier</key><string>local.xterm.glass</string>
  <key>CFBundleExecutable</key><string>XTerm</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>${VERSION:-dev}</string>
  <key>NSHumanReadableCopyright</key><string>Developed by Suraj Van Verma · © 2026</string>
  <key>LSMinimumSystemVersion</key><string>26.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
EOF
codesign --force --deep -s - "$APP" # ad-hoc sign so macOS sees an intact bundle
echo "Built $APP"
