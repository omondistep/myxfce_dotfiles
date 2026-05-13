#!/bin/bash
# Script run by install.sh for each distro's packages
set -euo pipefail

DISTRO="$1"
SUDO="$2"

install_arch() {
  $SUDO pacman -Syu --noconfirm

  # Install pipewire first (before other audio packages)
  if ! command -v pipewire &>/dev/null; then
    $SUDO pacman -S --noconfirm --needed \
      pipewire pipewire-pulse pipewire-alsa wireplumber 2>/dev/null || true
  fi

  yes | $SUDO pacman -S --noconfirm --needed \
    base-devel git curl unzip \
    xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
    polybar rofi xbindkeys alacritty foot kitty \
    picom dunst tmux conky \
    ttf-jetbrains-mono-nerd papirus-icon-theme \
    starship maim xclip pavucontrol ranger \
    xfce4-clipman-plugin network-manager-applet \
    chromium noto-fonts-cjk noto-fonts-emoji \
    xdotool playerctl brightnessctl \
    xfce4-pulseaudio-plugin 2>/dev/null || true

  # i3lock-color from AUR
  if command -v yay &>/dev/null; then
    yay -S --noconfirm i3lock-color 2>/dev/null || true
  elif command -v paru &>/dev/null; then
    paru -S --noconfirm i3lock-color 2>/dev/null || true
  fi

  # Enable services
  $SUDO systemctl enable lightdm.service 2>/dev/null || true
  $SUDO systemctl enable NetworkManager.service 2>/dev/null || true
}

install_debian() {
  $SUDO apt update

  $SUDO apt purge -y lite-themes 2>/dev/null || true

  $SUDO apt install -y \
    polybar rofi xbindkeys xfce4-terminal alacritty kitty \
    papirus-icon-theme fonts-jetbrains-mono \
    starship foot \
    maim xclip pavucontrol ranger xfce4-clipman-plugin \
    surf curl git unzip \
    picom dunst tmux conky-all \
    network-manager-gnome \
    chromium-browser \
    fonts-noto-cjk fonts-noto-color-emoji \
    xdotool playerctl brightnessctl \
    xfce4-pulseaudio-plugin 2>/dev/null || true

  # Retry with --force-overwrite if papirus failed
  if ! dpkg -l papirus-icon-theme 2>/dev/null | grep -q "^ii"; then
    $SUDO apt install -y -o Dpkg::Options::="--force-overwrite" papirus-icon-theme
  fi

  # Remove bloat
  $SUDO apt purge -y tumbler libreoffice* firefox* 2>/dev/null || true
  $SUDO apt autoremove -y
}

case "$DISTRO" in
  arch)   install_arch ;;
  debian) install_debian ;;
esac
