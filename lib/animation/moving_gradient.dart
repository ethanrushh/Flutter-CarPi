import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';

class FlowingGradientBackground extends StatelessWidget {
  const FlowingGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimateGradient(
      primaryBeginGeometry: const AlignmentDirectional(0, 1),
      primaryEndGeometry: const AlignmentDirectional(0, 2),
      secondaryBeginGeometry: const AlignmentDirectional(2, 0),
      secondaryEndGeometry: const AlignmentDirectional(0, -0.8),
      textDirectionForGeometry: TextDirection.rtl,
       primaryColors: const [
         Colors.purpleAccent,
         Colors.deepPurpleAccent,
         Colors.deepPurple,
       ],
       secondaryColors: const [
         Colors.purpleAccent,
         Colors.deepPurpleAccent,
         Colors.deepPurple,
       ],
    );
  }
}
