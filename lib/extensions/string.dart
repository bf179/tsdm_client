import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/routes/app_routes.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/time.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

extension ParseUrl on String {
  /// Try parse string to [AppRoute] with arguments.
  (String, Map<String, String>)? parseUrlToRoute() {
    final fidRe = RegExp(r'fid=(?<Fid>\d+)');
    final fidMatch = fidRe.firstMatch(this);
    if (fidMatch != null) {
      return (ScreenPaths.forum, {'fid': "${fidMatch.namedGroup('Fid')}"});
    }

    final tidRe = RegExp(r'tid=(?<Tid>\d+)');
    final tidMatch = tidRe.firstMatch(this);
    if (tidMatch != null) {
      return (ScreenPaths.thread, {'tid': "${tidMatch.namedGroup('Tid')}"});
    }

    return null;
  }

  /// Parse self as an uri and return the value of parameter [name].
  String? uriQueryParameter(String name) {
    return Uri.parse(this).queryParameters[name];
  }
}

extension EnhanceModification on String {
  /// Prepend [prefix].
  String? prepend(String prefix) {
    return '$prefix$this';
  }

  /// Prepend host url.
  String prependHost() {
    return '$baseUrl/$this';
  }
}

extension ParseStringTo on String {
  int? parseToInt() {
    return int.parse(this);
  }

  DateTime? parseToDateTimeUtc8() {
    return DateTime.tryParse(formatTimeStringWithUTC8(this));
  }
}

extension ImageCacheFileName on String {
  String fileNameV5() {
    return _uuid.v5(Namespace.URL, this);
  }
}
