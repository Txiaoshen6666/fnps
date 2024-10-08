import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:vita_dl/database/database_helper.dart';
import 'package:vita_dl/model/content_model.dart';
import 'package:vita_dl/utils/content_info.dart';
import 'package:vita_dl/utils/file_size_convert.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key, required this.content});

  final Content content;

  @override
  State<StatefulWidget> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Content> dlcs = [];

  @override
  void initState() {
    super.initState();
    _fetchDLCs();
  }

  Future<void> _fetchDLCs() async {
    if (widget.content.type != 'app') {
      return;
    }
    List<Content> fetchedDLCs =
        await dbHelper.getContents('dlc', widget.content.titleID);
    setState(() {
      dlcs = fetchedDLCs;
    });
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var fileSize = fileSizeConvert(widget.content.fileSize);
    return Scaffold(
        appBar: AppBar(
            // title: Text(widget.content.name),
            ),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 128,
                      height: 128,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            fit: BoxFit.contain,
                            getContentIcon(widget.content.contentID),
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                    child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ));
                              }
                            },
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              print('Error loading image: $error');
                              return const SizedBox();
                            },
                          )),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.content.name,
                      style: const TextStyle(fontSize: 32.0),
                    ),
                    widget.content.originalName.isEmpty
                        ? const SizedBox()
                        : Text(widget.content.originalName),
                    const SizedBox(height: 4),
                    Row(
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
                            widget.content.region,
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
                            widget.content.titleID,
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
                            widget.content.type,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    fileSize == null
                        ? const SizedBox()
                        : Text('Size: $fileSize MB'),
                    widget.content.appVersion.isEmpty
                        ? const SizedBox()
                        : Text(
                            'App version: ${widget.content.appVersion.toString()}'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ElevatedButton(
                          onPressed: widget.content.pkgDirectLink.isEmpty
                              ? null
                              : () => _launchURL(widget.content.pkgDirectLink),
                          child: Text(widget.content.pkgDirectLink.isEmpty
                              ? 'Dowload link not available'
                              : 'Download'),
                        ),
                        ElevatedButton(
                          onPressed: widget.content.pkgDirectLink.isEmpty
                              ? null
                              : () => _copyToClipboard(
                                  widget.content.pkgDirectLink, 'Link'),
                          child: Text(widget.content.pkgDirectLink.isEmpty
                              ? 'Dowload link not available'
                              : 'Copy Link'),
                        ),
                        ElevatedButton(
                          onPressed: widget.content.zRIF.isEmpty
                              ? null
                              : () =>
                                  _copyToClipboard(widget.content.zRIF, 'zRIF'),
                          child: Text(widget.content.zRIF.isEmpty
                              ? 'zRIF not available'
                              : 'Copy zRIF'),
                        ),
                      ],
                    ),
                  ],
                )),
            const SizedBox(
              height: 16,
            ),
            dlcs.isEmpty
                ? const SizedBox()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dlcs.length,
                    itemBuilder: (context, index) {
                      final dlc = dlcs[index];
                      return ListTile(
                          title: Text(dlc.name),
                          onTap: () => Navigator.pushNamed(context, '/content',
                              arguments: dlc),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              dlc.pkgDirectLink.isEmpty
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () =>
                                          _launchURL(dlc.pkgDirectLink),
                                      icon: const Icon(Icons.download)),
                              dlc.pkgDirectLink.isEmpty
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () => _copyToClipboard(
                                          dlc.pkgDirectLink, 'DLC link'),
                                      icon: const Icon(Icons.copy)),
                              dlc.zRIF.isEmpty
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () =>
                                          _copyToClipboard(dlc.zRIF, 'zRIF'),
                                      icon: const Icon(Icons.key)),
                            ],
                          ));
                    },
                  ),
          ]),
        ));
  }
}
