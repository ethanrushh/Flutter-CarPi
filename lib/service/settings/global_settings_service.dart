import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:developer' as devtools show log;

import 'package:carpi/service/gpio/gpio_service.dart';

class GlobalSettingsService {
  static late final File _settingsJsonFile;
  static late final SettingsContainer container;

  static final StreamController<SettingsContainer> _containerChangedController =
      StreamController.broadcast();

  static Stream<SettingsContainer> get onContainerChanged =>
      _containerChangedController.stream;

  static Future<void> initialize() async {
    // Save on shutdown
    GpioPowerService.registerShutdownProcedure(() async {
      await save();
    });

    final home = Platform.environment['HOME'];
    if (home == null) {
      throw 'No HOME env var is set. Cannot determine settings location.';
    }

    _settingsJsonFile = File(path.join(home, '.config', 'carpi', 'settings.json'));

    await _load();

    print('Loaded settings from ${_settingsJsonFile.absolute.path}');
  }

  static Future<void> _load() async {
    if (!await _settingsJsonFile.exists()) {
      await _createDefault();
    }

    final jsonString = await _settingsJsonFile.readAsString();
    Map<String, dynamic> jsonMap;
    try {
      jsonMap = jsonDecode(jsonString);
    } catch (_) {
      // Invalid JSON, recreate
      await _createDefault();
      jsonMap = jsonDecode(await _settingsJsonFile.readAsString());
    }

    // Check for missing top-level properties
    final requiredKeys = ['displaySettings', 'soundSettings', 'bluetoothSettings', 'personalisationSettings'];
    bool missingKey = requiredKeys.any((key) => !jsonMap.containsKey(key));

    if (missingKey) {
      print('Missing settings keys detected. Merging defaults...');
      final defaultContainer = SettingsContainer.generateDefault();
      final defaultJson = defaultContainer.toJson();

      for (final key in requiredKeys) {
        if (!jsonMap.containsKey(key)) {
          jsonMap[key] = defaultJson[key];
        }
      }

      // Save the merged version
      await _settingsJsonFile.writeAsString(jsonEncode(jsonMap));
    }

    container = SettingsContainer.fromJson(jsonMap);

    print('Loaded settings at ${_settingsJsonFile.absolute.path}');
  }

  static Future<void> _createDefault() async {
    final container = SettingsContainer.generateDefault();

    await _settingsJsonFile.parent.create(recursive: true);
    await _settingsJsonFile.writeAsString(jsonEncode(container));
  }

  static Future<void> save() async {
    final jsonString = jsonEncode(container.toJson());

    await _settingsJsonFile.parent.create(recursive: true);
    await _settingsJsonFile.writeAsString(jsonString);

    print('Saved settings to ${_settingsJsonFile.absolute.path}');
  }

  static Future<void> notifyChanged() async {
    await save(); // TODO This should only happen when we actually want it to. This is a little aggressive and is going to cause jank.
    _containerChangedController.add(container);
  }
}

// ---------------- Settings container ----------------

class SettingsContainer {
  late DisplaySettings displaySettings;
  late SoundSettings soundSettings;
  late BluetoothSettings bluetoothSettings;
  late PersonalisationSettings personalisationSettings;

  SettingsContainer();

  factory SettingsContainer.generateDefault() {
    final container = SettingsContainer();
    container.displaySettings = DisplaySettings.generateDefault();
    container.soundSettings = SoundSettings.generateDefault();
    container.bluetoothSettings = BluetoothSettings.generateDefault();
    container.personalisationSettings = PersonalisationSettings.generateDefault();
    return container;
  }

  Map<String, dynamic> toJson() => {
        'displaySettings': displaySettings.toJson(),
        'soundSettings': soundSettings.toJson(),
        'bluetoothSettings': bluetoothSettings.toJson(),
        'personalisationSettings': personalisationSettings.toJson()
      };

  factory SettingsContainer.fromJson(Map<String, dynamic> json) =>
      SettingsContainer()
        ..displaySettings = DisplaySettings.fromJson(json['displaySettings'])
        ..soundSettings = SoundSettings.fromJson(json['soundSettings'])
        ..bluetoothSettings = BluetoothSettings.fromJson(json['bluetoothSettings'])
        ..personalisationSettings = PersonalisationSettings.fromJson(json['personalisationSettings']);
}

// ---------------- Bluetooth settings ----------------

class BluetoothSettings {
  late bool bluetoothEnabled;

  BluetoothSettings();

  factory BluetoothSettings.generateDefault() {
    final settings = BluetoothSettings();
    settings.bluetoothEnabled = true;
    return settings;
  }

  Map<String, dynamic> toJson() => {
        'bluetoothEnabled': bluetoothEnabled,
      };

  factory BluetoothSettings.fromJson(Map<String, dynamic> json) =>
      BluetoothSettings()
        ..bluetoothEnabled = json['bluetoothEnabled'] as bool;
}

// ---------------- Sound settings ----------------

class SoundSettings {
  late EqualizerSettings equalizer;

  SoundSettings();

  factory SoundSettings.generateDefault() {
    final settings = SoundSettings();
    settings.equalizer = EqualizerSettings.generateDefault();
    return settings;
  }

  Map<String, dynamic> toJson() => {
        'equalizer': equalizer.toJson(),
      };

  factory SoundSettings.fromJson(Map<String, dynamic> json) =>
      SoundSettings()
        ..equalizer = EqualizerSettings.fromJson(json['equalizer']);
}

// ---------------- Equalizer settings ----------------

class EqualizerSettings {
  late List<double> bands;

  EqualizerSettings();

  factory EqualizerSettings.generateDefault() {
    final eq = EqualizerSettings();
    eq.bands = List.filled(10, 0.0);
    return eq;
  }

  Map<String, dynamic> toJson() => {
        'bands': bands,
      };

  factory EqualizerSettings.fromJson(Map<String, dynamic> json) =>
      EqualizerSettings()
        ..bands = (json['bands'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
}

// ---------------- Display settings ----------------

enum BrightnessMode { auto, dim, bright }

class DisplaySettings {
  late BrightnessMode brightnessMode;

  DisplaySettings();

  factory DisplaySettings.generateDefault() {
    final displaySettings = DisplaySettings();
    displaySettings.brightnessMode = BrightnessMode.auto;
    return displaySettings;
  }

  Map<String, dynamic> toJson() => {
        'brightnessMode': brightnessMode.name,
      };

  factory DisplaySettings.fromJson(Map<String, dynamic> json) =>
      DisplaySettings()
        ..brightnessMode = BrightnessMode.values.firstWhere((e) => e.name == json['brightnessMode']);
}

class PersonalisationSettings {
  late String wallpaper;

  PersonalisationSettings();

  factory PersonalisationSettings.generateDefault() {
    final displaySettings = PersonalisationSettings();
    displaySettings.wallpaper = 'assets/img/bg/mountains.jpg';
    return displaySettings;
  }

  Map<String, dynamic> toJson() => {
        'wallpaperAssetUri': wallpaper,
      };

  factory PersonalisationSettings.fromJson(Map<String, dynamic> json) =>
      PersonalisationSettings()
        ..wallpaper = json['wallpaperAssetUri'] as String;
}
