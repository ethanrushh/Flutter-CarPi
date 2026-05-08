import 'dart:async';
import 'dart:developer' as devtools show log;
import 'package:bluez/bluez.dart';
import 'package:flutter/material.dart';
import 'package:carpi/service/bluetooth/bluetooth_connection_service.dart';

class BluetoothPairingView extends StatefulWidget {
  const BluetoothPairingView({super.key});

  @override
  State<BluetoothPairingView> createState() => _BluetoothPairingViewState();
}

class _BluetoothPairingViewState extends State<BluetoothPairingView> {
  late final Future<void> setDiscoveryFuture;
  late StreamSubscription _devicesSubscription;
  late List<BlueZDevice> _unpairedDevices = [];

  BlueZDevice? _pairingDevice;
  
  @override
  void initState() {
    _devicesSubscription = BluetoothConnectionService.onDeviceChange.listen((devices) {
      if (mounted) {
        setState(() { _unpairedDevices = devices.where((device) => !device.paired && device.name.isNotEmpty && BluetoothConnectionService.isPhone(device)).toList(); });
      } else {
        _unpairedDevices = devices.where((device) => !device.paired && device.name.isNotEmpty && BluetoothConnectionService.isPhone(device)).toList();
      }
    });
    setDiscoveryFuture = BluetoothConnectionService.setScanning(true);
    super.initState();
  }

  @override
  void dispose() {
    _devicesSubscription.cancel();
    BluetoothConnectionService.setScanning(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pair Device"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _pairingDevice != null ? null : Navigator.of(context).pop, // disables the button
        ),
      ),
      body: FutureBuilder(
        future: setDiscoveryFuture,
        builder:(context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return ListView.builder(
                itemCount: _unpairedDevices.length + 1,
                itemBuilder: (context, index) {
                  if (index < _unpairedDevices.length) {
                    return ListTile(
                      dense: false,
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(_unpairedDevices[index].name),
                      onTap: () async {
                        if (_pairingDevice != null) return;
      
                        setState(() {
                          _pairingDevice = _unpairedDevices[index];
                        });
      
                        try {
                          final device = _pairingDevice!; // I really hate dart sometimes :(
      
                          await device.setTrusted(true);
                          print('Trusted ${device.address} (${device.name})');
                          await device.pair();
                          print('Paired ${device.address} (${device.name})');
                          await device.connect();
                          print('Connected ${device.address} (${device.name})');
      
                          if (context.mounted) Navigator.of(context).pop();
                        }
                        finally {
                          setState(() {
                            _pairingDevice = null;
                          });
                        }
                      },
                      leading: const Icon(Icons.phone_android),
                      trailing: 
                        _pairingDevice != null && _pairingDevice!.address == _unpairedDevices[index].address 
                        ? CircularProgressIndicator() 
                        : const Icon(Icons.add_link),
                    );
                  }
                  else if (_pairingDevice == null) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 20,
                          children: [
                            const CircularProgressIndicator(),
                            const Text("Searching for devices")
                          ]
                        ),
                      ),
                    );
                  }
                }
              );
      
            default: return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
