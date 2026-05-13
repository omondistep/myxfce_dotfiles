#!/bin/bash
# Restore xfce4-panel layout
set -euo pipefail

# Wait for XFCE to be ready
sleep 2

# Kill default panel
xfce4-panel --quit 2>/dev/null || true
sleep 1

# Set panel properties
xfconf-query -c xfce4-panel -n -p /panels/panel-0/position -t string -s "p=6;x=0;y=0"
xfconf-query -c xfce4-panel -n -p /panels/panel-0/position-locked -t bool -s true
xfconf-query -c xfce4-panel -n -p /panels/panel-0/length -t int -s 100
xfconf-query -c xfce4-panel -n -p /panels/panel-0/size -t int -s 32
xfconf-query -c xfce4-panel -n -p /panels/panel-0/autohide-behavior -t int -s 0
xfconf-query -c xfce4-panel -n -p /panels/panel-0/background-style -t int -s 0
xfconf-query -c xfce4-panel -n -p /panels/panel-0/enter-opacity -t int -s 1
xfconf-query -c xfce4-panel -n -p /panels/panel-0/leave-opacity -t int -s 1
xfconf-query -c xfce4-panel -n -p /panels/panel-0/nrows -t int -s 1
xfconf-query -c xfce4-panel -n -p /panels/panel-0/mode -t int -s 0

# Restart panel
xfce4-panel &
