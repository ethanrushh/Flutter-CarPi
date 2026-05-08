
import 'package:flutter/material.dart';

class ThresholdScrollPhysics extends CarouselScrollPhysics {
  final double dragThreshold;

  const ThresholdScrollPhysics({super.parent, this.dragThreshold = 10});

  @override
  ThresholdScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ThresholdScrollPhysics(parent: buildParent(ancestor), dragThreshold: dragThreshold);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Ignore small drags
    if (offset.abs() < dragThreshold) return 0;
    
    return super.applyPhysicsToUserOffset(position, offset);
  }
}
