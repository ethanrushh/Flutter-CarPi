import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carpi/service/audio/volume_service.dart';
import 'package:carpi/service/bluetooth/bluetooth_connection_service.dart';
import 'package:carpi/util/system/display_handler.dart';
import 'package:carpi/service/settings/global_settings_service.dart';
import 'package:carpi/views/settings/settings_view.dart';
import 'package:carpi/service/navigation/carousel_service.dart';

class QuickSettingsPage extends StatefulWidget {
  const QuickSettingsPage({super.key});

  @override
  State<QuickSettingsPage> createState() => _QuickSettingsPageState();
}

class _QuickSettingsPageState extends State<QuickSettingsPage> {
  StreamSubscription? _settingsSubscription;
  StreamSubscription? _bluetoothSubscription;

  @override
  void initState() {
    super.initState();
    _settingsSubscription = GlobalSettingsService.onContainerChanged.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _bluetoothSubscription = BluetoothConnectionService.onPowerChange.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _bluetoothSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightnessMode = GlobalSettingsService.container.displaySettings.brightnessMode;
    final bluetoothPowered = BluetoothConnectionService.powered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double padding = 24.0;
          const double spacing = 20.0;

          final double availableHeight = constraints.maxHeight - (2 * padding) - spacing;
          final double availableWidth = constraints.maxWidth - (2 * padding) - (2 * spacing);

          final double itemHeight = availableHeight / 2;
          final double itemWidth = availableWidth / 3;
          final double aspectRatio = itemWidth / itemHeight;

          return Padding(
            padding: const EdgeInsets.all(padding),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Brightness
                _QuickSettingsButton(
                  icon: brightnessMode == BrightnessMode.auto
                      ? Icons.brightness_auto
                      : (brightnessMode == BrightnessMode.bright ? Icons.brightness_high : Icons.brightness_low),
                  label: 'Brightness\n${brightnessMode.name.toUpperCase()}',
                  color: theme.colorScheme.primary,
                  onTap: () async {
                    BrightnessMode nextMode;
                    if (brightnessMode == BrightnessMode.auto) {
                      nextMode = BrightnessMode.dim;
                    } else if (brightnessMode == BrightnessMode.dim) {
                      nextMode = BrightnessMode.bright;
                    } else {
                      nextMode = BrightnessMode.auto;
                    }
                    DisplayHandler.setBrightness(nextMode);
                    
                    GlobalSettingsService.container.displaySettings.brightnessMode = nextMode;
                    GlobalSettingsService.notifyChanged();
                    setState(() {});
                  },
                ),
                // Bluetooth
                _QuickSettingsButton(
                  icon: bluetoothPowered ? Icons.bluetooth : Icons.bluetooth_disabled,
                  label: 'Bluetooth\n${bluetoothPowered ? "ON" : "OFF"}',
                  color: bluetoothPowered ? Colors.blue : Colors.grey,
                  onTap: () async {
                    await BluetoothConnectionService.setPowered(!bluetoothPowered);
                    setState(() {});
                  },
                ),
                // Volume Up
                _QuickSettingsButton(
                  icon: Icons.volume_up,
                  label: 'Vol Up',
                  color: theme.colorScheme.secondary,
                  onTap: () => RpiRotaryEncoderInterop.processMfwInput(true),
                ),
                // Audio
                _QuickSettingsButton(
                  icon: Icons.music_note,
                  label: 'Audio',
                  color: theme.colorScheme.tertiary,
                  onTap: () => CarouselService.instance.requestPage(0),
                ),
                // Settings
                _QuickSettingsButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsView())),
                ),
                // Volume Down
                _QuickSettingsButton(
                  icon: Icons.volume_down,
                  label: 'Vol Down',
                  color: theme.colorScheme.secondary,
                  onTap: () => RpiRotaryEncoderInterop.processMfwInput(false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickSettingsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickSettingsButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.4), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
