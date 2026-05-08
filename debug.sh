#!/usr/bin/bash

DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/host/var/run/dbus/system_bus_socket flutter-elinux run -d elinux-wayland --debug --disable-service-auth-codes --device-vmservice-port=12345 --host-vmservice-port=42771
