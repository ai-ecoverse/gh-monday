#!/bin/bash

# gh-monday installer helper
# Installs this repository as a local gh extension.

set -e
export AMI_PASSTHROUGH=true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'
NC='\033[0m'

GH_BIN="$(type -P gh || true)"
EXTENSION_NAME="monday"

print_color() {
    local color="$1"
    shift
    printf "${color}%s${NC}\n" "$*"
}

extension_installed() {
    "$GH_BIN" extension list | awk '{print $1 " " $2}' | grep -qx "gh $EXTENSION_NAME"
}

extension_entry() {
    "$GH_BIN" extension list | awk -v n="$EXTENSION_NAME" '$1 == "gh" && $2 == n { print; exit }'
}

if [ -z "$GH_BIN" ] || [ ! -x "$GH_BIN" ]; then
    print_color "$RED" "Error: gh binary not found"
    exit 1
fi

print_color "$BLUE" "=== gh-monday installer ==="
print_color "$WHITE" "Using gh binary: $GH_BIN"

if extension_installed; then
    entry="$(extension_entry || true)"
    set -- $entry
    if [ $# -ge 3 ]; then
        print_color "$YELLOW" "Extension '$EXTENSION_NAME' already installed, upgrading..."
        "$GH_BIN" extension upgrade "$EXTENSION_NAME"
    else
        print_color "$YELLOW" "Extension '$EXTENSION_NAME' is installed locally, reinstalling from current checkout..."
        "$GH_BIN" extension remove "$EXTENSION_NAME" >/dev/null 2>&1 || true
        "$GH_BIN" extension install .
    fi
else
    print_color "$BLUE" "Installing extension from current directory..."
    "$GH_BIN" extension install .
fi

print_color "$GREEN" "Done. Run: gh monday"
