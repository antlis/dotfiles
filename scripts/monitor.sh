#!/bin/sh
if xrandr | grep -q "HDMI-2 connected"; then
    xrandr --output HDMI-2 --preferred --above eDP-1
else
    xrandr --output HDMI-2 --off
fi
