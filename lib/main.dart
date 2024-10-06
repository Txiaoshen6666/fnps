import 'package:flutter/material.dart';
import 'package:vita_dl/pages/app_page.dart';
import 'package:vita_dl/pages/home_page.dart';
import 'package:vita_dl/pages/settings_page.dart';

void main() {
  runApp(const VitaDL());
}

class VitaDL extends StatelessWidget {
  const VitaDL({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitaDL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'VitaDL'),
      routes: {
        '/settings' : (context) => const SettingsPage(),
        '/app': (context) => const AppPage(),
      },
    );
  }
}

