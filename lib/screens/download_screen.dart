import 'package:flutter/material.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Download Page"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Back to Home"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
