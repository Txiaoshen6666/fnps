import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:vita_dl/database/database_helper.dart';
import 'package:vita_dl/model/config_model.dart';
import 'package:vita_dl/provider/config_provider.dart';
import 'package:vita_dl/model/content_model.dart';
import 'package:vita_dl/utils/get_localizations.dart';
import 'package:vita_dl/utils/uri.dart';

class Settings extends HookWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final t = getLocalizations(context);
    final configProvider = Provider.of<ConfigProvider>(context);

    Config config = configProvider.config;

    final TextEditingController hmacKeyController =
        TextEditingController(text: config.hmacKey);

    final DatabaseHelper dbHelper = DatabaseHelper();

    Future<void> updateSource(
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

      if (source == 'theme') {
        Source theme = configProvider.config.theme;
        theme.type = type;
        theme.url = url;
        theme.updateTime = updateTime;
        configProvider.updateConfig({'theme': theme});
      }
    }

    Future<void> updateHmacKey(String hmacKey) async {
      configProvider.updateConfig({'hmacKey': hmacKey});
    }

    Future<void> readFile(String filePath, String type) async {
      final file = File(filePath);
      if (await file.exists()) {
        String content = await file.readAsString();
        String processedContent = content
            .replaceAll('\t', ',')
            .replaceAll("'", '')
            .replaceAll('"', '');
        List<List<dynamic>> data =
            const CsvToListConverter().convert(processedContent);
        List<Content> contents = [];
        if (data.isNotEmpty) {
          List<String> headers =
              List<String>.from(data[0].map((item) => item.toString()));
          contents = data.sublist(1).map((row) {
            Map<String, dynamic> rowMap = {};
            rowMap['Type'] = type;
            for (int i = 0; i < headers.length; i++) {
              if (i < row.length) {
                rowMap[headers[i]] = row[i].toString();
              } else {
                rowMap[headers[i]] = '';
              }
            }
            return Content.convert(rowMap);
          }).toList();
        }
        await dbHelper.deleteContentsByTypes([type]);
        await dbHelper.insertContents(contents);
        await updateSource(type, 'local', '', DateTime.now().toIso8601String());
      } else {
        log('File does not exist.');
      }
    }

    Future<void> pickTsvFile(String type) async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['tsv', 'csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        String filePath = result.files.single.path!;
        readFile(filePath, type);
      }
    }

    Future<void> resetConfig() async {
      await dbHelper.deleteContents();
      await configProvider.resetConfig();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(t.updateAppList),
              subtitle: Text(
                  config.app.updateTime.replaceAll('T', ' ').split('.').first),
              onTap: () => pickTsvFile('app'),
            ),
            ListTile(
              title: Text(t.updateDLCList),
              subtitle: Text(
                  config.dlc.updateTime.replaceAll('T', ' ').split('.').first),
              onTap: () => pickTsvFile('dlc'),
            ),
            ListTile(
              title: Text(t.updateThemeList),
              subtitle: Text(config.theme.updateTime
                  .replaceAll('T', ' ')
                  .split('.')
                  .first),
              onTap: () => pickTsvFile('theme'),
            ),
            ListTile(
              title: Text(t.hmacKey),
              subtitle: Text(config.hmacKey),
              onTap: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(t.hmacKey),
                  content: TextField(
                    controller: hmacKeyController,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancal'),
                      child: Text(t.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        updateHmacKey(hmacKeyController.text);
                        Navigator.pop(context, 'OK');
                      },
                      child: Text(t.ok),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(t.resetConfig),
              subtitle: Text(t.resetConfigSub),
              onTap: resetConfig,
            ),
            const Divider(),
            ListTile(
              title: const Text('VitaDL'),
              subtitle: const Text('A PSVita application downloader'),
              onTap: () => launchURL('https://github.com/nini22P/VitaDL'),
            ),
          ],
        ),
      ),
    );
  }
}
