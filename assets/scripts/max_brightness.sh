#!/usr/bin/env bash
for backlight in /sys/class/backlight/*; do
    max=$(cat "$backlight/max_brightness")
    echo "$max" | sudo tee "$backlight/brightness" > /dev/null
done
