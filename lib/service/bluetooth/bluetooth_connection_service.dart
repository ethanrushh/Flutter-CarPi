import 'dart:async';
import 'package:bluez/bluez.dart';
import 'dart:developer' as devtools show log;
import 'package:carpi/service/settings/global_settings_service.dart';

class DefaultFlutterAgent implements BlueZAgent {
  final BlueZClient _client;

  DefaultFlutterAgent({required BlueZClient client}) : _client = client;

  @override
  Future<BlueZAgentResponse> authorizeService(BlueZDevice device, BlueZUUID uuid) async {
    print('Authorizing service $uuid on ${device.name}');
    return BlueZAgentResponse.success();
  }

  @override
  Future<void> cancel() async {
    print('Pairing canceled');
  }

  @override
  Future<void> displayPasskey(BlueZDevice device, int passkey, int entered) async {
    print('Display passkey $passkey for ${device.name}, entered: $entered');
  }

  @override
  Future<BlueZAgentResponse> displayPinCode(BlueZDevice device, String pinCode) async {
    print('Display PIN $pinCode for ${device.name}');
    return BlueZAgentResponse.success();
  }

  @override
  Future<void> release() async {
    print('Agent released');
  }

  @override
  Future<BlueZAgentResponse> requestAuthorization(BlueZDevice device) async {
    print('Request authorization for ${device.name}');
    return BlueZAgentResponse.success();
  }

  @override
  Future<BlueZAgentResponse> requestConfirmation(BlueZDevice device, int passkey) async {
    print('Confirm passkey $passkey for ${device.name}');
    // Automatically accept for simplicity; you could show a dialog to the user here
    return BlueZAgentResponse.success();
  }

  @override
  Future<BlueZAgentPasskeyResponse> requestPasskey(BlueZDevice device) async {
    print('Request passkey for ${device.name}');
    // Return a default or prompt user via dialog in a real UI
    return BlueZAgentPasskeyResponse.success(0);
  }

  @override
  Future<BlueZAgentPinCodeResponse> requestPinCode(BlueZDevice device) async {
    print('Request PIN for ${device.name}');
    // Return default PIN or prompt user via dialog in a real UI
    return BlueZAgentPinCodeResponse.success("000000");
  }
}

class BluetoothConnectionService {
  static late final BlueZAdapter _adapter;
  static final _client = BlueZClient();

  static late final StreamController<List<BlueZDevice>> _devicesController;
  static Stream<List<BlueZDevice>> get onDeviceChange => _devicesController.stream;

  static final List<BlueZDevice> _devices = [];

  static bool get powered => _adapter.powered;

  static late final StreamController<bool> _powerChangedController;
  static Stream<bool> get onPowerChange => _powerChangedController.stream;

  static Future<void> initialize() async {
    _devicesController = StreamController<List<BlueZDevice>>.broadcast(
      onListen: () => _devicesController.add(List.unmodifiable(_devices))
    );

    await _client.connect();

    await _client.registerAgent(DefaultFlutterAgent(client: _client));

    _adapter = _client.adapters.first;

    _devices.addAll(_client.devices);

    _client.deviceAdded.listen((device) {
      print("Device ${device.name} added");

      _attachPropertyListener(device);
      if (!_devices.any((d) => d.address == device.address)) {
        _devices.add(device);
        _devicesController.add(List.unmodifiable(_devices));
      }
    });

    _powerChangedController = StreamController<bool>.broadcast();

    // Load initial state from settings
    final initialPowered = GlobalSettingsService.container.bluetoothSettings.bluetoothEnabled;
    if (initialPowered != _adapter.powered) {
      try {
        await _adapter.setPowered(initialPowered);
      }
      catch (e) {
        print("Failed to set bluetooth powered: $e");
      }
    }
    _powerChangedController.add(_adapter.powered);

    _client.deviceRemoved.listen((device) {
      print("Device ${device.name} removed");

      _devices.removeWhere((d) => d.address == device.address);
      _devicesController.add(List.unmodifiable(_devices));
    });

    for (var device in _client.devices) {
      _attachPropertyListener(device);
    }
  }

  static Future<void> ensurePowered() async {
    if (!_adapter.powered) await _adapter.setPowered(true);
  }

  static void _attachPropertyListener(BlueZDevice device) {
    device.propertiesChanged.listen((changed) {
      if (changed.contains('Paired') || changed.contains('Connected')) {
        _devicesController.add(List.unmodifiable(_devices));
      }
    });
  }

  static Future<void> setDiscoverable(bool discoverable) async {
    await _adapter.setDiscoverable(discoverable);
    await _adapter.setPairable(discoverable);
  }
  static Future<void> setScanning(bool scan) async {
    if (scan) {
      //await _adapter.setDiscoveryFilter(uuids: ['0000110b-0000-1000-8000-00805f9b34fb'], );
      await _adapter.startDiscovery();
      print("Starting discovery");
    } else {
      await _adapter.stopDiscovery();
      print("Stopping discovery");
    }
  }

  static Future<void> remove(BlueZDevice device) async {
    await _adapter.removeDevice(device);
  }

  static Future<void> setPowered(bool powered) async {
    try {
      await _adapter.setPowered(powered);
      GlobalSettingsService.container.bluetoothSettings.bluetoothEnabled = powered;
      await GlobalSettingsService.notifyChanged();
      _powerChangedController.add(powered);

      print("Set powered to $powered for bluetooth and saved.");
    }
    catch (e) {
      print("Failed to set bluetooth powered: $e");
    }
  }

  static Future<void> dispose() async {
    try {
      //if (_adapter.powered) await _adapter.setPowered(false); <- This is no longer necessary as we have a toggle
      await _devicesController.close();
      await _powerChangedController.close();
      await _client.close();

      print("Closed bluetooth service");
    }
    catch (e) {
      print("Failed to dispose of bluetooth service $e");
    }
  }

  static bool isPhone(BlueZDevice device) {
    final cod = device.deviceClass;
    
    final major = (cod & 0x1F00) >> 8;
    return major == 0x02; // Phone major class
  }
}
