import 'package:flutter/material.dart';
import 'package:vita_dl/pages/settings_page.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 这里可以添加任何内容
    return Scaffold(
      appBar: AppBar(
          title: const Text("App Page"),
      ),
      body: const Center(
        child: Text("This is a app page!"),
      ),
    );
  }
}
