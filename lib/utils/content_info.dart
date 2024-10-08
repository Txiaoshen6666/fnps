const String baseUrl =
    "https://store.playstation.com/store/api/chihiro/00_09_000/container";

Map<String, String> regionMap = {
  "EP": "sa/en",
  "UP": "us/en",
  "JP": "jp/ja",
  "KP": "kr/ko",
  "HP": "hk/zh",
};

String getContentIcon(String contentID) =>
    "$baseUrl/${regionMap[contentID.substring(0, 2)]}/999/$contentID/image";
