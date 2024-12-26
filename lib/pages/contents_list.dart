import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vita_dl/database/database_helper.dart';
import 'package:vita_dl/model/content_model.dart';
import 'package:vita_dl/utils/get_localizations.dart';

class ContentsList extends HookWidget {
  const ContentsList({
    super.key,
    required this.types,
  });

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    final t = getLocalizations(context);

    final contents = useState(<Content>[]);
    final filteredContents = useState(<Content>[]);
    final searchText = useState('');
    final regions = useState(<String>[]);
    final selectedRegions = useState(<String>[]);

    final focusNode = useFocusNode();
    final searchTextController = useTextEditingController();

    Future<void> fetchContents() async {
      final DatabaseHelper dbHelper = DatabaseHelper();
      List<Content> fetchedContents = await dbHelper.getContents(types, null);
      fetchedContents.sort((a, b) => a.name.compareTo(b.name));
      contents.value = [...fetchedContents];
    }

    Future<void> fetchRegions() async {
      final DatabaseHelper dbHelper = DatabaseHelper();
      List<String> fetchedRegion = await dbHelper.getRegions();
      regions.value = [...fetchedRegion];
      selectedRegions.value = [...fetchedRegion];
    }

    useEffect(() {
      fetchContents();
      fetchRegions();
      return;
    }, []);

    useEffect(() {
      filteredContents.value = contents.value
          .where((content) =>
              (content.name
                      .toLowerCase()
                      .contains(searchText.value.toLowerCase()) ||
                  content.contentID
                      .toLowerCase()
                      .contains(searchText.value.toLowerCase()) ||
                  content.originalName
                      .toLowerCase()
                      .contains(searchText.value.toLowerCase())) &&
              selectedRegions.value.contains(content.region))
          .toList();
      return;
    }, [searchText.value, selectedRegions.value, contents.value]);

    void clearSearchText() {
      searchTextController.clear();
      searchText.value = '';
      focusNode.unfocus();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            style: const TextStyle(height: 1),
            controller: searchTextController,
            focusNode: focusNode,
            onChanged: (value) => searchText.value = value,
            decoration: InputDecoration(
              labelText: t.serach,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  searchText.value.isEmpty
                      ? const SizedBox()
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: clearSearchText,
                        ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onOpened: () => focusNode.unfocus(),
                    itemBuilder: (BuildContext context) => regions.value
                        .map(
                          (String region) => CheckedPopupMenuItem<String>(
                            value: region,
                            checked: selectedRegions.value.contains(region),
                            child: Text(region),
                            onTap: () {
                              focusNode.unfocus();
                              if (selectedRegions.value.contains(region)) {
                                selectedRegions.value = selectedRegions.value
                                    .where((element) => element != region)
                                    .toList();
                              } else {
                                selectedRegions.value = [
                                  ...selectedRegions.value,
                                  region
                                ];
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
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
            itemCount: filteredContents.value.length,
            itemBuilder: (context, index) {
              final content = filteredContents.value[index];
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
                  focusNode.unfocus();
                  Navigator.pushNamed(context, '/content', arguments: content);
                },
              );
            },
          ),
        )
      ],
    );
  }
}
