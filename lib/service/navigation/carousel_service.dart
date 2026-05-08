import 'dart:async';

class CarouselService {
  static final CarouselService instance = CarouselService._internal();
  CarouselService._internal();

  final StreamController<int> _pageController = StreamController<int>.broadcast();
  Stream<int> get onPageRequested => _pageController.stream;

  void requestPage(int index) {
    _pageController.add(index);
  }

  void dispose() {
    _pageController.close();
  }
}
