import 'package:flutter/material.dart';
import 'package:shady/shady.dart';

class ShaderBackground extends StatefulWidget {
  final String shaderPath;

  const ShaderBackground({super.key, required this.shaderPath});

  @override
  State<ShaderBackground> createState() => _ShaderBackgroundState();
}

class _ShaderBackgroundState extends State<ShaderBackground> with SingleTickerProviderStateMixin {
  late final Shady _shady;

  @override
  void initState() {
    super.initState();

    _shady = Shady(
      assetName: widget.shaderPath,
      shaderToy: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationX(3.14159), // rotate 180° around X
      child: ShadyCanvas(_shady),
    );
  }
}
