#!/bin/bash

# Basic sanity test for gh-monday extension script.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Running gh-monday sanity test..."
"$SCRIPT_DIR/gh-monday" --no-fetch --no-global --limit 20 >/dev/null
echo "OK: script executed successfully"
