#!/usr/bin/bash

cd /home/pi/elinux-carpi && git fetch origin && git reset --hard origin/main && ./build.sh && sudo reboot
