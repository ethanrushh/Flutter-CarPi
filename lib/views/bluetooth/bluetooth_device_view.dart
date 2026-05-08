
import 'package:bluez/bluez.dart';
import 'package:flutter/material.dart';
import 'package:carpi/dialog/confirmation_dialog.dart';
import 'package:carpi/service/bluetooth/bluetooth_connection_service.dart';

class BluetoothDeviceView extends StatefulWidget {
  final BlueZDevice device;

  const BluetoothDeviceView({super.key, required this.device});

  @override
  State<BluetoothDeviceView> createState() => _BluetoothDeviceViewState();
}

class _BluetoothDeviceViewState extends State<BluetoothDeviceView> {
  bool _acting = false;

  @override void initState() {
    
    super.initState();
  }

  @override void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _acting ? null : Navigator.of(context).pop, // disables the button
        ),
        actions: [
          if (_acting) Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator()
              ),
            )
          )
        ],
      ),
      body: ListView(
        
        children: [
          ListTile(
            dense: false,
            visualDensity: VisualDensity(vertical: 3),
            title: Text("Remove Device", style: TextStyle(color: !_acting ? null : Theme.of(context).disabledColor)),
            trailing: Icon(Icons.delete, color: !_acting ? null : Theme.of(context).disabledColor),
            onTap: () async {
              if (_acting) return;

              setState(() {
                _acting = true;
              });
              try {
                // Idiot protection
                if (!await showConfirmationDialog(title: 'Are you sure?', content: 'Are you sure you would like to remove ${widget.device.name}? \nYou will need to re-pair the device to connect again.', confirmationButtonText: 'Remove', context: context)) return;

                await BluetoothConnectionService.remove(widget.device);
                if (context.mounted && mounted) Navigator.of(context).pop();
              }
              finally {
                setState(() {
                  _acting = false;
                });
              }
            },
          ),

          ListTile(
            dense: false,
            visualDensity: VisualDensity(vertical: 3),
            title: Text("Disconnect Device", style: TextStyle(color: !widget.device.connected || _acting ? Theme.of(context).disabledColor : null)),
            trailing: Icon(Icons.link_off, color: !widget.device.connected || _acting ? Theme.of(context).disabledColor : null),
            onTap: widget.device.connected ? () async {
              if (_acting) return;

              setState(() {
                _acting = true;
              });
              try {
                await widget.device.disconnect();
                if (context.mounted && mounted) Navigator.of(context).pop();
              }
              finally {
                setState(() {
                  _acting = false;
                });
              }
            } : null
          ),

          ListTile(
            dense: false,
            visualDensity: VisualDensity(vertical: 3),
            title: Text("Connect Audio", style: TextStyle(color: widget.device.connected || _acting ? Theme.of(context).disabledColor : null)),
            trailing: Icon(Icons.music_note, color: widget.device.connected || _acting ? Theme.of(context).disabledColor : null),
            onTap: !widget.device.connected ? () async {
              if (_acting) return;

              setState(() {
                _acting = true;
              });
              try {
                await widget.device.connect();
                // await widget.device.connectProfile(BlueZUUID.fromString("0000110a-0000-1000-8000-00805f9b34fb"));
                // await widget.device.connectProfile(BlueZUUID.fromString("0000110d-0000-1000-8000-00805f9b34fb"));
                // await widget.device.connectProfile(BlueZUUID.fromString("0000110c-0000-1000-8000-00805f9b34fb"));
                // await widget.device.connectProfile(BlueZUUID.fromString("0000110e-0000-1000-8000-00805f9b34fb"));
                if (context.mounted && mounted) Navigator.of(context).pop();
              }
              finally {
                setState(() {
                  _acting = false;
                });
              }
            } : null
          )
        ],
      )
    );
  }
}
