#!/bin/sh
# Usage: ./release.sh 0.2
# Builds XTerm.app, publishes a GitHub release, and points the Homebrew cask at it.
set -e
cd "$(dirname "$0")"
V=${1:?usage: ./release.sh <version>}

VERSION=$V ./bundle.sh

# Notarize when a Developer ID is available (paid Apple Developer account). Untested until then.
# One-time setup: xcrun notarytool store-credentials xterm --apple-id <email> --team-id <team>
if [ -n "$DEVELOPER_ID" ]; then
  codesign --force --deep --options runtime --timestamp -s "$DEVELOPER_ID" XTerm.app
  ditto -c -k --keepParent XTerm.app XTerm.zip
  xcrun notarytool submit XTerm.zip --keychain-profile xterm --wait
  xcrun stapler staple XTerm.app
fi

rm -f XTerm.zip
ditto -c -k --keepParent XTerm.app XTerm.zip
SHA=$(shasum -a 256 XTerm.zip | cut -d' ' -f1)

git push
gh release create "v$V" XTerm.zip --title "XTerm $V" --generate-notes

TAP=$(mktemp -d)
gh repo clone bythebug/homebrew-tap "$TAP" -- -q
sed -i '' -e "s/version \".*\"/version \"$V\"/" -e "s/sha256 \".*\"/sha256 \"$SHA\"/" "$TAP/Casks/xterm-glass.rb"
git -C "$TAP" commit -qam "xterm-glass $V"
git -C "$TAP" push -q
rm -rf "$TAP"
echo "Released $V: brew upgrade --cask xterm-glass"
