#!/usr/bin/env bash
set -euo pipefail

# The Command Line Tools ship swift-testing's macro plugin and support
# libraries under Library/Developer rather than the Developer/ paths SwiftPM
# searches, so a plain `swift test` fails to build the macros and then fails to
# load the test bundle. Add them back when they are present; a full Xcode
# install needs none of this and the guards simply skip.
DEVELOPER_DIR=$(xcode-select -p)
PLUGIN="${DEVELOPER_DIR}/usr/lib/swift/host/plugins/testing/libTestingMacros.dylib"
FRAMEWORKS="${DEVELOPER_DIR}/Library/Developer/Frameworks"
LIBRARIES="${DEVELOPER_DIR}/Library/Developer/usr/lib"

FLAGS=()
if [[ -f "${PLUGIN}" ]]; then
  FLAGS+=(-Xswiftc -load-plugin-library -Xswiftc "${PLUGIN}")
fi
if [[ -d "${FRAMEWORKS}" ]]; then
  FLAGS+=(-Xlinker -rpath -Xlinker "${FRAMEWORKS}")
fi
if [[ -d "${LIBRARIES}" ]]; then
  FLAGS+=(-Xlinker -rpath -Xlinker "${LIBRARIES}")
fi

exec swift test "${FLAGS[@]}" "$@"
