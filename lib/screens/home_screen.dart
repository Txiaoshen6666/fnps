import 'package:flutter/material.dart';

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
    List<Content> fetchedContents = await dbHelper.getContents();
    setState(() {
      contents = fetchedContents;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: contents.isEmpty
          // ? const Center(child: CircularProgressIndicator())
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
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchContents,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
