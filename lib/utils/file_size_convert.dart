String? fileSizeConvert(String fileSize) => int.tryParse(fileSize) == null
    ? null
    : (int.parse(fileSize) / 1024 / 1024).toStringAsFixed(2);
