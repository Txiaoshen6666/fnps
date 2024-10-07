import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:vita_dl/database/database_helper.dart';
import 'package:vita_dl/model/content_model.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key, required this.content});

  final Content content;

  @override
  State<StatefulWidget> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final String imageBaseUrl =
      "https://store.playstation.com/store/api/chihiro/00_09_000/container";
  Map<String, String> regionMap = {
    "EP": "sa/en",
    "UP": "us/en",
    "JP": "jp/ja",
    "KP": "kr/ko",
    "HP": "hk/zh",
  };

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchURL() async {
    if (!await launchUrl(Uri.parse(widget.content.pkgDirectLink!))) {
      throw Exception('Could not launch ${widget.content.pkgDirectLink!}');
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
    print(widget.content.fileSize);
    return Scaffold(
      appBar: AppBar(
          // title: Text(widget.content.name),
          ),
      body: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      fit: BoxFit.contain,
                      "$imageBaseUrl/${regionMap[widget.content.contentID.substring(0, 2)]}/999/${widget.content.contentID}/image",
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                              child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ));
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        print("Error loading image: $error");
                        return const SizedBox();
                      },
                    )),
              ),
              const SizedBox(height: 24),
              Text(
                widget.content.name,
                style: const TextStyle(fontSize: 32.0),
              ),
              (widget.content.originalName == null) ||
                      widget.content.originalName!.isEmpty
                  ? const SizedBox()
                  : Text(widget.content.originalName!),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      widget.content.titleID,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              widget.content.fileSize == null ||
                      widget.content.fileSize!.isEmpty
                  ? const SizedBox()
                  : Text(
                      'Size: ${(int.parse(widget.content.fileSize!) / 1024 / 1024).toStringAsFixed(2)} MB'),
              widget.content.appVersion == null ||
                      widget.content.appVersion!.isEmpty
                  ? const SizedBox()
                  : Text(
                      'App version: ${widget.content.appVersion.toString()}'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: widget.content.pkgDirectLink == null
                        ? null
                        : _launchURL,
                    child: Text(widget.content.pkgDirectLink == null
                        ? 'Not Available'
                        : 'Download'),
                  ),
                  ElevatedButton(
                    onPressed: widget.content.pkgDirectLink == null
                        ? null
                        : () => _copyToClipboard(
                            widget.content.pkgDirectLink!, 'Link'),
                    child: Text(widget.content.pkgDirectLink == null
                        ? 'Not Available'
                        : 'Copy Link'),
                  ),
                  ElevatedButton(
                    onPressed: widget.content.zRIF == null
                        ? null
                        : () => _copyToClipboard(widget.content.zRIF!, 'zRIF'),
                    child: Text(widget.content.pkgDirectLink == null
                        ? 'Not Available'
                        : 'Copy zRIF'),
                  )
                ],
              )
            ],
          )),
    );
  }
}
