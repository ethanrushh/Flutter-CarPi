
import 'package:flutter/material.dart';

class SystemUpdatePage extends StatelessWidget {
  const SystemUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Updating...'),
            const CircularProgressIndicator(),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Please do not turn off the system.'),
            )
          ],
        ),
      )
    );
  }
}
