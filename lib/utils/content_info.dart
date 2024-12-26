import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:crypto/crypto.dart';

const String baseApiUrl =
    "https://store.playstation.com/store/api/chihiro/00_09_000/container";

Map<String, String> regionMap = {
  "EP": "sa/en",
  "UP": "us/en",
  "JP": "jp/ja",
  "KP": "kr/ko",
  "HP": "hk/zh",
};

class Update {
  final String version;
  final String size;
  final String url;

  Update({
    required this.version,
    required this.size,
    required this.url,
  });
}

class ContentInfo {
  final List<String> images;
  final String desc;

  ContentInfo({
    required this.images,
    required this.desc,
  });
}

String getContentIcon(String contentID) =>
    "$baseApiUrl/${regionMap[contentID.substring(0, 2)]}/999/$contentID/image";

Future<ContentInfo> getContentInfo(String contentID) async {
  final infoUrl =
      "$baseApiUrl/${regionMap[contentID.substring(0, 2)]}/999/$contentID";

  try {
    final response = await HttpClient().getUrl(Uri.parse(infoUrl));
    final data = await response.close();
    final jsonString = await data.transform(utf8.decoder).join();
    final json = jsonDecode(jsonString);

    List<String> images = [];

    for (var promo in json['promomedia']) {
      for (var material in promo['materials']) {
        for (var urlObj in material['urls']) {
          images.add(urlObj['url']);
        }
      }
    }

    final desc = json['long_desc'] ?? '';

    return ContentInfo(images: images, desc: desc);
  } catch (e) {
    return ContentInfo(images: [], desc: '');
  }
}

String getUpdateXmlLink(String titleID, String hmacKey) {
  List<int> binary = [];
  String key = "0x$hmacKey";

  for (int i = 2; i < key.length; i += 2) {
    String s = key.substring(i, i + 2);
    binary.add(int.parse(s, radix: 16));
  }

  var hmac = Hmac(sha256, binary);
  var byteHash = hmac.convert(utf8.encode("np_$titleID")).bytes;

  String hash = byteHash
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join()
      .toLowerCase();

  return "http://gs-sec.ww.np.dl.playstation.net/pl/np/$titleID/$hash/$titleID-ver.xml";
}

Future<Update?> getUpdateLink(String titleID, String hmacKey) async {
  var xmlLink = getUpdateXmlLink(titleID, hmacKey);

  try {
    var response = await HttpClient().getUrl(Uri.parse(xmlLink));
    var data = await response.close();

    var contents = await data.transform(utf8.decoder).join();
    final document = XmlDocument.parse(contents);

    if (document.findElements('Error').isNotEmpty) {
      return null;
    }

    if (document.findElements('titlepatch').isNotEmpty) {
      final titlePatch = document.findAllElements('titlepatch').first;
      final tag = titlePatch.findElements('tag').first;

      final package = tag.findElements('package').first;

      final version = package.getAttribute('version') ?? '';
      final size = package.getAttribute('size') ?? '';
      final url = package.getAttribute('url') ?? '';

      return Update(version: version, size: size, url: url);
    }
  } catch (e) {
    return null;
  }
  return null;
}
