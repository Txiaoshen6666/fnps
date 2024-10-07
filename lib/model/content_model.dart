class Content {
  final String type; // app | dlc | theme
  final String titleID;
  final String region;
  final String name;
  final String? pkgDirectLink;
  final String? zRIF;
  final String contentID;
  final DateTime? lastModificationDate;
  final String? originalName;
  final String? fileSize;
  final String? sha256;
  final String? requiredFW;
  final String? appVersion;

  Content({
    required this.type,
    required this.titleID,
    required this.region,
    required this.name,
    required this.pkgDirectLink,
    required this.zRIF,
    required this.contentID,
    required this.lastModificationDate,
    required this.originalName,
    required this.fileSize,
    required this.sha256,
    required this.requiredFW,
    required this.appVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'titleId': titleID,
      'region': region,
      'name': name,
      'pkgDirectLink': pkgDirectLink,
      'zRIF': zRIF,
      'contentId': contentID,
      'lastModificationDate': lastModificationDate?.toIso8601String(),
      'originalName': originalName,
      'fileSize': fileSize,
      'sha256': sha256,
      'requiredFw': requiredFW,
      'appVersion': appVersion,
    };
  }

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      type: map['type'],
      titleID: map['titleId'],
      region: map['region'],
      name: map['name'],
      pkgDirectLink: map['pkgDirectLink'],
      zRIF: map['zRIF'],
      contentID: map['contentId'],
      lastModificationDate: map['lastModificationDate'] == null
          ? null
          : DateTime.tryParse(map['lastModificationDate']),
      originalName: map['originalName'],
      fileSize: map['fileSize'].toString(),
      sha256: map['sha256'],
      requiredFW: map['requiredFw'],
      appVersion: map['appVersion'],
    );
  }

  factory Content.convert(Map<String, dynamic> map) {
    return Content(
      type: map['Type'],
      titleID: map['Title ID'],
      region: map['Region'],
      name: map['Name'],
      pkgDirectLink: map['PKG direct link'],
      zRIF: map['zRIF'],
      contentID: map['Content ID'],
      lastModificationDate: DateTime.tryParse(map['Last Modification Date']),
      originalName: map['Original Name'],
      fileSize: map['File Size'].toString(),
      sha256: map['SHA256'],
      requiredFW: map['Required FW'],
      appVersion: map['App Version'],
    );
  }
}
