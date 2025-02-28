import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/database/cookie.dart';
import 'package:tsdm_client/models/settings.dart';
import 'package:tsdm_client/providers/storage_provider.dart';

part '../generated/providers/settings_provider.g.dart';

/// Notifier of app settings.
@Riverpod(keepAlive: true, dependencies: [AppStorage])
class AppSettings extends _$AppSettings {
  /// Constructor.
  @override
  Settings build() {
    final storage = _getStorage();

    return Settings(
      dioAccept:
          storage.getString(settingsNetClientAccept) ?? _defaultDioAccept,
      dioAcceptEncoding: storage.getString(settingsNetClientAcceptEncoding) ??
          _defaultDioAcceptEncoding,
      dioAcceptLanguage: storage.getString(settingsNetClientAcceptLanguage) ??
          _defaultDioAcceptLanguage,
      dioUserAgent:
          storage.getString(settingsNetClientUserAgent) ?? _defaultDioUserAgent,
      windowWidth:
          storage.getDouble(settingsWindowWidth) ?? _defaultWindowWidth,
      windowHeight:
          storage.getDouble(settingsWindowHeight) ?? _defaultWindowHeight,
      windowPositionDx: storage.getDouble(settingsWindowPositionDx) ??
          _defaultWindowPositionDx,
      windowPositionDy: storage.getDouble(settingsWindowPositionDy) ??
          _defaultWindowPositionDy,
      windowInCenter:
          storage.getBool(settingsWindowInCenter) ?? _defaultWindowInCenter,
      loginUsername:
          storage.getString(settingsLoginUsername) ?? _defaultLoginUsername,
      loginUid: storage.getInt(settingsLoginUid) ?? _defaultLoginUid,
      themeMode: storage.getInt(settingsThemeMode) ?? _defaultThemeMode,
      locale: storage.getString(settingsLocale) ?? _defaultLocale,
      checkInFeeling:
          storage.getString(settingsCheckInFeeling) ?? _defaultCheckInFeeling,
      checkInMessage:
          storage.getString(settingsCheckInMessage) ?? _defaultCheckInMessage,
    );
  }

  /// Dio config: Accept.
  static const String _defaultDioAccept =
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7';

  /// Dio config: Accept-Encoding.
  ///
  /// FormatException happens in some page, current found in 301 request in redirect
  /// url in notice page.
  /// After debugging like this:
  /// https://github.com/flutter/flutter/issues/32558#issuecomment-886022246
  /// Remove "gzip" encoding in "Accept-Encoding" can fix this.
  static const String _defaultDioAcceptEncoding = 'deflate, br';

  /// Dio config: Accept-Language.
  static const String _defaultDioAcceptLanguage =
      'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,zh-TW;q=0.5';

  /// Dio config: User-Agent.
  static const String _defaultDioUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.57';

  /// Window position config on desktop platforms.
  static const _defaultWindowPositionDx = 0.0;

  /// Window position config on desktop platforms.
  static const _defaultWindowPositionDy = 0.0;

  /// Window width config on desktop platforms.
  static const _defaultWindowWidth = 600.0;

  /// Window height config on desktop platforms.
  static const _defaultWindowHeight = 800.0;

  /// Window whether in the center of screen config on desktop platforms.
  static const _defaultWindowInCenter = false;

  /// Login user username.
  static const _defaultLoginUsername = '';

  /// Login user uid.
  static const _defaultLoginUid = -1;

  /// Default app theme mode.
  ///
  /// 0: [ThemeMode.system]
  /// 1: [ThemeMode.light]
  /// 2: [ThemeMode.dark]
  static final _defaultThemeMode = ThemeMode.system.index;

  /// Locale
  ///
  /// Empty means follow system locale.
  static const _defaultLocale = '';

  /// Default feeling when check in
  static const _defaultCheckInFeeling = 'kx';

  /// Default check in message when check in
  static const _defaultCheckInMessage = '每日签到';

  Storage _getStorage() {
    return ref.read(appStorageProvider);
  }

  Future<void> setWindowSize(Size size) async {
    final storage = _getStorage();

    await storage.saveDouble(settingsWindowWidth, size.width);
    await storage.saveDouble(settingsWindowHeight, size.height);
    state = state.copyWith(
      windowPositionDx: size.width,
      windowPositionDy: size.height,
    );
  }

  Future<void> setWindowPosition(Offset offset) async {
    final storage = _getStorage();

    await storage.saveDouble(settingsWindowPositionDx, offset.dx);
    await storage.saveDouble(settingsWindowPositionDy, offset.dy);
    state = state.copyWith(
      windowPositionDx: offset.dx,
      windowPositionDy: offset.dy,
    );
  }

  Future<void> setThemeMode(int themeMode) async {
    final storage = _getStorage();

    await storage.saveInt(settingsThemeMode, themeMode);
    state = state.copyWith(themeMode: themeMode);
  }

  /// Update current login user username.
  ///
  /// Because in some situation we don't know uid (e.g. try to login), use this
  /// [username] to identify user.
  ///
  /// Note that the server side does not allow same username so it's safe to
  /// treat username as user identifier.
  Future<void> setLoginInfo(String username, int uid) async {
    final storage = _getStorage();

    await storage.saveString(settingsLoginUsername, username);
    await storage.saveInt(settingsLoginUid, uid);
    state = state.copyWith(loginUsername: username, loginUid: uid);
  }

  /// Get a cookie belongs to user with [username].
  ///
  /// Return null if not found.
  DatabaseCookie? getCookie(String username) {
    final storage = _getStorage();

    return storage.getCookie(username);
  }

  /// Save cookie into database.
  ///
  /// This function should only be called by cookie provider.
  Future<void> saveCookie(
    String username,
    Map<String, String> cookie,
  ) async {
    final storage = _getStorage();

    return storage.saveCookie(username, cookie);
  }

  /// Delete user [username]'s cookie from database.
  ///
  /// This function should only be called by cookie provider.
  Future<bool> deleteCookieByUsername(String username) async {
    final storage = _getStorage();

    return storage.deleteCookieByUsername(username);
  }

  Future<void> setLocale(String locale) async {
    final storage = _getStorage();

    // Filter invalid locales.
    // Empty locale means follow system locale.
    if (locale.isNotEmpty &&
        !AppLocale.values.any((v) => v.languageTag == locale)) {
      return;
    }
    await storage.saveString(settingsLocale, locale);
    state = state.copyWith(locale: locale);
  }

  Future<void> setCheckInFeeling(String feeling) async {
    final storage = _getStorage();
    await storage.saveString(settingsCheckInFeeling, feeling);
    state = state.copyWith(checkInFeeling: feeling);
  }

  Future<void> setCheckInMessage(String message) async {
    final storage = _getStorage();
    await storage.saveString(settingsCheckInMessage, message.truncate(50));
    state = state.copyWith(checkInMessage: message.truncate(50));
  }
}
