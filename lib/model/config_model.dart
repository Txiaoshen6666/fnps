import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  Source app;
  Source dlc;
  Source theme;
  String hmacKey;

  Config({
    required this.app,
    required this.dlc,
    required this.theme,
    required this.hmacKey,
  });

  static final initConfig = {
    'app': {'type': 'local', 'updateTime': '', 'url': ''},
    'dlc': {'type': 'local', 'updateTime': '', 'url': ''},
    'theme': {'type': 'local', 'updateTime': '', 'url': ''},
    'hmacKey': dotenv.env['HMAC_KEY'] ?? '',
  };

  Map<String, dynamic> toJson() {
    return {
      'app': app.toJson(),
      'dlc': dlc.toJson(),
      'theme': theme.toJson(),
      'hmacKey': hmacKey,
    };
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      app: Source.fromJson(json['app']),
      dlc: Source.fromJson(json['dlc']),
      theme: Source.fromJson(json['theme']),
      hmacKey: json['hmacKey'],
    );
  }

  void updateFromJson(Map<String, dynamic> updates) {
    if (updates.containsKey('app')) {
      app = updates['app'];
    }
    if (updates.containsKey('dlc')) {
      dlc = updates['dlc'];
    }
    if (updates.containsKey('theme')) {
      theme = updates['theme'];
    }
    if (updates.containsKey('hmacKey')) {
      hmacKey = updates['hmacKey'];
    }
  }
}

class Source {
  String type; // remote | local
  String updateTime;
  String url;

  Source({
    required this.type,
    required this.updateTime,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'updateTime': updateTime,
      'url': url,
    };
  }

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      type: json['type'] ?? 'local',
      updateTime: json['updateTime'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
