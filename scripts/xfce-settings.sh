#!/bin/bash
# Restore xfce4 settings

# Workspace names
xfconf-query -c xfwm4 -n -p /general/workspace_count -t int -s 6
xfconf-query -c xfwm4 -n -p /general/workspace_names -t string -s "1" -t string -s "2" -t string -s "3" -t string -s "4" -t string -s "5" -t string -s "6"

# GTK theme
xfconf-query -c xsettings -n -p /Net/ThemeName -t string -s "Everforest"
xfconf-query -c xsettings -n -p /Net/IconThemeName -t string -s "Papirus-Dark"
xfconf-query -c xsettings -n -p /Gtk/CursorThemeName -t string -s "catppuccin-latte-mauve-cursors"
xfconf-query -c xsettings -n -p /Gtk/FontName -t string -s "JetBrains Mono 11"
xfconf-query -c xsettings -n -p /Gtk/MonospaceFontName -t string -s "JetBrains Mono 10"

# WM theme
xfconf-query -c xfwm4 -n -p /general/theme -t string -s "Everforest"

# Default terminal - Alacritty
mkdir -p ~/.config/xdg-terminals.list 2>/dev/null
cat > ~/.config/xdg-terminals.list << 'TERMEOF'
alacritty.desktop
kitty.desktop
xfce4-terminal.desktop
foot.desktop
TERMEOF

# Wallpaper
BG="$HOME/.local/share/backgrounds/everforest.jpg"
if [ -f "$BG" ]; then
  # Set for all monitors and workspaces
  for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "last-image" || true); do
    xfconf-query -c xfce4-desktop -n -p "$prop" -t string -s "$BG" 2>/dev/null || true
  done
fi
