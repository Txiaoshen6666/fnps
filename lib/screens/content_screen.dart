import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vita_dl/database/database_helper.dart';
import 'package:vita_dl/model/config_model.dart';
import 'package:vita_dl/model/content_model.dart';
import 'package:vita_dl/provider/config_provider.dart';
import 'package:vita_dl/utils/content_info.dart';
import 'package:vita_dl/utils/file_size_convert.dart';
import 'package:vita_dl/utils/uri.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key, required this.content});

  final Content content;

  @override
  State<StatefulWidget> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Content> dlcs = [];
  PackageInfo? updateInfo;

  @override
  void initState() {
    super.initState();
    _fetchDLCs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final configProvider = Provider.of<ConfigProvider>(context);
    Config config = configProvider.config;
    String hmacKey = config.hmacKey;
    if (hmacKey.isNotEmpty) {
      _fetchUpdateInfo(hmacKey);
    }
  }

  Future<void> _fetchDLCs() async {
    if (widget.content.type != 'app') {
      return;
    }
    List<Content> fetchedDLCs =
        await dbHelper.getContents('dlc', widget.content.titleID);
    setState(() => dlcs = fetchedDLCs);
  }

  Future<void> _fetchUpdateInfo(String hmacKey) async {
    if (widget.content.type != 'app') {
      return;
    }
    PackageInfo? info = await getUpdateLink(widget.content.titleID, hmacKey);
    setState(() => updateInfo = info);
  }

  Future<void> _copyToClipboard(String text, String description) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(description)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              log('Error loading image: $error');
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
                    const SizedBox(height: 8),
                    widget.content.appVersion.isEmpty &&
                            updateInfo?.version == null
                        ? const SizedBox()
                        : Text(
                            '${AppLocalizations.of(context)!.version}: ${updateInfo?.version ?? widget.content.appVersion.toString()}'),
                    widget.content.fileSize.isEmpty
                        ? const SizedBox()
                        : Text(
                            '${AppLocalizations.of(context)!.size}: ${fileSizeConvert(widget.content.fileSize)} MB'),
                    updateInfo?.size == null
                        ? const SizedBox()
                        : Text(
                            '${AppLocalizations.of(context)!.updateSize}: ${fileSizeConvert(updateInfo!.size)} MB'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ElevatedButton(
                          onPressed: widget.content.pkgDirectLink.isEmpty
                              ? null
                              : () => launchURL(widget.content.pkgDirectLink),
                          child: Text(widget.content.pkgDirectLink.isEmpty
                              ? AppLocalizations.of(context)!
                                  .dowloadLinkNotAvailable
                              : AppLocalizations.of(context)!.download),
                        ),
                        widget.content.pkgDirectLink.isEmpty
                            ? const SizedBox()
                            : ElevatedButton(
                                onPressed: () => _copyToClipboard(
                                    widget.content.pkgDirectLink,
                                    AppLocalizations.of(context)!
                                        .downloadLinkCopied),
                                child: Text(widget.content.pkgDirectLink.isEmpty
                                    ? AppLocalizations.of(context)!
                                        .dowloadLinkNotAvailable
                                    : AppLocalizations.of(context)!.copyLink),
                              ),
                        ElevatedButton(
                          onPressed: widget.content.zRIF.isEmpty
                              ? null
                              : () => _copyToClipboard(widget.content.zRIF,
                                  AppLocalizations.of(context)!.zRIFCopied),
                          child: Text(widget.content.zRIF.isEmpty
                              ? AppLocalizations.of(context)!.zRIFNotAvailable
                              : '${AppLocalizations.of(context)!.copy} zRIF'),
                        ),
                        updateInfo?.url == null
                            ? const SizedBox()
                            : ElevatedButton(
                                onPressed: () => launchURL(updateInfo!.url),
                                child: Text(AppLocalizations.of(context)!
                                    .downloadUpdate),
                              ),
                        updateInfo?.url == null
                            ? const SizedBox()
                            : ElevatedButton(
                                onPressed: () => _copyToClipboard(
                                    updateInfo!.url,
                                    AppLocalizations.of(context)!
                                        .updateLinkCopied),
                                child: Text(AppLocalizations.of(context)!
                                    .copyUpdateLink),
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
                                          launchURL(dlc.pkgDirectLink),
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
