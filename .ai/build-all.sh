#!/usr/bin/env bash
# Runs every adapter's build.sh in order.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ADAPTERS_DIR="$REPO_ROOT/.ai/adapters"

if [ ! -d "$ADAPTERS_DIR" ]; then
  echo "No adapters dir at $ADAPTERS_DIR" >&2
  exit 1
fi

for adapter in "$ADAPTERS_DIR"/*/; do
  build="$adapter/build.sh"
  if [ -x "$build" ] || [ -f "$build" ]; then
    echo "▶ $(basename "$adapter")"
    bash "$build"
  fi
done
