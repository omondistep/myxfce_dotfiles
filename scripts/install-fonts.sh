#!/bin/bash
# Install JetBrainsMono Nerd Font (for Debian where apt package isn't patched)
set -euo pipefail

FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
TMP_DIR="/tmp/jetbrains-nerd-font"

# Check if already installed
if fc-list | grep -qi "JetBrainsMonoNerdFont"; then
    echo "JetBrainsMono Nerd Font already installed"
    exit 0
fi

echo "Downloading JetBrainsMono Nerd Font..."
mkdir -p "$TMP_DIR" "$FONT_DIR"
curl -fsSL "$URL" -o "$TMP_DIR/JetBrainsMono.zip"
unzip -q -o "$TMP_DIR/JetBrainsMono.zip" -d "$TMP_DIR" "*.ttf"
cp "$TMP_DIR"/*.ttf "$FONT_DIR/"
fc-cache -f
rm -rf "$TMP_DIR"
echo "JetBrainsMono Nerd Font installed"
