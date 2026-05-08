#!/usr/bin/env bash
for backlight in /sys/class/backlight/*; do
    echo 30 | sudo tee "$backlight/brightness" > /dev/null
done
