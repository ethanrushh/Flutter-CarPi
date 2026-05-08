import 'package:carpi/dialog/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:carpi/service/audio/eq_service.dart';
import 'package:carpi/service/settings/global_settings_service.dart';
import 'dart:ui';

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  late List<SliderDefinition> sliders;
  bool _allowClipping = false;

  @override void initState() {
    sliders = EqualizerService.currentBands ?? SliderDefinition.generateDefaultList();

    if (sliders.any((slider) => slider.value > 6)) _allowClipping = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer')
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Column(
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      sliders = SliderDefinition.generateDefaultList();
                      EqualizerService.currentBands = sliders;

                      for (final slider in sliders) {
                        EqualizerService.setGain(slider.eqBandName, slider.value);
                      }

                      GlobalSettingsService.container.soundSettings.equalizer.bands = sliders.map((x) => x.value).toList();
                      GlobalSettingsService.notifyChanged();
                    });
                  }, 
                  label: const Text('Reset'),
                  icon: const Icon(Icons.sync)
                ),
                Row(
                  spacing: 4,
                  children: [
                    const Text("Clip"),
                    Switch(
                      value: _allowClipping,
                      onChanged: (value) async {
                        if (!value) {
                          if (sliders.any((slider) => slider.value > 6 || slider.value < 6)) {
                            if (!await showConfirmationDialog(title: 'Are you sure?', content: 'This will adjust your current EQ profile. Are you sure you want to disable clipping?', confirmationButtonText: 'Confirm', context: context)) return;
                          }

                          setState(() {
                            for (final slider in sliders) {
                              slider.value = clampDouble(slider.value, -6, 6);
                              EqualizerService.setGain(slider.eqBandName, slider.value);
                            }
                          });
                        }

                        EqualizerService.currentBands = sliders;

                        GlobalSettingsService.container.soundSettings.equalizer.bands = sliders.map((x) => x.value).toList();
                        GlobalSettingsService.notifyChanged();

                        setState(() {
                          _allowClipping = value;
                        });
                      },
                    )
                  ]
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(sliders.length, (index) => 
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        sliders[index].hz,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      RotatedBox(
                        quarterTurns: -1, // make vertical
                        child: Slider(
                          value: sliders[index].value,
                          min: _allowClipping ? -12 : -6,
                          max: _allowClipping ? 12 : 6,
                          onChanged: (newValue) {
                            setState(() {
                              sliders[index].value = newValue;
                            });
                          },
                          onChangeEnd: (newValue) {
                            EqualizerService.setGain(sliders[index].eqBandName, newValue);
                            EqualizerService.currentBands = sliders;

                            GlobalSettingsService.container.soundSettings.equalizer.bands = sliders.map((x) => x.value).toList();
                            GlobalSettingsService.notifyChanged();
                          }
                        ),
                      ),
                      Text(
                        '${sliders[index].value.toStringAsFixed(1)}db',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: sliders[index].value > 6 ? Colors.red : Theme.of(context).colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
