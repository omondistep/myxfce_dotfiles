#!/bin/bash
killall xfce4-panel 2>/dev/null
killall polybar 2>/dev/null
while pgrep -x polybar >/dev/null; do sleep 0.5; done

# Auto-detect wireless interface
WIFI_IFACE=$(ls /sys/class/net/ 2>/dev/null | grep -E '^wl' | head -1)
[ -z "$WIFI_IFACE" ] && WIFI_IFACE=$(ls /sys/class/net/ 2>/dev/null | grep -v lo | head -1)
export WIFI_IFACE

# Create temporary config with correct interface
TMP_CONFIG="/tmp/polybar-config-${USER}.ini"
sed "s/interface = wlan0/interface = ${WIFI_IFACE}/" ~/.config/polybar/config.ini > "$TMP_CONFIG"
polybar top -c "$TMP_CONFIG" 2>&1 &

killall xbindkeys 2>/dev/null
xbindkeys &

killall xfce4-clipman 2>/dev/null
xfce4-clipman &

killall dunst 2>/dev/null
dunst &

killall picom 2>/dev/null
picom -b 2>/dev/null &

killall nm-applet 2>/dev/null
nm-applet &

killall conky 2>/dev/null
sleep 1 && conky -q -c ~/.config/conky/conky.conf &
