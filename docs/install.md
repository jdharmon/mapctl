---
title: Install
description: "Building mapctl from source, code signing, and shell completion."
---

## Requirements

- macOS 26 or newer
- A Swift 6.2 toolchain — Xcode 26, or the matching Command Line Tools

The macOS 26 floor comes from MapKit's current geocoding APIs (`MKGeocodingRequest`, `MKReverseGeocodingRequest`, `MKAddress`, `MKAddressRepresentations`). Their predecessors, `CLGeocoder` and `MKPlacemark`, are deprecated in the macOS 26 SDK.

## From source

```bash
git clone <repo> mapctl && cd mapctl
make build
cp bin/mapctl /usr/local/bin/
```

`make build` regenerates the version file, builds a release binary, copies it to `bin/mapctl`, and ad-hoc signs it.

## Code signing

The build signs the binary with a stable identifier:

```bash
codesign --force --sign - --identifier com.jdharmon.mapctl bin/mapctl
```

`mapctl` needs no TCC permissions, so an unsigned binary still works. The signature and the embedded `Info.plist` exist to give the tool a stable bundle identity, matching how `calctl` is built.

## Verify

```bash
mapctl --version
mapctl doctor
```

`doctor` reports the version, executable path, shell, locale, measurement system, and whether Apple's map services answer from this machine. If it reports the services unreachable, check the network — that is the only dependency.

## Shell completion

```bash
# zsh
mapctl completion zsh > "${fpath[1]}/_mapctl"

# bash
mapctl completion bash > /usr/local/etc/bash_completion.d/mapctl
```

Restart the shell afterwards.

## Development

```bash
make format   # swift format in-place
make lint     # swift format lint + swiftlint --strict + shellcheck
make test     # swift test with coverage
make check    # lint + test + coverage gate
make clean    # swift package clean
```

`make lint` needs [SwiftLint](https://github.com/realm/SwiftLint) and [ShellCheck](https://www.shellcheck.net):

```bash
brew install swiftlint shellcheck
```

SwiftLint loads `sourcekitdInProc.framework` by relative path and does not search the Command Line Tools, so `make lint` sets `DYLD_FRAMEWORK_PATH` to `$(xcode-select -p)/usr/lib` for it. That is a no-op under a full Xcode install, where SwiftLint finds the framework in the toolchain on its own.

Tests run through `scripts/swift-test.sh`. On a Command Line Tools install, swift-testing's macro plugin and support libraries live outside the paths SwiftPM searches, so a plain `swift test` fails to build the test macros; the script adds them back when it finds them and is a no-op on a full Xcode install.
