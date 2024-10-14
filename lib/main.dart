import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vita_dl/provider/config_provider.dart';
import 'package:vita_dl/model/content_model.dart';
import 'package:vita_dl/screens/content_screen.dart';
import 'package:vita_dl/screens/download_screen.dart';
import 'package:vita_dl/screens/home_screen.dart';
import 'package:vita_dl/screens/settings_screen.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await dotenv.load(fileName: '.env');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ConfigProvider()..loadConfig(),
      child: const VitaDL(),
    ),
  );
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
      home: const HomeScreen(title: 'VitaDL'),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/download': (context) => const DownloadScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/content') {
          final args = settings.arguments as Content;
          return MaterialPageRoute(
            builder: (context) {
              return ContentScreen(content: args);
            },
          );
        }
        return null;
      },
    );
  }
}
