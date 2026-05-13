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
echo "=== Installing packages ==="
bash "$DOTFILES/scripts/install-packages.sh" "$DISTRO" "$SUDO"

# ------ Link configs ------
echo "=== Linking configs ==="
mkdir -p ~/.config ~/.local/bin ~/.fonts ~/.local/share/backgrounds ~/.local/share/icons

ln -sf "$DOTFILES/.xbindkeysrc" ~/
ln -sf "$DOTFILES/.bashrc" ~/

mkdir -p ~/.config/alacritty ~/.config/foot ~/.config/fontconfig \
  ~/.config/gtk-3.0 ~/.config/polybar ~/.config/rofi \
  ~/.config/xfce4/terminal ~/.config/dunst ~/.config/picom \
  ~/.config/tmux ~/.config/kitty ~/.config/conky ~/.config/zsh \
  ~/.config/Thunar ~/.config/xfce4/panel

ln -sf "$DOTFILES/config/alacritty/alacritty.toml" ~/.config/alacritty/
ln -sf "$DOTFILES/config/foot/foot.ini" ~/.config/foot/
ln -sf "$DOTFILES/config/fontconfig/fonts.conf" ~/.config/fontconfig/
ln -sf "$DOTFILES/config/gtk-3.0/gtk.css" ~/.config/gtk-3.0/
ln -sf "$DOTFILES/config/gtk-3.0/settings.ini" ~/.config/gtk-3.0/
ln -sf "$DOTFILES/config/starship.toml" ~/.config/starship.toml
mkdir -p ~/.config/opencode
ln -sf "$DOTFILES/config/opencode/opencode.json" ~/.config/opencode/
ln -sf "$DOTFILES/config/polybar/config.ini" ~/.config/polybar/
ln -sf "$DOTFILES/config/polybar/launch.sh" ~/.config/polybar/
ln -sf "$DOTFILES/config/rofi/config.rasi" ~/.config/rofi/
ln -sf "$DOTFILES/config/xfce4-terminal/terminalrc" ~/.config/xfce4/terminal/
ln -sf "$DOTFILES/config/dunst/dunstrc" ~/.config/dunst/
ln -sf "$DOTFILES/config/picom/picom.conf" ~/.config/picom/
ln -sf "$DOTFILES/config/tmux/tmux.conf" ~/.config/tmux/
ln -sf "$DOTFILES/config/kitty/kitty.conf" ~/.config/kitty/
ln -sf "$DOTFILES/config/conky/conky.conf" ~/.config/conky/
ln -sf "$DOTFILES/config/zsh/.zshrc" ~/.config/zsh/
ln -sf "$DOTFILES/config/Thunar/uca.xml" ~/.config/Thunar/
ln -sf "$DOTFILES/config/xfce4/panel/whiskermenu-1.rc" ~/.config/xfce4/panel/
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

# Zsh symlink (home .zshrc -> config)
ln -sf "$DOTFILES/config/zsh/.zshrc" ~/.zshrc 2>/dev/null || true

# xdg-terminals
cat > ~/.config/xdg-terminals.list << 'TERM'
alacritty.desktop
kitty.desktop
xfce4-terminal.desktop
foot.desktop
TERM

# ------ Theme ------
echo "=== Installing Everforest GTK theme ==="
mkdir -p ~/.themes
if [ ! -d ~/.themes/Everforest ]; then
  git clone --depth 1 https://github.com/theorytoe/everforest-gtk.git /tmp/everforest-gtk \
    && cp -r /tmp/everforest-gtk/* ~/.themes/Everforest/ \
    && rm -rf /tmp/everforest-gtk
fi

# ------ Fonts ------
echo "=== Installing Nerd Font (Debian) ==="
if [ "$DISTRO" = "debian" ]; then
  bash "$DOTFILES/scripts/install-fonts.sh"
fi

echo "=== Installing Catppuccin cursor theme ==="
bash "$DOTFILES/scripts/install-cursor.sh" || true

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

# ------ OpenCode CLI ------
echo "=== Installing OpenCode CLI ==="
if ! command -v opencode &>/dev/null; then
  curl -fsSL https://opencode.ai/install | bash
fi

# ------ Gemini CLI ------
if command -v node &>/dev/null; then
  echo "=== Installing Gemini CLI ==="
  npm install -g @google/gemini-cli 2>/dev/null || true
fi

# ------ Enable services (Arch) ------
if [ "$DISTRO" = "arch" ]; then
  echo "=== Enabling services ==="
  $SUDO systemctl enable lightdm.service 2>/dev/null || true
  $SUDO systemctl enable NetworkManager.service 2>/dev/null || true
fi

# ------ Restore xfce settings (only if X is running) ------
if [ -n "${DISPLAY:-}" ]; then
  echo "=== Restoring xfce settings ==="
  bash "$DOTFILES/scripts/xfce-keybindings.sh" 2>/dev/null || true
  bash "$DOTFILES/scripts/xfce-settings.sh" 2>/dev/null || true
  bash "$DOTFILES/scripts/xfce-panel.sh" 2>/dev/null || true
  bash "$DOTFILES/scripts/detect-monitors.sh" 2>/dev/null || true
  xfwm4 --replace &>/dev/null &
  bash ~/.config/polybar/launch.sh 2>/dev/null || true
fi

echo ""
echo "=== Done! ==="
echo "Reboot (or startx/lightdm) and press Super+F1 for keybinding help."
