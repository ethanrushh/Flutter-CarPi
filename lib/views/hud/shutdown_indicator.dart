import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carpi/service/gpio/gpio_service.dart';

class ShutdownIndicator extends StatefulWidget {
  const ShutdownIndicator({super.key});

  @override
  State<ShutdownIndicator> createState() => _ShutdownIndicatorState();
}

class _ShutdownIndicatorState extends State<ShutdownIndicator> {
  late final StreamSubscription _ignLowSubscription;
  bool _ignLow = false;

  @override
  void initState() {
    _ignLowSubscription = GpioPowerService.isIgnLow.listen((isLow) {
      _ignLow = isLow;

      if (mounted) setState(() { });
    });
    super.initState();
  }

  @override void dispose() {
    _ignLowSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _ignLow ? 1 : 0,
      child: IgnorePointer(
        child: Scaffold(
          appBar: null,
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.5 * 255).toInt()),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Center(
                    heightFactor: 1,
                    widthFactor: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFF111111),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox.fromSize(
                                  size: const Size.square(24),
                                  child: const CircularProgressIndicator(),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Shutdown Pending",
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                    Text(
                                      "System will shut down soon if ignition is not restored",
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Theme.of(context).textTheme.labelMedium?.color?.withAlpha(150)
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
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
      ),
    );
  }
}
