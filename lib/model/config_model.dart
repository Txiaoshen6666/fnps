import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  Source app;
  Source dlc;
  Source theme;
  String hmacKey;
  List<String> regions;

  Config({
    required this.app,
    required this.dlc,
    required this.theme,
    required this.hmacKey,
    required this.regions,
  });

  static final initConfig = {
    'app': {'type': 'local', 'updateTime': '', 'url': ''},
    'dlc': {'type': 'local', 'updateTime': '', 'url': ''},
    'theme': {'type': 'local', 'updateTime': '', 'url': ''},
    'hmacKey': dotenv.env['HMAC_KEY'] ?? '',
    'regions': ['JP', 'US', 'INT', 'EU', 'ASIA', 'UNKNOWN'],
  };

  Config copyWith({
    Source? app,
    Source? dlc,
    Source? theme,
    String? hmacKey,
    List<String>? regions,
  }) {
    return Config(
      app: app ?? this.app,
      dlc: dlc ?? this.dlc,
      theme: theme ?? this.theme,
      hmacKey: hmacKey ?? this.hmacKey,
      regions: regions ?? this.regions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app': app.toJson(),
      'dlc': dlc.toJson(),
      'theme': theme.toJson(),
      'hmacKey': hmacKey,
      'regions': regions,
    };
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      app: Source.fromJson(json['app']),
      dlc: Source.fromJson(json['dlc']),
      theme: Source.fromJson(json['theme']),
      hmacKey: json['hmacKey'],
      regions: List<String>.from(json['regions']),
    );
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

  Source copyWith({
    String? type,
    String? updateTime,
    String? url,
  }) {
    return Source(
      type: type ?? this.type,
      updateTime: updateTime ?? this.updateTime,
      url: url ?? this.url,
    );
  }

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
