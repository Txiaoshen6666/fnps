class Content {
  final int? id;
  final String type; // app | dlc | theme
  final String titleID;
  final String region;
  final String name;
  final String pkgDirectLink;
  final String zRIF;
  final String contentID;
  final String lastModificationDate;
  final String originalName;
  final String fileSize;
  final String sha256;
  final String requiredFW;
  final String appVersion;

  Content({
    this.id,
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

  Content copyWith({
    int? id,
    String? type,
    String? titleID,
    String? region,
    String? name,
    String? pkgDirectLink,
    String? zRIF,
    String? contentID,
    String? lastModificationDate,
    String? originalName,
    String? fileSize,
    String? sha256,
    String? requiredFW,
    String? appVersion,
  }) {
    return Content(
      id: id ?? this.id,
      type: type ?? this.type,
      titleID: titleID ?? this.titleID,
      region: region ?? this.region,
      name: name ?? this.name,
      pkgDirectLink: pkgDirectLink ?? this.pkgDirectLink,
      zRIF: zRIF ?? this.zRIF,
      contentID: contentID ?? this.contentID,
      lastModificationDate: lastModificationDate ?? this.lastModificationDate,
      originalName: originalName ?? this.originalName,
      fileSize: fileSize ?? this.fileSize,
      sha256: sha256 ?? this.sha256,
      requiredFW: requiredFW ?? this.requiredFW,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'titleID': titleID,
      'region': region,
      'name': name,
      'pkgDirectLink': pkgDirectLink,
      'zRIF': zRIF,
      'contentID': contentID,
      'lastModificationDate': lastModificationDate,
      'originalName': originalName,
      'fileSize': fileSize,
      'sha256': sha256,
      'requiredFW': requiredFW,
      'appVersion': appVersion,
    };
  }

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      id: map['id'],
      type: map['type'],
      titleID: map['titleID'],
      region: map['region'],
      name: map['name'],
      pkgDirectLink: map['pkgDirectLink'],
      zRIF: map['zRIF'],
      contentID: map['contentID'],
      lastModificationDate: map['lastModificationDate'],
      originalName: map['originalName'],
      fileSize: map['fileSize'].toString(),
      sha256: map['sha256'],
      requiredFW: map['requiredFW'],
      appVersion: map['appVersion'],
    );
  }

  static checkNull(String? text) =>
      (text == null || text == 'MISSING' || text.isEmpty) ? '' : text;

  factory Content.convert(Map<String, dynamic> map) {
    return Content(
      id: map['ID'],
      type: map['Type'],
      titleID: map['Title ID'],
      region: map['Region'],
      name: map['Name'],
      pkgDirectLink: checkNull(map['PKG direct link']),
      zRIF: checkNull(map['zRIF']),
      contentID: checkNull(map['Content ID']),
      lastModificationDate: checkNull(map['Last Modification Date']),
      originalName: checkNull(map['Original Name']),
      fileSize: checkNull(map['File Size']),
      sha256: checkNull(map['SHA256']),
      requiredFW: checkNull(map['Required FW']),
      appVersion: checkNull(map['App Version']),
    );
  }
}
