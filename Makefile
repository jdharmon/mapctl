SHELL := /bin/bash

# SwiftLint loads sourcekitdInProc.framework by relative path and does not
# search the Command Line Tools; point it there. Harmless under a full Xcode.
SOURCEKIT_PATH := $(shell xcode-select -p)/usr/lib

.PHONY: help format lint test check build mapctl clean

help:
	@printf "%s\n" \
		"make format  - swift format in-place" \
		"make lint    - Swift and shell lint" \
		"make test    - sync version + swift test (coverage enabled)" \
		"make check   - lint + test + coverage gate" \
		"make build   - release build into bin/ (codesigned)" \
		"make mapctl  - clean rebuild + run debug binary (ARGS=...)" \
		"make clean   - swift package clean"

format:
	swift format --in-place --recursive Sources Tests

lint:
	swift format lint --recursive Sources Tests
	DYLD_FRAMEWORK_PATH=$(SOURCEKIT_PATH) swiftlint --strict
	shellcheck -x scripts/*.sh

test:
	scripts/generate-version.sh
	scripts/swift-test.sh --enable-code-coverage

check:
	$(MAKE) lint
	$(MAKE) test
	scripts/check-coverage.sh

build:
	scripts/generate-version.sh
	mkdir -p bin
	swift build -c release --product mapctl
	cp .build/release/mapctl bin/mapctl
	codesign --force --sign - --identifier com.jdharmon.mapctl bin/mapctl

mapctl:
	scripts/generate-version.sh
	swift package clean
	swift build -c debug --product mapctl
	./.build/debug/mapctl $(ARGS)

clean:
	swift package clean
