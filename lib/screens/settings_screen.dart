import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vita_dl/model/config_model.dart';
import 'package:vita_dl/provider/config_provider.dart';
import 'package:vita_dl/model/content_model.dart';
import 'package:vita_dl/utils/uri.dart';

import '../database/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late ConfigProvider configProvider;

  @override
  void initState() {
    super.initState();
    configProvider = Provider.of<ConfigProvider>(context, listen: false);
  }

  Future<void> _updateSource(
      String source, String type, String url, String updateTime) async {
    if (source == 'app') {
      Source app = configProvider.config.app;
      app.type = type;
      app.url = url;
      app.updateTime = updateTime;
      configProvider.updateConfig({'app': app});
    }

    if (source == 'dlc') {
      Source dlc = configProvider.config.dlc;
      dlc.type = type;
      dlc.url = url;
      dlc.updateTime = updateTime;
      configProvider.updateConfig({'dlc': dlc});
    }
  }

  Future<void> _updateHmacKey(String hmacKey) async {
    configProvider.updateConfig({'hmacKey': hmacKey});
  }

  Future<void> _pickTsvFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tsv', 'csv'],
    );

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path!;
      _readFile(filePath, type);
    }
  }

  Future<void> _readFile(String filePath, String type) async {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();
      String processedContent = content.replaceAll('\t', ',');
      List<List<dynamic>> data =
          const CsvToListConverter().convert(processedContent);
      List<Content> contents = [];
      if (data.isNotEmpty) {
        List<String> headers =
            List<String>.from(data[0].map((item) => item.toString()));
        contents = data.sublist(1).map((row) {
          Map<String, dynamic> rowMap = {};
          for (int i = 0; i < headers.length; i++) {
            rowMap['Type'] = type;
            rowMap[headers[i]] = row[i].toString();
          }
          return Content.convert(rowMap);
        }).toList();
      }
      await dbHelper.deleteContentsByType(type);
      await dbHelper.insertContents(contents);
      await _updateSource(type, 'local', '', DateTime.now().toIso8601String());
    } else {
      log('File does not exist.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);

    Config config = configProvider.config;

    final TextEditingController hmacKeyController =
        TextEditingController(text: config.hmacKey);

    Future<void> resetConfig() async {
      await dbHelper.deleteContents();
      await configProvider.resetConfig();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          children: [
            ListTile(
              title: const Text('Update game list'),
              subtitle: Text(
                  config.app.updateTime.replaceAll('T', ' ').split('.').first),
              onTap: () => _pickTsvFile('app'),
            ),
            ListTile(
              title: const Text('Update dlc list'),
              subtitle: Text(
                  config.dlc.updateTime.replaceAll('T', ' ').split('.').first),
              onTap: () => _pickTsvFile('dlc'),
            ),
            ListTile(
              title: const Text('HMAC Key'),
              subtitle: Text(config.hmacKey),
              onTap: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('HMAC Key'),
                  content: TextField(
                    controller: hmacKeyController,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancal'),
                      child: const Text('Cancal'),
                    ),
                    TextButton(
                      onPressed: () {
                        _updateHmacKey(hmacKeyController.text);
                        Navigator.pop(context, 'OK');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Reset config'),
              subtitle: const Text('All config will be reset'),
              onTap: resetConfig,
            ),
            const Divider(),
            ListTile(
              title: const Text('VitaDL'),
              subtitle: const Text('A PSVita application downloader'),
              onTap: () => launchURL('https://github.com/nini22P/VitaDL'),
            ),
          ],
        ));
  }
}
