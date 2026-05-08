#!/usr/bin/bash

set -o pipefail

export PATH=$PATH:/opt/flutter-elinux/bin
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/host/var/run/dbus/system_bus_socket
