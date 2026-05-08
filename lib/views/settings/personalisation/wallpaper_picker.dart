import 'package:carpi/service/settings/global_settings_service.dart';
import 'package:carpi/util/asset/list_assets.dart';
import 'package:flutter/material.dart';

class WallpaperPicker extends StatefulWidget {
  const WallpaperPicker({super.key});

  @override
  State<WallpaperPicker> createState() => _WallpaperPickerState();
}

class _WallpaperPickerState extends State<WallpaperPicker> {
  late final Future<List<String>> _wallpapersFuture;
  
  @override void initState() {
    _wallpapersFuture = (() async {
      try {
        final List<String> wallpapers = [];

        wallpapers.addAll(await listAssets('assets/img/bg'));
        wallpapers.addAll((await listAssets('assets/shaders/bg'))
          .where((shaderAssetDir) => !shaderAssetDir.endsWith('.thumb.png'))
          .map((shaderAssetDir) => "shader:$shaderAssetDir"));

        print("WallpaperPicker: Found ${wallpapers.length} wallpapers.");

        return wallpapers;
      }
      catch (e) {
        print(e);
        return [] as List<String>;
      }
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _wallpapersFuture,
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              final wallpapers = asyncSnapshot.data;

              if (wallpapers == null) break;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1, // square tiles
                ),
                itemCount: wallpapers.length,
                itemBuilder: (context, index) {
                  final wallpaper = wallpapers[index];

                  return Material(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        debugPrint('Tapped $wallpaper');

                        GlobalSettingsService.container.personalisationSettings.wallpaper = wallpaper;
                        await GlobalSettingsService.notifyChanged();

                        if (context.mounted) Navigator.pop<String>(context, wallpaper);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Image.asset(
                          wallpaper.startsWith("shader:") ? 
                            'assets/shaders/bg/thumb/${wallpaper.split('/').last.replaceFirst('.frag', '')}.thumb.png' // TODO This is so sketchy holy shit
                            : wallpaper,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }
              );

            default: break;
          }

          return Center(
            child: CircularProgressIndicator()
          );
        }
      )
    );
  }
}
