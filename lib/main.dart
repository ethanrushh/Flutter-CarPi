import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carpi/views/shader/bg/bubble_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carpi/physics/treshold_scroll_physics.dart';
import 'package:carpi/service/audio/audio_player_service.dart';
import 'package:carpi/service/audio/eq_service.dart';
import 'package:carpi/service/audio/volume_service.dart';
import 'package:carpi/service/bluetooth/bluetooth_connection_service.dart';
import 'package:carpi/service/can/vehicle_can_service.dart';
import 'package:carpi/service/gpio/gpio_service.dart';
import 'package:carpi/service/settings/global_settings_service.dart';
import 'package:carpi/service/shutdown/shutdown_service.dart';
import 'package:carpi/service/system/dbus_service.dart';
import 'package:carpi/util/system/display_handler.dart';
import 'package:carpi/views/home/audio/audio_view.dart';
import 'package:carpi/views/home/launcher.dart';
import 'package:carpi/views/home/quick_settings_page.dart';
import 'package:carpi/service/navigation/carousel_service.dart';
import 'package:carpi/views/hud/shutdown_indicator.dart';
import 'package:carpi/views/hud/volume_hud.dart';
import 'dart:developer' as devtools show log;
import 'package:parallax_rain/parallax_rain.dart';

// Future<void> killPlymouth() async {
//   if (await isRaspberryPi5()) {
//     try {
//       await Process.start('sudo', ['systemctl', 'start', 'plymouth-quit-once.service']);
//       print("Killed plymouth");
//     }
//     catch (e) {
//       print(e);
//     }
//   }
// }

Future<void> initApp() async {
  // Don't finish resolving until at least (n) seconds to avoid UI jank
  await Future.wait([
    (() async {

    })(),
    //Future.delayed(Duration(seconds: 4))
  ]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // TODO Some kind of dependency/service framework would make a lot of sense here. An interface with Initializable and Disposable sort of how C# does things?
  // Not sure, but Repeating the same calls is dumb.
  await GlobalSettingsService.initialize(); // This should probably go first
  print("Started GlobalSettingsService");
  await BluetoothAvrcpService.initialize();
  print("Started BluetoothAvrcpService");
  ShutdownService.shutdownSteps.add(() async { await BluetoothAvrcpService.dispose(); });  
  await GpioPowerService.initialize();
  print("Started GpioPowerService");
  ShutdownService.shutdownSteps.add(() async { await GpioPowerService.dispose(); });
  await VolumeService.initialize();
  print("Started VolumeService");
  ShutdownService.shutdownSteps.add(() async { await VolumeService.dispose(); });
  await VehicleCanService.initialize();
  print("Started VehicleCanService");
  ShutdownService.shutdownSteps.add(() async { await VehicleCanService.dispose(); });
  await BluetoothConnectionService.initialize();
  print("Started BluetoothConnectionService");
  ShutdownService.shutdownSteps.add(() async { await BluetoothConnectionService.dispose(); });
  await DisplayHandler.initialize();
  print("Started DisplayHandler");
  ShutdownService.shutdownSteps.add(() async { await EqualizerService.dispose(); });
  EqualizerService.test();
  print("Started EqualizerService");

  await AudioPlayerService.instance.initialize();
  print("Started AudioPlayerService");

  // This is a hack. bad.
  ProcessSignal.sigint.watch().listen((_) { ShutdownService.shutdown(true); }); 
  ProcessSignal.sigterm.watch().listen((_) { ShutdownService.shutdown(true); });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const Scaffold(
        body: Stack(
          children: [
            HomeRoot(),
            VolumeHud(),
            ShutdownIndicator(),
          ],
        ),
      ),
    );
  }
}

class HomeRoot extends StatefulWidget {
  const HomeRoot({super.key});

  @override
  State<HomeRoot> createState() => _HomeRootState();
}

Widget _createBackground(String wallpaperDir) {
  if (wallpaperDir.startsWith('shader:')) {
    // Special case for rain:
    if (wallpaperDir.endsWith('rain.frag')) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/bg/stormy.jpg'),
            fit: BoxFit.cover,
          )
        ),
        child: SizedBox.expand(
          child: ParallaxRain(
              dropColors: [
                  Colors.blueGrey
              ],
              dropFallSpeed: 8,
              trail: true,
          ),
        ),
      );
    }

    final shaderPath = wallpaperDir.substring('shader:'.length);
    return Positioned.fill(key: Key(wallpaperDir), child: ShaderBackground(key: Key(wallpaperDir), shaderPath: shaderPath));
  } else {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(wallpaperDir),
            fit: BoxFit.cover,
          ),
        ),
      )
    );
  }
}

class _HomeRootState extends State<HomeRoot> {
  late String _wallpaper;
  late StreamSubscription _sub;
  late Widget _background;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();

    _wallpaper = GlobalSettingsService.container.personalisationSettings.wallpaper;

    _sub = GlobalSettingsService.onContainerChanged.listen((container) {
      final newPath = container.personalisationSettings.wallpaper;
      if (newPath != _wallpaper) {
        if (mounted) {
          setState(() {
            print('_HomeRootState: Wallpaper changed, updating to $newPath');
            _background = _createBackground(newPath);
            _wallpaper = newPath;
          });
        }
      }
    });

    CarouselService.instance.onPageRequested.listen((index) {
      _carouselController.animateToPage(index);
    });

    _background = _createBackground(_wallpaper);
  }

  @override
  void dispose() {
    _sub.cancel();
    CarouselService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Builder(builder: (context) => _background),
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1,
            autoPlay: false,
            initialPage: 1,
            scrollPhysics: const ThresholdScrollPhysics(dragThreshold: 10),
          ),
          items: const [
            AudioPage(),
            HomePageLauncher(),
            QuickSettingsPage(),
            //VideoPlayerView(),
          ],
        ),
      ],
    );
  }
}
