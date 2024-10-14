import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:vita_dl/utils/storage.dart';
import '../model/config_model.dart';

class ConfigProvider with ChangeNotifier {
  static final String hmacKey = dotenv.env['HMAC_KEY'] ?? '';

  static final initConfig = {
    'app': {'type': 'local', 'updateTime': '', 'url': ''},
    'dlc': {'type': 'local', 'updateTime': '', 'url': ''},
    'hmacKey': hmacKey,
  };

  Config _config = Config.fromJson(initConfig);

  Config get config => _config;

  Future<String> getConfigPath() async =>
      join(await getDataPath(), 'config', 'config.json');

  Future<void> loadConfig() async {
    final file = File(await getConfigPath());

    if (await file.exists()) {
      String contents = await file.readAsString();
      _config = Config.fromJson(json.decode(contents));
      notifyListeners();
    }
  }

  Future<void> saveConfig() async {
    final file = File(await getConfigPath());
    await file.writeAsString(json.encode(_config.toJson()));
  }

  void updateConfig(Map<String, dynamic> updates) {
    _config.updateFromJson(updates);
    saveConfig();
    notifyListeners();
  }

  Future<void> resetConfig() async {
    print(initConfig['hmacKey']);
    _config = Config.fromJson(initConfig);
    saveConfig();
    notifyListeners();
  }
}
