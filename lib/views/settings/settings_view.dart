import 'dart:async';
import 'dart:io';

import 'package:carpi/util/platform/platform_helpers.dart';
import 'package:carpi/views/settings/personalisation/wallpaper_picker.dart';
import 'package:carpi/views/settings/system/version_display_widget.dart';
import 'package:carpi/views/system/update_page.dart';
import 'package:flutter/material.dart';
import 'package:carpi/dialog/confirmation_dialog.dart';
import 'package:carpi/service/gpio/gpio_service.dart';
import 'package:carpi/views/settings/eq_control.dart';
import 'package:carpi/views/settings/visual/brightness_button.dart';


class SettingsContent extends StatelessWidget {
  const SettingsContent({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        final slide = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}


class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Widget _current = const AudioSettings();

  void _open(Widget page) {
    setState(() => _current = page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.volume_up_rounded),
                  title: const Text('Audio'),
                  onTap: () => _open(const AudioSettings()),
                ),
                ListTile(
                  leading: const Icon(Icons.display_settings_rounded),
                  title: const Text('Visual'),
                  onTap: () => _open(const VisualSettings()),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('System'),
                  onTap: () => _open(const SystemSettings()),
                ),
                ListTile(
                  leading: const Icon(Icons.brush_rounded),
                  title: const Text('Personalisation'),
                  onTap: () => _open(const PersonalisationSettings()),
                ),
                ListTile(
                  leading: const Icon(Icons.power_settings_new_rounded),
                  title: const Text('Power'),
                  onTap: () => _open(const PowerSettings()),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SettingsContent(
              child: KeyedSubtree(
                key: ValueKey(_current.runtimeType),
                child: _current,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioSettings extends StatelessWidget {
  const AudioSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Equalizer'),
            TextButton.icon(
              label: const Text('Adjust Equalizer'), 
              icon: const Icon(Icons.equalizer_rounded),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<void>(builder: (context) => EqualizerPage()));
              },
            )
          ],
        )
      ],
    );
  }
}

class VisualSettings extends StatelessWidget {
  const VisualSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Display Brightness'),
            const BrightnessSetting()
          ],
        )
      ],
    );
  }
}

class PersonalisationSettings extends StatelessWidget {
  const PersonalisationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text("Change Wallpaper"),
          onTap: () async {
            Navigator.push(context, MaterialPageRoute<void>(builder: (context) => WallpaperPicker()));
          },
          trailing: const Icon(Icons.now_wallpaper)
        )
      ],
    );
  }
}

class SystemSettings extends StatefulWidget {
  const SystemSettings({super.key});

  @override
  State<SystemSettings> createState() => _SystemSettingsState();
}
class _SystemSettingsState extends State<SystemSettings> {

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('System Update'),
          trailing: const Icon(Icons.cached_rounded),
          onTap: () async {
            if (await showConfirmationDialog(title: 'Are you sure?', content: 'Would you like to run a system update? The system will be unavailable during this time.', confirmationButtonText: 'Update', context: context)) {
              unawaited(Navigator.push(context, MaterialPageRoute<void>(builder: (context) => SystemUpdatePage())));
              
              if (await isRaspberryPi5()) {
                var process = await Process.start('/home/pi/elinux-carpi/update.sh', []);

                // Pipe stdout and stderr to console
                process.stdout.transform(SystemEncoding().decoder).listen(stdout.write);
                process.stderr.transform(SystemEncoding().decoder).listen(stderr.write);

                // Wait for it to finish
                var exitCode = await process.exitCode;
                print('Process exited with code $exitCode');

                if (exitCode != 0) {// We expect this to restart the system.
                  Navigator.pop(context);
                }
              }
              else {
                print("Not running on a Pi - ignoring update request");
              }
            }
          },
        ),
        VersionDisplayWidget()
      ],
    );
  }
}

class PowerSettings extends StatefulWidget {
  const PowerSettings({super.key});

  @override
  State<PowerSettings> createState() => _PowerSettingsState();
}

class _PowerSettingsState extends State<PowerSettings> {
  bool ignitionOverride = false;

  @override
  void initState() {
    ignitionOverride = GpioPowerService.ignitionOverride;    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('Ignore Ignition State'),
          trailing: Switch(
            value: ignitionOverride,
            onChanged: (value) {
              setState(() {
                GpioPowerService.setIgnitionOverride(value);

                ignitionOverride = GpioPowerService.ignitionOverride;
              });
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.power_settings_new_rounded),
          title: const Text('Shutdown'),
          onTap: () async {
            if (await showConfirmationDialog(
              title: 'Are you sure?', 
              content: 'Are you sure you would like to shut down the system?', 
              confirmationButtonText: 'Shut Down', 
              context: context
            )) {
              unawaited(GpioPowerService.triggerShutdown());
            }
          }
        )
      ],
    );
  }
}
