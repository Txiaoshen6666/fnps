import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vita_dl/model/content_model.dart';

import '../database/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> _pickTsvFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tsv'],
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
      List<List<dynamic>> data =
          const CsvToListConverter(fieldDelimiter: '\t').convert(content);
      List<Content> contents = [];
      if (data.isNotEmpty) {
        List<String> headers = List<String>.from(data[0]);
        contents = data.sublist(1).map((row) {
          Map<String, dynamic> rowMap = {};
          for (int i = 0; i < headers.length; i++) {
            rowMap['Type'] = type;
            if (headers[i] == 'Last Modification Date') {
              rowMap[headers[i]] = row[i].toString().replaceAll('/', "-");
            } else {
              rowMap[headers[i]] = row[i].toString();
            }
          }
          return Content.convert(rowMap);
        }).toList();
      }
      dbHelper.insertContents(contents);
    } else {
      print('File does not exist.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () => _pickTsvFile('app'),
              child: const Text("Import game list"),
            ),
            ElevatedButton(
              onPressed: () => _pickTsvFile('dlc'),
              child: const Text("Import dlc list"),
            ),
            ElevatedButton(
              onPressed: () => _pickTsvFile('theme'),
              child: const Text("Import theme list"),
            ),
          ],
        ));
  }
}
