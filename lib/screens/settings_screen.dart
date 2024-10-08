import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vita_dl/config/config.dart';
import 'package:vita_dl/config/config_provider.dart';
import 'package:vita_dl/model/content_model.dart';

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

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _updateConfig(
      String source, String type, String url, String updateTime) async {
    if (source == 'app') {
      Source app = configProvider.config.app;
      app.type = type;
      app.url = url;
      app.updateTime = updateTime;
      configProvider.updateConfig(app, null);
    }

    if (source == 'dlc') {
      Source dlc = configProvider.config.dlc;
      dlc.type = type;
      dlc.url = url;
      dlc.updateTime = updateTime;
      configProvider.updateConfig(null, dlc);
    }
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
      await _updateConfig(type, 'local', '', DateTime.now().toIso8601String());
    } else {
      print('File does not exist.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);

    Config config = configProvider.config;

    Future<void> clearListData() async {
      await dbHelper.deleteContents();
      await _updateConfig('app', '', '', '');
      await _updateConfig('dlc', '', '', '');
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          children: [
            ListTile(
              title: const Text('Update game list'),
              subtitle: Text(config.app.updateTime.replaceAll('T', ' ')),
              onTap: () => _pickTsvFile('app'),
            ),
            ListTile(
              title: const Text('Update dlc list'),
              subtitle: Text(config.dlc.updateTime.replaceAll('T', ' ')),
              onTap: () => _pickTsvFile('dlc'),
            ),
            ListTile(
              title: const Text('Clear list data'),
              subtitle: const Text('All list data will be cleared'),
              onTap: clearListData,
            ),
            const Divider(color: Colors.grey, thickness: 1),
            ListTile(
              title: const Text('VitaDL'),
              subtitle: const Text('A PSVita application downloader'),
              onTap: () => _launchURL('https://github.com/nini22P/VitaDL'),
            ),
          ],
        ));
  }
}
