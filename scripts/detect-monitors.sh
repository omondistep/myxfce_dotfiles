#!/bin/bash
# Detect monitors, set up wallpaper, DPI scaling, and xfce backdrop
set -euo pipefail

if [ -z "${DISPLAY:-}" ]; then
    echo "No display detected, skipping monitor setup"
    exit 0
fi

BG="${1:-$HOME/.local/share/backgrounds/everforest.jpg}"
SCALE="${XFCE_SCALE:-auto}"

# ------ Detect monitors via xrandr ------
MONITORS=$(xrandr --query 2>/dev/null | grep " connected" || true)

if [ -z "$MONITORS" ]; then
    echo "No monitors detected via xrandr"
    exit 0
fi

echo "Detected monitors:"
echo "$MONITORS"

# ------ Identify primary and secondary ------
PRIMARY=$(echo "$MONITORS" | grep " primary " | head -1 | awk '{print $1}')
[ -z "$PRIMARY" ] && PRIMARY=$(echo "$MONITORS" | head -1 | awk '{print $1}')
SECONDARY=$(echo "$MONITORS" | grep -v " primary " | awk '{print $1}' | head -1)

echo "Primary: $PRIMARY"
[ -n "$SECONDARY" ] && echo "Secondary: $SECONDARY"

# ------ Get resolution and DPI ------
get_resolution() {
    local mon="$1"
    echo "$MONITORS" | grep "^$mon " | grep -oP '\d+x\d+' | head -1
}

get_dpi() {
    local mon="$1"
    local info=$(xrandr --query 2>/dev/null | grep "^$mon connected" | head -1)
    local mm=$(echo "$info" | grep -oP '\d+mm x \d+mm' | head -1 || true)
    local res=$(get_resolution "$mon")

    if [ -n "$mm" ] && [ -n "$res" ]; then
        local w_mm=$(echo "$mm" | awk '{print $1}')
        local h_mm=$(echo "$mm" | awk '{print $3}')
        local w_px=$(echo "$res" | cut -d'x' -f1)
        local h_px=$(echo "$res" | cut -d'x' -f2)
        local dpi_w=$(( w_px * 254 / w_mm / 10 ))
        local dpi_h=$(( h_px * 254 / h_mm / 10 ))
        echo $(( (dpi_w + dpi_h) / 2 ))
    else
        echo 96
    fi
}

PRI_RES=$(get_resolution "$PRIMARY")
PRI_DPI=$(get_dpi "$PRIMARY")

echo "Primary resolution: $PRI_RES"
echo "Primary DPI: $PRI_DPI"

# ------ Determine scaling factor ------
if [ "$SCALE" = "auto" ]; then
    if [ "$PRI_DPI" -ge 192 ]; then
        SCALE=2
    elif [ "$PRI_DPI" -ge 144 ]; then
        SCALE=1.5
    else
        SCALE=1
    fi
fi

echo "Scale factor: ${SCALE}x"

# ------ Set wallpaper on all monitors/workspaces ------
if [ -f "$BG" ]; then
    xfconf-query -c xfce4-desktop -n -p /backdrop/singlescreen -t bool -s false 2>/dev/null || true

    for mon in $PRIMARY $SECONDARY; do
        [ -z "$mon" ] && continue
        for ws in $(seq 0 5); do
            prop="/backdrop/screen0/monitor${mon}/workspace${ws}/last-image"
            xfconf-query -c xfce4-desktop -n -p "$prop" -t string -s "$BG" 2>/dev/null || true
            prop="/backdrop/screen0/monitor${mon}/workspace${ws}/image-style"
            xfconf-query -c xfce4-desktop -n -p "$prop" -t int -s 5 2>/dev/null || true
        done
    done
else
    xfconf-query -c xfce4-desktop -n -p /backdrop/singlescreen -t bool -s true 2>/dev/null || true
    for mon in $PRIMARY $SECONDARY; do
        [ -z "$mon" ] && continue
        for ws in $(seq 0 5); do
            prop="/backdrop/screen0/monitor${mon}/workspace${ws}/color-style"
            xfconf-query -c xfce4-desktop -n -p "$prop" -t int -s 0 2>/dev/null || true
            prop="/backdrop/screen0/monitor${mon}/workspace${ws}/rgba1"
            xfconf-query -c xfce4-desktop -n -p "$prop" -t double -s 45 -t double -s 53 -t double -s 59 -t double -s 1 2>/dev/null || true
        done
    done
fi

# ------ Apply DPI-based font scaling ------
if [ "$SCALE" != "1" ]; then
    BASE=11
    FONT_SIZE=$(( BASE * SCALE ))
    MONO_SIZE=$(( BASE * SCALE - 1 ))

    echo "Setting font size to $FONT_SIZE (${SCALE}x scale)"

    xfconf-query -c xsettings -n -p /Gtk/FontName -t string -s "JetBrains Mono $FONT_SIZE" 2>/dev/null || true
    xfconf-query -c xsettings -n -p /Gtk/MonospaceFontName -t string -s "JetBrains Mono $MONO_SIZE" 2>/dev/null || true

    # Xresources DPI
    if command -v xrdb &>/dev/null; then
        echo "Xft.dpi: $(( PRI_DPI * SCALE / 2 ))" | xrdb -merge 2>/dev/null || true
    fi
fi

# ------ Configure xfce4 display for multi-monitor ------
if [ -n "$SECONDARY" ]; then
    sec_res=$(get_resolution "$SECONDARY")
    echo "Setting up multi-monitor: $PRIMARY + $SECONDARY"
    # Place secondary to the right of primary
    xrandr --output "$PRIMARY" --auto --output "$SECONDARY" --auto --right-of "$PRIMARY" 2>/dev/null || true
else
    echo "Single monitor setup: $PRIMARY"
    xrandr --output "$PRIMARY" --auto 2>/dev/null || true
fi

echo "Monitor setup complete"
