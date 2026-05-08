import 'package:flutter/material.dart';
import 'package:carpi/linux/process/movie/firefox_controller.dart';
import 'package:carpi/views/audio/local/local_audio_browser.dart';
import 'package:carpi/views/bluetooth/bluetooth_view.dart';
import 'package:carpi/views/home/launcher/clock/home_clock.dart';
import 'package:carpi/views/settings/settings_view.dart';

class HomePageLauncher extends StatefulWidget {
  const HomePageLauncher({super.key});

  @override
  State<HomePageLauncher> createState() => _HomePageLauncherState();
}

class _HomePageLauncherState extends State<HomePageLauncher> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              widthFactor: 1,
              child: HomePageClock()
            )
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Local Music
                  FloatingActionButton(
                    heroTag: 'launcher-local-music-button',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute<void>(
                        builder: (context) => LocalAudioBrowserView()
                      ));
                    },
                    child: const Icon(Icons.music_note)
                  ),
    
                  // Bluetooth Music
                  FloatingActionButton(
                    heroTag: 'launcher-bluetooth-music-button',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute<void>(builder: (context) => BluetoothView()));
                    },
                    child: const Icon(Icons.bluetooth)
                  ),
    
                  // Settings
                  FloatingActionButton(
                    heroTag: 'launcher-settings-button',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute<void>(builder: (context) => SettingsView()));
                    },
                    child: const Icon(Icons.settings)
                  ),
    
                  // Netflix/Firefox
                  FloatingActionButton(
                    heroTag: 'launcher-netflix-button',
                    onPressed: () {
                      FirefoxController.launchFirefoxDetached();
                    },
                    child: const Icon(Icons.movie)
                  )
                ],
              ),
            ),
          )
        ]
      ),
    );
  }
}
