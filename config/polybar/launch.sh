#!/bin/bash
killall xfce4-panel 2>/dev/null
killall polybar 2>/dev/null
while pgrep -x polybar >/dev/null; do sleep 0.5; done
polybar top 2>&1 &
killall xbindkeys 2>/dev/null
xbindkeys &
killall xfce4-clipman 2>/dev/null
xfce4-clipman &
