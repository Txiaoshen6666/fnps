class Config {
  Source app;
  Source dlc;

  Config({required this.app, required this.dlc});

  Map<String, dynamic> toJson() {
    return {
      'app': app.toJson(),
      'dlc': dlc.toJson(),
    };
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      app: Source.fromJson(json['app']),
      dlc: Source.fromJson(json['dlc']),
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

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'updateTime': updateTime,
      'url': url,
    };
  }

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      type: json['type'],
      updateTime: json['updateTime'],
      url: json['url'],
    );
  }
}
