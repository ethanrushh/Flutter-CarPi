
// TODO Figure out a way to do this programatically
const assets = [
  // "assets/img/album/demo-album-cover.jpg",
  // "assets/img/bg/abstract-dark-bg.jpg",
  // "assets/img/bg/black.png",
  // "assets/img/bg/golf-bg.png",
  // "assets/img/bg/golf-headlights-night.png",
  "assets/img/bg/mountains.jpg",
  // "assets/img/bg/splash.png",
  // "assets/img/bg/landscape.jpg",
  // "assets/img/bg/dark-bg.jpg",

  // "assets/shaders/bg/cubes.frag",
  // "assets/shaders/bg/darkflow.frag",
  // "assets/shaders/bg/windwaker.frag",
  // "assets/shaders/bg/waves.frag",
  // "assets/shaders/bg/darkwaves.frag",
  // 'assets/shaders/bg/chillywaves.frag',
  // 'assets/shaders/bg/rain.frag',
  // 'assets/shaders/bg/circlespiral.frag',
  // 'assets/shaders/bg/squares.frag',
  // 'assets/shaders/bg/warpspeed.frag',
  // 'assets/shaders/bg/psp.frag'
];

Future<List<String>> listAssets(String path) async {
  return assets
    .where((asset) => asset.startsWith(path))
    .toList();
}
