import 'dart:async';
import 'package:animations/animations.dart';
import 'package:bluez/bluez.dart';
import 'package:flutter/material.dart';
import 'package:carpi/service/bluetooth/bluetooth_connection_service.dart';
import 'package:carpi/views/bluetooth/bluetooth_device_view.dart';
import 'package:carpi/views/bluetooth/bluetooth_pairing_view.dart';

class BluetoothView extends StatefulWidget {
  const BluetoothView({super.key});

  @override
  State<BluetoothView> createState() => _BluetoothViewState();
}

class _BluetoothViewState extends State<BluetoothView> {
  late StreamSubscription _devicesSubscription;
  late StreamSubscription _powerSubscription;
  late List<BlueZDevice> _pairedDevices = [];

  @override
  void initState() {
    _devicesSubscription = BluetoothConnectionService.onDeviceChange.listen((devices) {
      if (mounted) {
        setState(() { _pairedDevices = devices.where((device) => device.paired).toList(); });
      } else {
        _pairedDevices = devices.where((device) => device.paired).toList();
      }
    });

    _powerSubscription = BluetoothConnectionService.onPowerChange.listen((powered) {
      if (mounted) {
        setState(() { _bluetoothEnabled = powered; });
      }
    });

    _bluetoothEnabled = BluetoothConnectionService.powered;

    super.initState();
  }

  @override
  void dispose() {
    _devicesSubscription.cancel();
    _powerSubscription.cancel();
    super.dispose();
  }

  bool _lockBluetooth = false;
  bool _bluetoothEnabled = false;
  Future<void> toggleBluetooth(bool value) async {
    setState(() {
      _lockBluetooth = true;
    });

    try {
      await BluetoothConnectionService.setPowered(value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle Bluetooth: $e')),
        );
      }
    }
    finally {
      if (mounted) {
        setState(() {
          _lockBluetooth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Switch(value: _bluetoothEnabled, onChanged: _lockBluetooth ? null : toggleBluetooth),
            ),
          )
        ],
      ),
      body: !_bluetoothEnabled ? 
        Center(
          child: Text("Bluetooth is disabled", style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).disabledColor
          ),)
        ) 
        : 
        ListView.builder(
          itemCount: _pairedDevices.length + 1,
          itemBuilder: (context, index) {
            if (index < _pairedDevices.length) {
              return ListTile(
                dense: false,
                visualDensity: VisualDensity(vertical: 3),
                title: Text(_pairedDevices[index].name),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => BluetoothDeviceView(device: _pairedDevices[index]),
                      transitionsBuilder: (_, animation, secondaryAnimation, child) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    if (_pairedDevices[index].connected && _pairedDevices[index].uuids.contains(BlueZUUID.fromString("0000110a-0000-1000-8000-00805f9b34fb"))) const Icon(Icons.music_note),
                    if (_pairedDevices[index].connected) const Icon(Icons.bluetooth_connected),
                    const Icon(Icons.link),
                  ],
                ),
              );
            }
            else {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) => BluetoothPairingView(),
                          transitionsBuilder: (_, animation, secondaryAnimation, child) {
                            return SharedAxisTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType: SharedAxisTransitionType.horizontal,
                              child: child,
                            );
                          },
                        ),
                      );
                    }, 
                    icon: const Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                      child: Icon(Icons.add, size: 24*1.5,),
                    ),
                    label: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: Text(
                        "Pair Device",
                        textScaler: TextScaler.linear(1.5),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
      )
    );
  }
}
