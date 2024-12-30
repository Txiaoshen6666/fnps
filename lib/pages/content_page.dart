import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:provider/provider.dart';
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

    Future<List<Content>> getDLCs() async {
      if (content.type != 'app') {
        return [];
      }
      final DatabaseHelper dbHelper = DatabaseHelper();
      List<Content> fetchedDLCs =
          await dbHelper.getContents(['dlc'], content.titleID);
      return [...fetchedDLCs];
    }

    Future<List<Content>> getThemes() async {
      if (content.type != 'app') {
        return [];
      }
      final DatabaseHelper dbHelper = DatabaseHelper();
      List<Content> fetchedThemes =
          await dbHelper.getContents(['theme'], content.titleID);
      return [...fetchedThemes];
    }

    Future<Update?> getUpdate(String hmacKey) async {
      if (content.type != 'app' || hmacKey.isEmpty) {
        return null;
      }
      Update? info = await getUpdateLink(content.titleID, hmacKey);
      return info;
    }

    final dlcFuture = useMemoized(() => getDLCs());
    final themeFuture = useMemoized(() => getThemes());
    final updateFuture = useMemoized(() => getUpdate(hmacKey));
    final contentInfoFuture =
        useMemoized(() => getContentInfo(content.contentID));

    final dlcs = useFuture(dlcFuture).data ?? [];
    final themes = useFuture(themeFuture).data ?? [];
    final update = useFuture(updateFuture).data;
    final contentInfo = useFuture(contentInfoFuture).data;

    Future<void> copyToClipboard(String text, String description) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(description)),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(content.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // 图标
                      SizedBox(
                        width: 128,
                        height: 128,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: getContentIcon(content.contentID),
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.gamepad),
                          ),
                        ),
                      ),
                      // 信息
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            content.name,
                            style: const TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                          content.originalName.isEmpty
                              ? const SizedBox()
                              : Text(content.originalName),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
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
                          content.appVersion.isEmpty && update?.version == null
                              ? const SizedBox()
                              : Text(
                                  '${t.version}: ${update?.version ?? content.appVersion.toString()}'),
                          content.fileSize.isEmpty
                              ? const SizedBox()
                              : Text(
                                  '${t.size}: ${fileSizeConvert(content.fileSize)} MB'),
                          update?.size == null
                              ? const SizedBox()
                              : Text(
                                  '${t.updateSize}: ${fileSizeConvert(update!.size)} MB'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 各种按钮
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
                                  content.pkgDirectLink, t.downloadLinkCopied),
                              child: Text(content.pkgDirectLink.isEmpty
                                  ? t.dowloadLinkNotAvailable
                                  : t.copyLink),
                            ),
                      ElevatedButton(
                        onPressed: content.zRIF.isEmpty
                            ? null
                            : () => copyToClipboard(content.zRIF, t.zRIFCopied),
                        child: Text(content.zRIF.isEmpty
                            ? t.zRIFNotAvailable
                            : '${t.copy} zRIF'),
                      ),
                      update?.url == null
                          ? const SizedBox()
                          : ElevatedButton(
                              onPressed: () => launchURL(update!.url),
                              child: Text(t.downloadUpdate),
                            ),
                      update?.url == null
                          ? const SizedBox()
                          : ElevatedButton(
                              onPressed: () => copyToClipboard(
                                  update!.url, t.updateLinkCopied),
                              child: Text(t.copyUpdateLink),
                            ),
                    ],
                  ),
                  // 截图
                  contentInfo == null || contentInfo.images.isEmpty
                      ? const SizedBox()
                      : const SizedBox(height: 16),
                  contentInfo == null || contentInfo.images.isEmpty
                      ? const SizedBox()
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: contentInfo.images
                                .map(
                                  (image) => Container(
                                    padding: const EdgeInsets.all(4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: image,
                                        fit: BoxFit.contain,
                                        width: 480 / 3 * 2,
                                        height: 272 / 3 * 2,
                                        placeholder: (context, url) =>
                                            const SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ],
              ),
            ),
            // 描述
            contentInfo == null || contentInfo.desc.isEmpty
                ? const SizedBox()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: html.Html(
                      data: contentInfo.desc,
                    ),
                  ),
            // 主题
            themes.isEmpty
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
            themes.isEmpty
                ? const SizedBox()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: themes.length,
                    itemBuilder: (context, index) {
                      final theme = themes[index];
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
                        ),
                      );
                    },
                  ),

            // DLC
            dlcs.isEmpty
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
                                    onPressed: () => copyToClipboard(
                                        dlc.pkgDirectLink, t.dlcLinkCopied),
                                    icon: const Icon(Icons.copy)),
                            dlc.zRIF.isEmpty
                                ? const SizedBox()
                                : IconButton(
                                    onPressed: () =>
                                        copyToClipboard(dlc.zRIF, t.zRIFCopied),
                                    icon: const Icon(Icons.key),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
