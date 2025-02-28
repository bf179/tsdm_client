import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/git_info.dart';
import 'package:tsdm_client/widgets/section_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  static const _gitInfo =
      '$gitCommitRevisionShort ($gitCommitTimeYear-$gitCommitTimeMonth-$gitCommitTimeDay)';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settingsPage.othersSection.about),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            onPressed: () async {
              const data = '''
## Info

* Version: $_gitInfo
* Flutter: $flutterVersion $flutterChannel ($flutterFrameworkRevision)
* Dart: $dartVersion
''';
              await Clipboard.setData(const ClipboardData(text: data));
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.t.aboutPage.copiedToClipboard),
              ));
            },
          )
        ],
      ),
      body: ListView(
        children: [
          Image.asset(
            './assets/images/tsdm_client.png',
            width: 192,
            height: 192,
          ),
          sizedBoxW10H10,
          SectionListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: Text(context.t.aboutPage.whatIsThis),
            subtitle: Text(context.t.aboutPage.description),
          ),
          SectionListTile(
            leading: const Icon(Icons.app_shortcut_outlined),
            title: Text(context.t.aboutPage.packageName),
            subtitle: const Text('kzs.th000.tsdm_client'),
          ),
          SectionListTile(
            leading: const Icon(Icons.terminal_outlined),
            title: Text(context.t.aboutPage.version),
            subtitle: const Text(_gitInfo),
          ),
          SectionListTile(
            leading: const Icon(Icons.home_max_outlined),
            title: Text(context.t.aboutPage.forumHomepage),
            subtitle: const Text(baseUrl),
            onTap: () async {
              await launchUrl(
                Uri.parse(baseUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SectionListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(context.t.aboutPage.homepage),
            subtitle: const Text('https://github.com/realth000/tsdm_client'),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://github.com/realth000/tsdm_client'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SectionListTile(
            leading: const Icon(Icons.flutter_dash_outlined),
            title: Text(context.t.aboutPage.flutterVersion),
            subtitle: const Text(
              '$flutterVersion ($flutterChannel) - $flutterFrameworkRevision',
            ),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://flutter.dev/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SectionListTile(
            leading: const Icon(Icons.foundation_outlined),
            title: Text(context.t.aboutPage.dartVersion),
            subtitle: const Text(dartVersion),
            onTap: () async {
              await launchUrl(
                Uri.parse('https://dart.dev/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SectionListTile(
            leading: const Icon(Icons.balance_outlined),
            title: Text(context.t.aboutPage.license),
            subtitle: const Text('MIT license'),
          )
        ],
      ),
    );
  }
}
