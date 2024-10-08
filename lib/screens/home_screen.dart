import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vita_dl/config/config_provider.dart';
import 'package:vita_dl/utils/content_info.dart';

import '../database/database_helper.dart';
import '../model/content_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Content> contents = [];

  @override
  void initState() {
    super.initState();
    _fetchContents();
  }

  Future<void> _fetchContents() async {
    List<Content> fetchedContents = await dbHelper.getContents('app', null);
    setState(() {
      fetchedContents.sort((a, b) => a.name.compareTo(b.name));
      contents = fetchedContents;
    });
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);

    bool isNotInitialized = configProvider.config.app.updateTime.isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/download');
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings').then((_) {
                _fetchContents();
              });
            },
          ),
        ],
      ),
      body: isNotInitialized
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Please add contents in settings.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings').then((_) {
                        _fetchContents();
                      });
                    },
                    child: const Text('Settings')),
              ],
            ))
          : contents.isEmpty
              ? null
              : ListView.builder(
                  itemCount: contents.length,
                  itemBuilder: (context, index) {
                    final content = contents[index];
                    return ListTile(
                      title: Text(content.name),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              content.region,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              content.titleID,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/content',
                            arguments: content);
                      },
                    );
                  },
                ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _fetchContents,
      //   tooltip: 'Refresh',
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}
