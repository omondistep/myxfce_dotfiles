#!/bin/bash
# Install Catppuccin cursor theme
set -euo pipefail

CURSOR_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
URL="https://github.com/catppuccin/cursors/releases/latest/download/catppuccin-latte-mauve-cursors.zip"
TMP_DIR="/tmp/catppuccin-cursors"

if [ -d "$CURSOR_DIR/catppuccin-latte-mauve-cursors" ]; then
    echo "Catppuccin cursor theme already installed"
    exit 0
fi

echo "Downloading Catppuccin cursor theme..."
mkdir -p "$TMP_DIR" "$CURSOR_DIR"
curl -fsSL "$URL" -o "$TMP_DIR/cursors.zip"
unzip -q -o "$TMP_DIR/cursors.zip" -d "$TMP_DIR"
# Copy the extracted theme directory
cp -r "$TMP_DIR"/catppuccin-latte-mauve-cursors "$CURSOR_DIR/"
rm -rf "$TMP_DIR"
echo "Catppuccin cursor theme installed"
