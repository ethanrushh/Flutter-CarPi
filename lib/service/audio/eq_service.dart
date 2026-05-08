import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:carpi/service/settings/global_settings_service.dart';

const eqBands = ['31Hz', '63Hz', '125Hz', '250Hz', '500Hz', '1kHz', '2kHz', '4kHz', '8kHz', '16kHz'];

class SliderDefinition {
  final String hz;
  final String eqBandName;
  double value;

  SliderDefinition({ required this.hz, required this.eqBandName, required this.value });

  static List<SliderDefinition> generateDefaultList() {
    return [
        SliderDefinition(hz: eqBands[0], eqBandName: 'eq_band_1', value: 0),
        SliderDefinition(hz: eqBands[1], eqBandName: 'eq_band_2', value: 0),
        SliderDefinition(hz: eqBands[2], eqBandName: 'eq_band_3', value: 0),
        SliderDefinition(hz: eqBands[3], eqBandName: 'eq_band_4', value: 0),
        SliderDefinition(hz: eqBands[4], eqBandName: 'eq_band_5', value: 0),
        SliderDefinition(hz: eqBands[5], eqBandName: 'eq_band_6', value: 0),
        SliderDefinition(hz: eqBands[6], eqBandName: 'eq_band_7', value: 0),
        SliderDefinition(hz: eqBands[7], eqBandName: 'eq_band_8', value: 0),
        SliderDefinition(hz: eqBands[8], eqBandName: 'eq_band_9', value: 0),
        SliderDefinition(hz: eqBands[9], eqBandName: 'eq_band_10', value: 0),
    ].toList();
  }
}

class EqualizerService {
  static const String nodeName = 'effect_input.eq6';
  
  static String get _configPath {
    final home = Platform.environment['HOME'];
    return '$home/.config/pipewire/pipewire.conf.d/sink-eq6.conf';
  }

  static const String _confContent = '''
context.modules = [
    { name = libpipewire-module-filter-chain
        args = {
            node.description = "Pipewire Equalizer with Preamp"
            media.name       = "Pipewire Equalizer"
            filter.graph = {
                nodes = [
                    # Preamp Node: Set to -6dB using 0Hz shelf
                    { type = builtin name = eq_preamp label = bq_highshelf control = { "Freq" = 0 "Q" = 1.0 "Gain" = -6.0 } }

                    { type = builtin name = eq_band_1  label = bq_lowshelf  control = { "Freq" = 31.25   "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_2  label = bq_peaking   control = { "Freq" = 62.5    "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_3  label = bq_peaking   control = { "Freq" = 125.0   "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_4  label = bq_peaking   control = { "Freq" = 250.0   "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_5  label = bq_peaking   control = { "Freq" = 500.0   "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_6  label = bq_peaking   control = { "Freq" = 1000.0  "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_7  label = bq_peaking   control = { "Freq" = 2000.0  "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_8  label = bq_peaking   control = { "Freq" = 4000.0  "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_9  label = bq_peaking   control = { "Freq" = 8000.0  "Q" = 1.414 "Gain" = 0 } }
                    { type = builtin name = eq_band_10 label = bq_highshelf control = { "Freq" = 16000.0 "Q" = 1.414 "Gain" = 0 } }
                ]
                links = [
                    # Route input through preamp first
                    { output = "eq_preamp:Out" input = "eq_band_1:In" }

                    { output = "eq_band_1:Out" input = "eq_band_2:In" }
                    { output = "eq_band_2:Out" input = "eq_band_3:In" }
                    { output = "eq_band_3:Out" input = "eq_band_4:In" }
                    { output = "eq_band_4:Out" input = "eq_band_5:In" }
                    { output = "eq_band_5:Out" input = "eq_band_6:In" }
                    { output = "eq_band_6:Out" input = "eq_band_7:In" }
                    { output = "eq_band_7:Out" input = "eq_band_8:In" }
                    { output = "eq_band_8:Out" input = "eq_band_9:In" }
                    { output = "eq_band_9:Out" input = "eq_band_10:In" }
                ]
            }
            audio.channels = 2
            audio.position = [ FL FR ]
            capture.props = {
                node.name  = "effect_input.eq6"
                media.class = Audio/Sink
            }
            playback.props = {
                node.name   = "effect_output.eq6"
                node.passive = true
            }
        }
    }
]
''';

  static int? nodeId;

  static List<SliderDefinition>? currentBands;

  static Future<void> dispose() async { }

  static Future<void> init() async {
    final configFile = File(_configPath);

    if (await configFile.exists()) {
      print("Configuration file already exists at $_configPath");
    } else {
      print("Creating PipeWire config at $_configPath...");
      try {
        // Create directory recursively if it doesn't exist
        await configFile.parent.create(recursive: true);
        // Write the configuration content
        await configFile.writeAsString(_confContent);
        print("Config created. You may need to restart PipeWire (systemctl --user restart pipewire).");
      } catch (e) {
        print("Error creating config file: $e");
        return;
      }
    }

    // Verify if the node is actually active in the current graph
    int? id = await _getVerifiedNodeId();
    if (id != null) {
      print("Equalizer active in graph (ID: $id)");
      nodeId = id;

      print("Restoring EQ settings from save");

      // What the fuck
      final bands = GlobalSettingsService
        .container
        .soundSettings
        .equalizer
        .bands
        .asMap()
        .entries
        .map(
          (entry) => 
            SliderDefinition(hz: eqBands[entry.key], eqBandName: 'eq_band_${(entry.key + 1)}', value: entry.value))
        .toList();

      for (final band in bands) {
        setGain(band.eqBandName, band.value);
      }

      currentBands = bands;
    } else {
      print("Equalizer config exists but node not found in pw-dump. Equalizer will be unavailable.");
    }
  }

  static Future<int?> _getVerifiedNodeId() async {
    final result = await Process.run('pw-dump', []);
    if (result.exitCode != 0) return null;
    final List<dynamic> dump = jsonDecode(result.stdout);
    for (var obj in dump) {
      if (obj['type'] == 'PipeWire:Interface:Node') {
        final props = obj['info']?['props'];
        if (props != null && props['node.name'] == nodeName) {
          return obj['id'] as int;
        }
      }
    }
    return null;
  }

  static Future<void> setGain(String band, double value) async {
    if (nodeId == null) throw 'No node is available';

    final truncatedValue = value.toStringAsFixed(1);

    final payload = '{"params":["$band:Gain", $truncatedValue]}';
    await Process.run('pw-cli', ['s', '$nodeId', 'Props', payload]);
    print("Updated $band Gain to $truncatedValue on node $nodeId");
  }

  static void test() async {
    await EqualizerService.init();
  }
}
