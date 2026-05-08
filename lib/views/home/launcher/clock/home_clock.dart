import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePageClock extends StatefulWidget {
  const HomePageClock({super.key});

  @override
  State<HomePageClock> createState() => HomePageClockState();
}

class HomePageClockState extends State<HomePageClock> {
  late final Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    _now = DateTime.now();

    // Every second, update the clock
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (context.mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            DateFormat.Hm().format(_now),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 100, 
              height: 1,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black
                )
              ]
            )
          ),
          Text(
            DateFormat.MMMMEEEEd().format(_now),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 20, 
              height: 1,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black
                )
              ]
            )
          )
        ],
      )
    );
  }
}
