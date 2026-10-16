<p align="center"><img src="docs/icon.png" width="128" alt="XTerm icon"></p>

# XTerm

A macOS terminal with Apple's Liquid Glass look. It behaves like Terminal.app (your shell, colors, vim, tmux, scrollback, copy/paste, tabs); only the style is new.

Requires macOS 26 (Tahoe) or later.

## Install

```sh
brew install --cask bythebug/tap/xterm-glass
```

XTerm isn't notarized by Apple yet, so the first launch is blocked. Allow it once with:

```sh
xattr -dr com.apple.quarantine /Applications/XTerm.app
```

Update with `brew upgrade --cask xterm-glass`.

## Features

| Shortcut | Action |
|---|---|
| ⌘N / ⌘T | New window / new tab, opened in the current folder |
| ⌘D / ⇧⌘D | Split right / split down (`exit` closes a pane) |
| ⌘= / ⌘- / ⌘0 | Bigger / smaller / actual size text |
| ⌘, | Settings: theme, font, size, glass background |

Themes: **Glass** (follows light/dark mode), **Midnight**, **Paper**, **High Contrast**. Also in View → Theme.

The terminal bell (`printf '\a'`) flashes the glass instead of beeping. Try `make; printf '\a'` to get a flash when a long command finishes.

## Build from source

Needs Xcode 26+.

```sh
swift run          # run it directly
./bundle.sh        # build XTerm.app
cp -R XTerm.app /Applications/
```

Release a new version (builds, publishes the GitHub release, updates the Homebrew cask):

```sh
./release.sh 0.3
```

## How it works

- `Sources/XTerm/XTermApp.swift` — windows, menus and shortcuts.
- `Sources/XTerm/GlassTerminal.swift` — native `NSGlassEffectView` window background.
- `Sources/XTerm/Pane.swift` — one transparent [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) shell; splitting and closing panes.
- `Sources/XTerm/Settings.swift` — themes and the Settings window.
- `bundle.sh` / `release.sh` — package and publish the app.

## Credits

Developed by Suraj Van Verma. Terminal emulation by [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) (MIT).

## License

[MIT](LICENSE)
