import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vita_dl/database/database_helper.dart';
import 'package:vita_dl/model/config_model.dart';
import 'package:vita_dl/model/content_model.dart';
import 'package:vita_dl/provider/config_provider.dart';
import 'package:vita_dl/utils/content_info.dart';
import 'package:vita_dl/utils/file_size_convert.dart';
import 'package:vita_dl/utils/get_localizations.dart';
import 'package:vita_dl/utils/uri.dart';

class ContentPage extends HookWidget {
  const ContentPage({super.key, required this.content});

  final Content content;

  @override
  Widget build(BuildContext context) {
    final t = getLocalizations(context);
    final configProvider = Provider.of<ConfigProvider>(context);
    Config config = configProvider.config;
    String hmacKey = config.hmacKey;

    final dlcs = useState<List<Content>>([]);
    final themes = useState<List<Content>>([]);
    final update = useState<Package?>(null);

    Future<void> fetchDLCs() async {
      if (content.type != 'app') {
        return;
      }
      final DatabaseHelper dbHelper = DatabaseHelper();
      List<Content> fetchedDLCs =
          await dbHelper.getContents(['dlc'], content.titleID);
      dlcs.value = [...fetchedDLCs];
    }

    Future<void> fetchThemes() async {
      if (content.type != 'app') {
        return;
      }
      final DatabaseHelper dbHelper = DatabaseHelper();
      List<Content> fetchedThemes =
          await dbHelper.getContents(['theme'], content.titleID);
      themes.value = [...fetchedThemes];
    }

    Future<void> fetchupdate(String hmacKey) async {
      if (content.type != 'app') {
        return;
      }
      Package? info = await getUpdateLink(content.titleID, hmacKey);
      update.value = info;
    }

    Future<void> copyToClipboard(String text, String description) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(description)),
        );
      }
    }

    useEffect(() {
      fetchDLCs();
      fetchThemes();
      if (hmacKey.isNotEmpty) {
        fetchupdate(hmacKey);
      }
      return;
    }, []);

    return Scaffold(
      appBar: AppBar(
          // title: Text(content.name),
          ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(16),
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
                            getContentIcon(content.contentID),
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
                      content.name,
                      style: const TextStyle(fontSize: 32.0),
                    ),
                    content.originalName.isEmpty
                        ? const SizedBox()
                        : Text(content.originalName),
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
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            content.type,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    content.appVersion.isEmpty && update.value?.version == null
                        ? const SizedBox()
                        : Text(
                            '${t.version}: ${update.value?.version ?? content.appVersion.toString()}'),
                    content.fileSize.isEmpty
                        ? const SizedBox()
                        : Text(
                            '${t.size}: ${fileSizeConvert(content.fileSize)} MB'),
                    update.value?.size == null
                        ? const SizedBox()
                        : Text(
                            '${t.updateSize}: ${fileSizeConvert(update.value!.size)} MB'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ElevatedButton(
                          onPressed: content.pkgDirectLink.isEmpty
                              ? null
                              : () => launchURL(content.pkgDirectLink),
                          child: Text(content.pkgDirectLink.isEmpty
                              ? t.dowloadLinkNotAvailable
                              : t.download),
                        ),
                        content.pkgDirectLink.isEmpty
                            ? const SizedBox()
                            : ElevatedButton(
                                onPressed: () => copyToClipboard(
                                    content.pkgDirectLink,
                                    t.downloadLinkCopied),
                                child: Text(content.pkgDirectLink.isEmpty
                                    ? t.dowloadLinkNotAvailable
                                    : t.copyLink),
                              ),
                        ElevatedButton(
                          onPressed: content.zRIF.isEmpty
                              ? null
                              : () =>
                                  copyToClipboard(content.zRIF, t.zRIFCopied),
                          child: Text(content.zRIF.isEmpty
                              ? t.zRIFNotAvailable
                              : '${t.copy} zRIF'),
                        ),
                        update.value?.url == null
                            ? const SizedBox()
                            : ElevatedButton(
                                onPressed: () => launchURL(update.value!.url),
                                child: Text(t.downloadUpdate),
                              ),
                        update.value?.url == null
                            ? const SizedBox()
                            : ElevatedButton(
                                onPressed: () => copyToClipboard(
                                    update.value!.url, t.updateLinkCopied),
                                child: Text(t.copyUpdateLink),
                              ),
                      ],
                    ),
                  ],
                )),
            themes.value.isEmpty
                ? const SizedBox()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      t.theme,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
            themes.value.isEmpty
                ? const SizedBox()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: themes.value.length,
                    itemBuilder: (context, index) {
                      final theme = themes.value[index];
                      return ListTile(
                          title: Text(theme.name),
                          onTap: () => Navigator.pushNamed(context, '/content',
                              arguments: theme),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              theme.pkgDirectLink.isEmpty
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () =>
                                          launchURL(theme.pkgDirectLink),
                                      icon: const Icon(Icons.download)),
                              theme.pkgDirectLink.isEmpty
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () => copyToClipboard(
                                          theme.pkgDirectLink, t.dlcLinkCopied),
                                      icon: const Icon(Icons.copy)),
                              theme.zRIF.isEmpty
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () => copyToClipboard(
                                          theme.zRIF, t.zRIFCopied),
                                      icon: const Icon(Icons.key)),
                            ],
                          ));
                    },
                  ),
            dlcs.value.isEmpty
                ? const SizedBox()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      t.dlc,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
            dlcs.value.isEmpty
                ? const SizedBox()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dlcs.value.length,
                    itemBuilder: (context, index) {
                      final dlc = dlcs.value[index];
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
                                      onPressed: () => copyToClipboard(
                                          dlc.pkgDirectLink, t.dlcLinkCopied),
                                      icon: const Icon(Icons.copy)),
                              dlc.zRIF.isEmpty
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () => copyToClipboard(
                                          dlc.zRIF, t.zRIFCopied),
                                      icon: const Icon(Icons.key)),
                            ],
                          ));
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
