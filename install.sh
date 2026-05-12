#!/bin/bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# ------ Distro detection ------
detect_distro() {
  if [ -f /etc/arch-release ]; then
    echo "arch"
  elif [ -f /etc/debian_version ]; then
    echo "debian"
  elif command -v apt &>/dev/null; then
    echo "debian"
  elif command -v pacman &>/dev/null; then
    echo "arch"
  else
    echo "unknown"
  fi
}

DISTRO=$(detect_distro)
echo "Detected distro: $DISTRO"

# ------ Privilege escalation ------
SUDO=""
if command -v sudo &>/dev/null; then
  SUDO="sudo"
elif command -v pkexec &>/dev/null; then
  SUDO="pkexec"
fi

if [ -z "$SUDO" ]; then
  echo "ERROR: neither sudo nor pkexec found"
  exit 1
fi

# ------ Install packages ------
install_arch() {
  $SUDO pacman -Syu --noconfirm
  $SUDO pacman -S --noconfirm \
    base-devel git curl unzip \
    xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
    polybar rofi xbindkeys alacritty foot \
    ttf-jetbrains-mono-nerd papirus-icon-theme \
    starship maim xclip pavucontrol ranger \
    xfce4-clipman-plugin
}

install_debian() {
  $SUDO apt update
  $SUDO apt install -y \
    polybar rofi xbindkeys xfce4-terminal alacritty \
    papirus-icon-theme fonts-jetbrains-mono \
    starship foot \
    maim xclip pavucontrol ranger xfce4-clipman-plugin \
    curl git unzip
  # Remove bloat
  $SUDO apt purge -y tumbler libreoffice* firefox* 2>/dev/null || true
  $SUDO apt autoremove -y
}

echo "=== Installing packages ==="
case "$DISTRO" in
  arch)   install_arch ;;
  debian) install_debian ;;
  *)
    echo "Unsupported distro: $DISTRO"
    echo "Install these packages manually, then re-run this script."
    exit 1
    ;;
esac

# ------ Link configs ------
echo "=== Linking configs ==="
mkdir -p ~/.config ~/.local/bin ~/.fonts ~/.local/share/backgrounds

ln -sf "$DOTFILES/.xbindkeysrc" ~/
ln -sf "$DOTFILES/.bashrc" ~/
mkdir -p ~/.config/alacritty ~/.config/foot ~/.config/fontconfig \
  ~/.config/gtk-3.0 ~/.config/polybar ~/.config/rofi \
  ~/.config/xfce4/terminal
ln -sf "$DOTFILES/config/alacritty/alacritty.toml" ~/.config/alacritty/
ln -sf "$DOTFILES/config/foot/foot.ini" ~/.config/foot/
ln -sf "$DOTFILES/config/fontconfig/fonts.conf" ~/.config/fontconfig/
[ -f "$DOTFILES/config/gtk-3.0/gtk.css" ] && ln -sf "$DOTFILES/config/gtk-3.0/gtk.css" ~/.config/gtk-3.0/
ln -sf "$DOTFILES/config/starship.toml" ~/.config/starship.toml
mkdir -p ~/.config/opencode
ln -sf "$DOTFILES/config/opencode/opencode.json" ~/.config/opencode/
ln -sf "$DOTFILES/config/polybar/config.ini" ~/.config/polybar/
ln -sf "$DOTFILES/config/polybar/launch.sh" ~/.config/polybar/
ln -sf "$DOTFILES/config/rofi/config.rasi" ~/.config/rofi/
ln -sf "$DOTFILES/config/xfce4-terminal/terminalrc" ~/.config/xfce4/terminal/
ln -sf "$DOTFILES/backgrounds/everforest.jpg" ~/.local/share/backgrounds/
ln -sf "$DOTFILES/local/bin/"* ~/.local/bin/

# Neovim config
mkdir -p ~/.config/nvim/lua/plugins
ln -sf "$DOTFILES/config/nvim/init.lua" ~/.config/nvim/
ln -sf "$DOTFILES/config/nvim/lua/config" ~/.config/nvim/lua/config 2>/dev/null || true
ln -sf "$DOTFILES/config/nvim/lua/plugins/everforest.lua" ~/.config/nvim/lua/plugins/

# Autostart
mkdir -p ~/.config/autostart
ln -sf "$DOTFILES/config/autostart/polybar.desktop" ~/.config/autostart/

# xdg-terminals
mkdir -p ~/.config
cat > ~/.config/xdg-terminals.list << 'TERM'
alacritty.desktop
xfce4-terminal.desktop
foot.desktop
TERM

# ------ Theme ------
echo "=== Installing Everforest GTK theme ==="
mkdir -p ~/.themes
if [ ! -d ~/.themes/Everforest ]; then
  curl -sL https://github.com/theorytoe/everforest-gtk/releases/latest/download/Everforest.tar.xz \
    | tar -xJ -C ~/.themes/
fi

# ------ Fonts ------
echo "=== Restoring font cache ==="
fc-cache -f

# ------ Neovim ------
echo "=== Installing Neovim ==="
if ! command -v nvim &>/dev/null; then
  if [ "$DISTRO" = "debian" ]; then
    curl -sL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage \
      -o ~/.local/bin/nvim && chmod +x ~/.local/bin/nvim
  fi
fi

# ------ Enable services (Arch) ------
if [ "$DISTRO" = "arch" ]; then
  echo "=== Enabling services ==="
  $SUDO systemctl enable lightdm.service 2>/dev/null || true
fi

# ------ Restore xfce settings (only if X is running) ------
if [ -n "${DISPLAY:-}" ]; then
  echo "=== Restoring xfce settings ==="
  bash "$DOTFILES/scripts/xfce-keybindings.sh" 2>/dev/null || true
  bash "$DOTFILES/scripts/xfce-settings.sh" 2>/dev/null || true
  xfwm4 --replace &>/dev/null &
  bash ~/.config/polybar/launch.sh 2>/dev/null || true
fi

echo ""
echo "=== Done! ==="
echo "Reboot (or startx/lightdm) and press Super+F1 for keybinding help."
