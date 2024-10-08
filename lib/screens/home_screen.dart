import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vita_dl/model/config_model.dart';
import 'package:vita_dl/provider/config_provider.dart';

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

  String searchText = '';

  List<String> regions = [];

  Map<String, bool> selectedRegions = {};

  final TextEditingController _controller = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchContents();
    _fetchRegions();
  }

  Future<void> _fetchContents() async {
    List<Content> fetchedContents = await dbHelper.getContents('app', null);
    setState(() {
      fetchedContents.sort((a, b) => a.name.compareTo(b.name));
      contents = fetchedContents;
    });
  }

  Future<void> _fetchRegions() async {
    List<String> fetchedRegion = await dbHelper.getRegions();
    setState(() {
      regions = fetchedRegion;
      for (var region in regions) {
        selectedRegions[region] = true;
      }
    });
  }

  void _setSearchText(String text) {
    setState(() {
      searchText = text;
    });
  }

  void _clearSearchText() {
    _controller.clear();
    _setSearchText('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);

    Config config = configProvider.config;

    bool isNotInitialized = config.app.updateTime.isEmpty;

    List<Content> filteredContents = contents.where((content) {
      Set<String> selectedRegionKeys = selectedRegions.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toSet();

      return (content.name.toLowerCase().contains(searchText.toLowerCase()) ||
              content.contentID
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              content.originalName
                  .toLowerCase()
                  .contains(searchText.toLowerCase())) &&
          selectedRegionKeys.contains(content.region);
    }).toList();

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
              _focusNode.unfocus();
              Navigator.pushNamed(context, '/settings').then((_) {
                _fetchContents();
                _fetchRegions();
              });
            },
          ),
          PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  selectedRegions[value] = !selectedRegions[value]!;
                });
              },
              itemBuilder: (BuildContext context) => regions
                  .map(
                    (String region) => CheckedPopupMenuItem<String>(
                      value: region,
                      checked: selectedRegions[region] ?? false,
                      child: Text(region),
                    ),
                  )
                  .toList()),
          const SizedBox(
            width: 16,
          )
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
                        _fetchRegions();
                      });
                    },
                    child: const Text('Settings')),
              ],
            ))
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) => _setSearchText(value),
                  decoration: InputDecoration(
                    labelText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchText.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearchText,
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: filteredContents.length,
                itemBuilder: (context, index) {
                  final content = filteredContents[index];
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
                      _focusNode.unfocus();
                      Navigator.pushNamed(context, '/content',
                          arguments: content);
                    },
                  );
                },
              ))
            ]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _fetchContents,
      //   tooltip: 'Refresh',
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}
