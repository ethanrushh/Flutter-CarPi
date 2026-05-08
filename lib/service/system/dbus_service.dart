import 'dart:async';
import 'package:dbus/dbus.dart';
import 'package:carpi/service/io/audio_browser_service.dart';
import 'package:carpi/service/system/bluez_media_player1.dart';
import 'dart:developer' as devtools show log;
import 'package:logging/logging.dart';

class BluetoothAvrcpService {
  static late final DBusClient _client;

  static BlueZMediaPlayer1Remote? _activeDevice;
  static late final StreamController<BlueZMediaPlayer1Remote?> _activeDeviceController;
  static Stream<BlueZMediaPlayer1Remote?> get onDeviceChanged => _activeDeviceController.stream;

  static Duration _currentPosition = Duration.zero;
  static late final StreamController<Duration> _positionUpdatedController;
  static Stream<Duration> get onPositionChanged => _positionUpdatedController.stream;

  static TrackMetadata _lastMetadata = TrackMetadata.empty();
  static late final StreamController<TrackMetadata> _metadataController;
  static Stream<TrackMetadata> get onMetadataChanged => _metadataController.stream;

  static Duration _currentDuration = Duration.zero;
  static late final StreamController<Duration> _durationUpdatedController;
  static Stream<Duration> get onDurationChanged => _durationUpdatedController.stream;

  static bool _isPlaying = false;
  static late final StreamController<bool> _playingChangedController;
  static Stream<bool> get onIsPlayingChanged => _playingChangedController.stream;

  
  static Future<void> initialize() async {
    _client = DBusClient.system();
    
    _positionUpdatedController = StreamController<Duration>.broadcast(onListen: () { _positionUpdatedController.add(_currentPosition); });
    _metadataController = StreamController<TrackMetadata>.broadcast(onListen: () { _metadataController.add(_lastMetadata); });
    _durationUpdatedController = StreamController<Duration>.broadcast(onListen: () { _durationUpdatedController.add(_currentDuration); });
    _playingChangedController = StreamController<bool>.broadcast(onListen: () { _playingChangedController.add(_isPlaying); });

    final interfacesAdded = DBusSignalStream(
      _client,
      sender: 'org.bluez',
      interface: 'org.freedesktop.DBus.ObjectManager',
      name: 'InterfacesAdded',
    );

    interfacesAdded.listen((signal) {
      final path = signal.values[0].asObjectPath();

      final interfaces =
          signal.values[1].asDict().map((key, value) {
            return MapEntry(
              key.asString(),
              value.asDict(),
            );
          });

      if (interfaces.containsKey('org.bluez.MediaPlayer1')) {
        // if (_activeDevice != null) {
        //   print('A device was added, but one already exists. Something has gone wrong.');
        //   return;
        // }
        //else {
        print("Detected and added device ${path.value}");

        final device = BlueZMediaPlayer1Remote(
          _client,
          'org.bluez',
          path,
        );
        _activeDevice = device;
        _activeDeviceController.add(_activeDevice);
        
        // Notify when properties get updated
        device.propertiesChanged.listen((props) {
          for (final propKey in props.changedProperties.keys) {
            final prop = props.changedProperties[propKey];

            if (prop == null) {
              continue;
            }

            switch (propKey) {
              case 'Status':
                switch (prop.asString()) {
                  case 'playing':
                    _isPlaying = true;
                    _playingChangedController.add(_isPlaying);
                    break;
                  case 'paused':
                    _isPlaying = false;
                    _playingChangedController.add(_isPlaying);
                    break;

                  default: break;
                }
                break;

              case 'Track':
                final trackInfo = prop.asStringVariantDict();

                _lastMetadata = TrackMetadata(trackInfo['Title']?.asString(), null, trackInfo['Artist']?.asString(), null, true, Duration(milliseconds: trackInfo['Duration']?.asUint32() ?? 0));
                _metadataController.add(_lastMetadata);

                _currentDuration = _lastMetadata.duration;
                _durationUpdatedController.add(_currentDuration);

                break;

              case 'Position':
                final positionMs = prop.asUint32();
                _currentPosition = Duration(milliseconds: positionMs);
                _positionUpdatedController.add(_currentPosition);
                break;

              default:
                print(propKey);
                break;
            }
          }
        });
        //}
      }
    });

    final interfacesRemoved = DBusSignalStream(
      _client,
      sender: 'org.bluez',
      interface: 'org.freedesktop.DBus.ObjectManager',
      name: 'InterfacesRemoved',
    );

    interfacesRemoved.listen((signal) {
      final path = signal.values[0].asObjectPath();
      final interfaces = signal.values[1].asStringArray();

      if (interfaces.contains('org.bluez.MediaPlayer1')) {
        print("Device ${path.value} was removed");

        if (_activeDevice?.path.value == path.value) {
          print("Same device was previously set as the active device; removing.");

          _activeDevice = null;
          _activeDeviceController.add(_activeDevice);
        }
      }
    });

    _activeDeviceController = StreamController<BlueZMediaPlayer1Remote?>.broadcast(onListen: () {
      _activeDeviceController.add(_activeDevice);
    });
  }

  static Future<void> dispose() async {
    await _client.close();
  }
}
