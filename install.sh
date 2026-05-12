#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

echo "=== Installing packages ==="
pkexec apt update
pkexec apt install -y \
  polybar rofi xbindkeys xfce4-terminal alacritty \
  papirus-icon-theme fonts-jetbrains-mono \
  starship foot \
  maim xclip pavucontrol ranger xfce4-clipman-plugin \
  curl git unzip

echo "=== Removing bloat ==="
pkexec apt purge -y tumbler libreoffice* firefox* 2>/dev/null || true
pkexec apt autoremove -y

echo "=== Linking configs ==="
mkdir -p ~/.config ~/.local/bin ~/.fonts ~/.local/share/backgrounds

ln -sf "$DOTFILES/.xbindkeysrc" ~/
ln -sf "$DOTFILES/.bashrc" ~/
ln -sf "$DOTFILES/config/alacritty/alacritty.toml" ~/.config/alacritty/
ln -sf "$DOTFILES/config/foot/foot.ini" ~/.config/foot/
ln -sf "$DOTFILES/config/fontconfig/fonts.conf" ~/.config/fontconfig/
ln -sf "$DOTFILES/config/gtk-3.0/gtk.css" ~/.config/gtk-3.0/ 2>/dev/null || true
ln -sf "$DOTFILES/config/starship.toml" ~/.config/starship.toml
ln -sf "$DOTFILES/config/opencode/opencode.json" ~/.config/opencode/
ln -sf "$DOTFILES/config/polybar/config.ini" ~/.config/polybar/
ln -sf "$DOTFILES/config/polybar/launch.sh" ~/.config/polybar/
ln -sf "$DOTFILES/config/rofi/config.rasi" ~/.config/rofi/
ln -sf "$DOTFILES/config/xfce4-terminal/terminalrc" ~/.config/xfce4/terminal/
ln -sf "$DOTFILES/backgrounds/everforest.jpg" ~/.local/share/backgrounds/
ln -sf "$DOTFILES/local/bin/"* ~/.local/bin/

# Neovim config
ln -sf "$DOTFILES/config/nvim/init.lua" ~/.config/nvim/
ln -sf "$DOTFILES/config/nvim/lua" ~/.config/nvim/

# Autostart
mkdir -p ~/.config/autostart
ln -sf "$DOTFILES/config/autostart/polybar.desktop" ~/.config/autostart/

# xdg-terminals
cat > ~/.config/xdg-terminals.list << 'TERM'
alacritty.desktop
xfce4-terminal.desktop
foot.desktop
TERM

echo "=== Installing Everforest GTK theme ==="
mkdir -p ~/.themes
if [ ! -d ~/.themes/Everforest ]; then
  curl -sL https://github.com/theorytoe/everforest-gtk/releases/latest/download/Everforest.tar.xz \
    | tar -xJ -C ~/.themes/
fi

echo "=== Restoring font cache ==="
fc-cache -f

echo "=== Installing Neovim ==="
if ! command -v nvim &>/dev/null; then
  curl -sL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage \
    -o ~/.local/bin/nvim && chmod +x ~/.local/bin/nvim
fi

echo "=== Restoring xfce settings ==="
bash "$DOTFILES/scripts/xfce-keybindings.sh"
bash "$DOTFILES/scripts/xfce-settings.sh"
xfwm4 --replace &

echo "=== Restarting services ==="
bash ~/.config/polybar/launch.sh

echo ""
echo "=== Done! ==="
echo "Log out and back in for all changes to take effect."
echo "Then press Super+F1 for keybinding help."
