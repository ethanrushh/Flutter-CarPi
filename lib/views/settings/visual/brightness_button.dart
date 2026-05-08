import 'dart:async';

import 'package:flutter/material.dart';
import 'package:carpi/service/settings/global_settings_service.dart';
import 'package:carpi/util/system/display_handler.dart';

class BrightnessSetting extends StatefulWidget {
  const BrightnessSetting({super.key});

  @override
  State<BrightnessSetting> createState() => _BrightnessSettingState();
}

class _BrightnessSettingState extends State<BrightnessSetting> {
  late int _selectedIndex;
  late final StreamSubscription<SettingsContainer> _streamSubscription;

  @override void initState() {
    _selectedIndex = GlobalSettingsService.container.displaySettings.brightnessMode.index;
    _streamSubscription = GlobalSettingsService.onContainerChanged.listen((container) {
      if (!mounted) return;

      // If selection has changed
      if (_selectedIndex != container.displaySettings.brightnessMode.index) {
        setState(() {
          _selectedIndex = container.displaySettings.brightnessMode.index;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  final List<String> _labels = ['Auto', 'Dim', 'Bright'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ToggleButtons(
      isSelected: List.generate(_labels.length, (i) => i == _selectedIndex),
      onPressed: (index) {
        final brightnessMode = BrightnessMode.values[index];
        
        DisplayHandler.setBrightness(brightnessMode);
        
        GlobalSettingsService.container.displaySettings.brightnessMode = brightnessMode;
        GlobalSettingsService.notifyChanged();
      },
      borderRadius: BorderRadius.circular(8),
      fillColor: theme.colorScheme.secondary.withAlpha(204),
      selectedColor: Colors.white,
      color: theme.colorScheme.onSurface.withAlpha(178),
      borderColor: theme.colorScheme.secondary.withAlpha(127),
      selectedBorderColor: theme.colorScheme.secondary,
      constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
      children: _labels.map((label) => Text(label)).toList(),
    );
  }
}
