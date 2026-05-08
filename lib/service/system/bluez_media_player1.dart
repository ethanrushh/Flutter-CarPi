// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object player0.xml
import 'package:dbus/dbus.dart';

class BlueZMediaPlayer1Remote extends DBusRemoteObject {
  Stream<DBusPropertiesChangedSignal> get mediaPlayerPropertiesChanged =>
    super.propertiesChanged.where(
      (e) => e.interface == 'org.bluez.MediaPlayer1',
    );

  BlueZMediaPlayer1Remote(
    DBusClient client,
    String destination,
    DBusObjectPath path,
  ) : super(client, name: destination, path: path);

  /// Invokes org.freedesktop.DBus.Introspectable.Introspect()
  Future<String> callIntrospect({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.DBus.Introspectable', 'Introspect', [], replySignature: DBusSignature('s'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asString();
  }

  /// Gets org.bluez.MediaPlayer1.Name
  Future<String> getName() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Name', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.MediaPlayer1.Type
  Future<String> getType() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Type', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.MediaPlayer1.Subtype
  Future<String> getSubtype() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Subtype', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.MediaPlayer1.Position
  Future<int> getPosition() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Position', signature: DBusSignature('u'));
    return value.asUint32();
  }

  /// Gets org.bluez.MediaPlayer1.Status
  Future<String> getStatus() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Status', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Gets org.bluez.MediaPlayer1.Equalizer
  Future<String> getEqualizer() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Equalizer', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Sets org.bluez.MediaPlayer1.Equalizer
  Future<void> setEqualizer (String value) async {
    await setProperty('org.bluez.MediaPlayer1', 'Equalizer', DBusString(value));
  }

  /// Gets org.bluez.MediaPlayer1.Repeat
  Future<String> getRepeat() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Repeat', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Sets org.bluez.MediaPlayer1.Repeat
  Future<void> setRepeat (String value) async {
    await setProperty('org.bluez.MediaPlayer1', 'Repeat', DBusString(value));
  }

  /// Gets org.bluez.MediaPlayer1.Shuffle
  Future<String> getShuffle() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Shuffle', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Sets org.bluez.MediaPlayer1.Shuffle
  Future<void> setShuffle (String value) async {
    await setProperty('org.bluez.MediaPlayer1', 'Shuffle', DBusString(value));
  }

  /// Gets org.bluez.MediaPlayer1.Scan
  Future<String> getScan() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Scan', signature: DBusSignature('s'));
    return value.asString();
  }

  /// Sets org.bluez.MediaPlayer1.Scan
  Future<void> setScan (String value) async {
    await setProperty('org.bluez.MediaPlayer1', 'Scan', DBusString(value));
  }

  /// Gets org.bluez.MediaPlayer1.Track
  Future<Map<String, DBusValue>> getTrack() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Track', signature: DBusSignature('a{sv}'));
    return value.asStringVariantDict();
  }

  /// Gets org.bluez.MediaPlayer1.Device
  Future<DBusObjectPath> getDevice() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Device', signature: DBusSignature('o'));
    return value.asObjectPath();
  }

  /// Gets org.bluez.MediaPlayer1.Browsable
  Future<bool> getBrowsable() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Browsable', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Gets org.bluez.MediaPlayer1.Searchable
  Future<bool> getSearchable() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Searchable', signature: DBusSignature('b'));
    return value.asBoolean();
  }

  /// Gets org.bluez.MediaPlayer1.Playlist
  Future<DBusObjectPath> getPlaylist() async {
    var value = await getProperty('org.bluez.MediaPlayer1', 'Playlist', signature: DBusSignature('o'));
    return value.asObjectPath();
  }

  /// Invokes org.bluez.MediaPlayer1.Play()
  Future<void> callPlay({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Play', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.Pause()
  Future<void> callPause({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Pause', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.Stop()
  Future<void> callStop({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Stop', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.Next()
  Future<void> callNext({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Next', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.Previous()
  Future<void> callPrevious({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Previous', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.FastForward()
  Future<void> callFastForward({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'FastForward', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.Rewind()
  Future<void> callRewind({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Rewind', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.Press()
  Future<void> callPress(int avc_key, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Press', [DBusByte(avc_key)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.Hold()
  Future<void> callHold(int avc_key, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Hold', [DBusByte(avc_key)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.bluez.MediaPlayer1.Release()
  Future<void> callRelease({bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.bluez.MediaPlayer1', 'Release', [], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.DBus.Properties.Get()
  Future<DBusValue> callGet(String interface, String name, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.DBus.Properties', 'Get', [DBusString(interface), DBusString(name)], replySignature: DBusSignature('v'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asVariant();
  }

  /// Invokes org.freedesktop.DBus.Properties.Set()
  Future<void> callSet(String interface, String name, DBusValue value, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    await callMethod('org.freedesktop.DBus.Properties', 'Set', [DBusString(interface), DBusString(name), DBusVariant(value)], replySignature: DBusSignature(''), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
  }

  /// Invokes org.freedesktop.DBus.Properties.GetAll()
  Future<Map<String, DBusValue>> callGetAll(String interface, {bool noAutoStart = false, bool allowInteractiveAuthorization = false}) async {
    var result = await callMethod('org.freedesktop.DBus.Properties', 'GetAll', [DBusString(interface)], replySignature: DBusSignature('a{sv}'), noAutoStart: noAutoStart, allowInteractiveAuthorization: allowInteractiveAuthorization);
    return result.returnValues[0].asStringVariantDict();
  }
}
