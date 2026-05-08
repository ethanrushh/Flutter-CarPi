import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:carpi/service/io/audio_browser_service.dart';
import 'package:carpi/service/system/bluez_media_player1.dart';
import 'package:carpi/service/system/dbus_service.dart';
import 'package:carpi/util/can/can_interpreter.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

class AudioPlayerService {
  static final instance = AudioPlayerService();

  late LocalAudioPlayer _localPlayer;
  late BlueZMediaPlayer1Remote? _activeBluetoothRemote;

  bool get isBluetoothMode => _activeBluetoothRemote != null;

  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;
  bool _isPlaying = false;
  TrackMetadata _lastMetadata = TrackMetadata.empty();
  TrackMetadata get currentMetadata => _lastMetadata;

  late final StreamController<Duration> _positionUpdatedController;
  Stream<Duration> get onPositionChanged => _positionUpdatedController.stream;

  late final StreamController<Duration> _durationUpdatedController;
  Stream<Duration> get onDurationChanged => _durationUpdatedController.stream;

  late final StreamController<bool> _playingChangedController;
  Stream<bool> get onIsPlayingChanged => _playingChangedController.stream;

  late final StreamController<TrackMetadata> _metadataController;
  Stream<TrackMetadata> get onMetadataChanged => _metadataController.stream;

  Timer? _bluetoothPositionTicker;
  int _lastSyncedPositionMs = 0;
  DateTime _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> initialize() async {
    BluetoothAvrcpService.onDeviceChanged.listen((remote) async {
      _activeBluetoothRemote = remote;

      if (_activeBluetoothRemote != null) {
        await _localPlayer.stop();
      }

      _currentPosition = Duration.zero;
      _currentDuration = Duration.zero;
      _isPlaying = false;
      _lastMetadata = TrackMetadata.empty();

      _lastSyncedPositionMs = 0;
      _lastSyncTime = DateTime.now();

      _updateBluetoothTicker();

      _positionUpdatedController.add(_currentPosition);
      _durationUpdatedController.add(_currentDuration);
      _playingChangedController.add(_isPlaying);
      _metadataController.add(_lastMetadata);
    });

    BluetoothAvrcpService.onPositionChanged.listen((pos) {
      if (!isBluetoothMode) return;

      _currentPosition = pos;
      _lastSyncedPositionMs = pos.inMilliseconds;
      _lastSyncTime = DateTime.now();

      _positionUpdatedController.add(pos);
    });
    BluetoothAvrcpService.onDurationChanged.listen((duration) {
      if (!isBluetoothMode) return;

      _currentDuration = duration;
      _durationUpdatedController.add(duration);
    });
    BluetoothAvrcpService.onMetadataChanged.listen((meta) {
      if (!isBluetoothMode) return;

      _lastMetadata = meta;
      _metadataController.add(meta);
    });
    BluetoothAvrcpService.onIsPlayingChanged.listen((isPlaying) {
      if (!isBluetoothMode) return;

      _isPlaying = isPlaying;
      _lastSyncTime = DateTime.now();

      _playingChangedController.add(_isPlaying);
      _updateBluetoothTicker();
    });

    _positionUpdatedController = StreamController<Duration>.broadcast(onListen: () { _positionUpdatedController.add(_currentPosition); });
    _durationUpdatedController = StreamController<Duration>.broadcast(onListen: () { _durationUpdatedController.add(_currentDuration); });
    _playingChangedController = StreamController<bool>.broadcast(onListen: () { _playingChangedController.add(_isPlaying); });
    _metadataController = StreamController<TrackMetadata>.broadcast(onListen: () { _metadataController.add(_lastMetadata); });

    final localPlayer = LocalAudioPlayer();
    _localPlayer = localPlayer;

    // Forward events from the active player
    localPlayer.onPositionChanged.listen((pos) {
      if (isBluetoothMode) return;
      _currentPosition = pos;
      _positionUpdatedController.add(pos);
    });
    // localPlayer.onDurationChanged.listen((duration) {
    //   if (isBluetoothMode) return;
    //   _currentDuration = duration;
    //   _durationUpdatedController.add(duration);
    // });
    localPlayer.onIsPlayingChanged.listen((playing) {
      if (isBluetoothMode) return;
      _isPlaying = playing;
      _playingChangedController.add(playing);
    });
    localPlayer.onMetadataChanged.listen((newMeta) {
      if (isBluetoothMode) return;
      _lastMetadata = newMeta;
      _metadataController.add(newMeta);
    });

    MultiFunctionWheelControlsInterpreter.mfwButtonChanged.listen((key) {
      if (key == MfwButton.leftPadRight) {
        unawaited(next());
      }
      else if (key == MfwButton.leftPadLeft) {
        unawaited(previous());
      }
    });

    await localPlayer.initialize();
  }

  /// BlueZ will only send us synchronisation points for keeping the seek. We need to continue on our own when we are playing and not continue when we are not.
  void _updateBluetoothTicker() {
    final shouldRun = isBluetoothMode && _isPlaying;

    if (shouldRun && _bluetoothPositionTicker == null) {
      _bluetoothPositionTicker = Timer.periodic(const Duration(milliseconds: 16), (_) {
        final elapsed = DateTime.now().difference(_lastSyncTime).inMilliseconds;

        final posMs = _lastSyncedPositionMs + elapsed;
        _currentPosition = Duration(milliseconds: posMs);

        _positionUpdatedController.add(_currentPosition);
      });
    } else if (!shouldRun && _bluetoothPositionTicker != null) {
      _bluetoothPositionTicker!.cancel();
      _bluetoothPositionTicker = null;
    }
  }

  Future<void> next() async {
    try {
      if (isBluetoothMode) {
        await _activeBluetoothRemote!.callNext();
      }
      else {
        await _localPlayer.next();
      }
    }
    catch (e) {
      log('Failed to perform next(). See error.', error: e);
    }
  }

  Future<void> previous() async {
    try {
      if (isBluetoothMode) {
        await _activeBluetoothRemote!.callPrevious();
      }
      else {
        await _localPlayer.previous();
      }
    }
    catch (e) {
      log('Failed to perform previous(). See error.', error: e);
    }
  }

  Future<void> togglePause() async {
    try {
      final remote = _activeBluetoothRemote;

      if (remote != null) {
        final status = await remote.getStatus();
        switch (status) {
          case 'playing':
            await remote.callPause();
            break;

          case 'paused':
          case 'stopped':
            await remote.callPlay();
            break;

          default:
            break;
        }
      }
      else {
        await _localPlayer.togglePause();
      }
    }
    catch (e) {
      log('Failed to perform togglePause(). See error.', error: e);
    }
  }

  Future<void> selectTrack(String path) async {
    if (isBluetoothMode) {
      log('A track was selected, but we are supposed to be using a bluetooth device', level: Level.WARNING.value);
    }
    else {
      try {
        await _localPlayer.selectTrack(path);
      }
      catch (e) {
        log('Failed to perform selectTrack() with "$path". See error.', error: e);
      }
    }
  }
}

class LocalAudioPlayer {
  var _player = AudioPlayer();
  final Queue<String> _queue = Queue();
  bool _repeat = true;
  String? _currentTrack;

  String? get current => _currentTrack;

  void enqueue(String track) => _queue.addLast(track);
  void enqueueFirst(String track) => _queue.addFirst(track);

  final _positionUpdatedController = StreamController<Duration>.broadcast();
  Stream<Duration> get onPositionChanged => _positionUpdatedController.stream;

  final _durationUpdatedController = StreamController<Duration>.broadcast();
  Stream<Duration> get onDurationChanged => _durationUpdatedController.stream;

  final _isPlayingController = StreamController<bool>.broadcast();
  Stream<bool> get onIsPlayingChanged => _isPlayingController.stream;

  final _metadataController = StreamController<TrackMetadata>.broadcast();
  Stream<TrackMetadata> get onMetadataChanged => _metadataController.stream;

  Future<void> initialize() async {
    await renewAudioPlayer();
  }

  // Buffers seem to grow indefinately unless we re-create the player. This sucks bad, but its the workdaround still open on the GitHub.
  Future<void> renewAudioPlayer() async {
    await _player.dispose();
    _player = AudioPlayer();

    _player.onPlayerComplete.listen((_) async {
      if (_queue.isNotEmpty) await next();
    });
    _player.onPositionChanged.listen(_positionUpdatedController.add);
    _player.onDurationChanged.listen(_durationUpdatedController.add);
    _player.onPlayerStateChanged.listen((event) => _isPlayingController.add(event == PlayerState.playing));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> _playFile(String path) async {
    await renewAudioPlayer();

    await _player.setSource(DeviceFileSource(path));
    await _player.resume();

    _metadataController.add(await AudioBrowserService.instance.getTrackMetadataOrEmpty(path));
  }

  Future<void> next() async {
    final nextTrack = _queue.removeFirst();

    if (_currentTrack != null && _repeat) {
      _queue.addLast(_currentTrack!);
    }

    _currentTrack = nextTrack;

    await _playFile(nextTrack);

    final d = await _player.getDuration() ?? Duration.zero;
    _durationUpdatedController.add(d);
  }

  Future<void> previous() async {
    final pos = await _player.getCurrentPosition() ?? Duration.zero;

    if (pos.inSeconds >= 5) {
        await _player.seek(Duration.zero);
        return;
    }

    if (_queue.isEmpty || _currentTrack == null) return;

    final prevTrack = _queue.removeLast();

    _queue.addFirst(_currentTrack!);

    _currentTrack = prevTrack;

    await _playFile(prevTrack);

    final d = await _player.getDuration() ?? Duration.zero;
    _durationUpdatedController.add(d);
  }

  Future<void> togglePause() async {
    if (_player.state == PlayerState.playing) {
      await _player.pause();
    }
    else if (_player.state == PlayerState.paused) {
      await _player.resume();
    }
  }

  Future<void> selectTrack(String path) async {
    _queue.clear();
    _currentTrack = null;

    final directory = dirname(path);

    final playlist = (await AudioBrowserService.instance.getNodesInDirectory(directory)).where((node) => !node.isDirectory);

    // Add all thats after it, then add all thats before it, if we are repeating.
    _queue.addAll(playlist.skipWhile((node) => node.fullPath != path).map((node) => node.fullPath));
    if (_repeat) {
      _queue.addAll(playlist.takeWhile((node) => node.fullPath != path).map((node) => node.fullPath));
    }

    await next();
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
