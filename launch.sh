#!/usr/bin/bash

export FLUTTER_DRM_DEVICE=/dev/dri/$(basename $(readlink -f /sys/class/drm/*-DSI-1 | sed 's#.*/drm/\(card[0-9]*\)/.*#\1#'))

echo Using DRM device $FLUTTER_DRM_DEVICE

cd /home/pi/elinux-carpi/build/elinux/arm64/release/bundle

/home/pi/elinux-carpi/build/elinux/arm64/release/bundle/carpi -r 90 --no-cursor --force-scale-factor=2 -b /home/pi/elinux-carpi/build/elinux/arm64/release/bundle
