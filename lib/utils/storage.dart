import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getDataPath() async {
  final directory = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  return join('${directory?.path}/VitaDL');
}
