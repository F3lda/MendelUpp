// lib/services/localization_service_with_plurals.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Libs/main_services_provider.dart';

class LocalizationService extends AppStartupService {

  @override
  String get serviceName => 'LocalizationService';

  static const String _localePrefsKey = 'saved_locale';

  Map<String, dynamic> _localizedStrings = {};
  Map<String, dynamic> _englishStrings = {};
  Locale _currentLocale = const Locale('en');
  List<Locale> _supportedLocales = [];
  bool _isInitialized = false;

  // Getters
  Locale get currentLocale => _currentLocale;
  List<Locale> get supportedLocales => _supportedLocales;
  bool get isInitialized => _isInitialized;
  Locale get systemLocale => PlatformDispatcher.instance.locale;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _discoverSupportedLocales();

      // Load saved locale from SharedPreferences first
      final savedLocale = await getSavedLocale();

      if (savedLocale != null && isLocaleSupported(savedLocale)) {
        _currentLocale = savedLocale;
        if (kDebugMode) {
          print('LocalizationService: Using saved locale ${_currentLocale.languageCode}');
        }
      } else {
        // Fall back to system locale if no saved locale or saved locale is not supported
        final systemLocale = PlatformDispatcher.instance.locale;
        _currentLocale = _supportedLocales.contains(systemLocale)
            ? systemLocale
            : const Locale('en');
        if (kDebugMode) {
          print('LocalizationService: Using system locale ${_currentLocale.languageCode}');
        }
      }

      await _loadEnglishTranslations();
      await _loadTranslations();

      _isInitialized = true;

      if (kDebugMode) {
        print('LocalizationService: Initialized successfully with locale ${_currentLocale.languageCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalizationService: Initialization failed - $e');
      }
      _isInitialized = false;
      rethrow;
    }
  }

  /// Save the current locale to SharedPreferences and switch to it
  Future<void> saveLocale(BuildContext context, Locale locale) async {
    // Check if locale is supported first
    if (!isLocaleSupported(locale)) {
      if (kDebugMode) {
        print('LocalizationService: Cannot save unsupported locale ${locale.languageCode}');
      }
      return;
    }

    try {
      final prefs = SharedPreferencesAsync();
      await prefs.setString(_localePrefsKey, locale.languageCode);

      if (kDebugMode) {
        print('LocalizationService: Saved locale ${locale.languageCode} to preferences');
      }

      // Switch to the saved locale
      await changeLocale(context, locale);
    } catch (e) {
      if (kDebugMode) {
        print('LocalizationService: Failed to save locale to preferences: $e');
      }
    }
  }

  /// Load saved locale from SharedPreferences
  Future<Locale?> getSavedLocale() async {
    try {
      final prefs = SharedPreferencesAsync();
      final savedLanguageCode = await prefs.getString(_localePrefsKey);

      if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
        if (kDebugMode) {
          print('LocalizationService: Found saved locale $savedLanguageCode in preferences');
        }
        return Locale(savedLanguageCode);
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalizationService: Failed to load saved locale from preferences: $e');
      }
    }

    return null;
  }

  /// Clear saved locale and switch to system locale
  Future<void> setSystemLocale(BuildContext context) async {
    try {
      // Clear saved locale from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localePrefsKey);

      if (kDebugMode) {
        print('LocalizationService: Cleared saved locale from preferences');
      }

      // Switch to system locale
      final systemLocale = PlatformDispatcher.instance.locale;
      final targetLocale = _supportedLocales.contains(systemLocale)
          ? systemLocale
          : const Locale('en');

      if (_currentLocale.languageCode != targetLocale.languageCode) {
        _currentLocale = targetLocale;
        await _loadTranslations();

        if (kDebugMode) {
          print('LocalizationService: Switched to system locale ${targetLocale.languageCode}');
        }

        context.serviceChanged();
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalizationService: Failed to set system locale: $e');
      }
    }
  }

  Future<void> _discoverSupportedLocales() async {
    _supportedLocales = [];

    if (await _checkTranslationFileExists('en')) {
      _supportedLocales.add(const Locale('en'));
      if (kDebugMode) {
        print('LocalizationService: Found English translation file');
      }
    }

    final systemLocale = PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode != 'en') {
      if (await _checkTranslationFileExists(systemLocale.languageCode)) {
        _supportedLocales.add(systemLocale);
        if (kDebugMode) {
          print('LocalizationService: Found system locale translation file for ${systemLocale.languageCode}');
        }
      }
    }

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final translationFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/translations/') && key.endsWith('.json'))
          .toList();

      for (final filePath in translationFiles) {
        final fileName = filePath.split('/').last;
        final langCode = fileName.replaceAll('.json', '');

        if (!_supportedLocales.any((locale) => locale.languageCode == langCode)) {
          _supportedLocales.add(Locale(langCode));
          if (kDebugMode) {
            print('LocalizationService: Found additional translation file for $langCode');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalizationService: Could not read AssetManifest.json for discovery: $e');
      }
    }

    if (!_supportedLocales.any((locale) => locale.languageCode == 'en')) {
      if (kDebugMode) {
        print('LocalizationService: Warning - No English translation file found, using keys as fallback');
      }
      _supportedLocales.insert(0, const Locale('en'));
    }

    _supportedLocales.sort((a, b) => a.languageCode.compareTo(b.languageCode));

    if (kDebugMode) {
      print('LocalizationService: Discovered ${_supportedLocales.length} translation files');
      print('LocalizationService: Supported locales: ${_supportedLocales.map((l) => l.languageCode).join(', ')}');
    }
  }

  Future<bool> _checkTranslationFileExists(String langCode) async {
    try {
      await rootBundle.loadString('assets/translations/$langCode.json');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadEnglishTranslations() async {
    try {
      final jsonString = await rootBundle.loadString('assets/translations/en.json');
      _englishStrings = json.decode(jsonString) as Map<String, dynamic>;
      if (kDebugMode) {
        print('LocalizationService: Loaded English translations (${_englishStrings.keys.length} root keys)');
      }
    } catch (e) {
      _englishStrings = {};
      if (kDebugMode) {
        print('LocalizationService: No English translation file found, will use keys as fallback');
      }
    }
  }

  Future<void> _loadTranslations() async {
    if (_currentLocale.languageCode == 'en') {
      _localizedStrings = Map.from(_englishStrings);
      return;
    }

    try {
      final jsonString = await rootBundle.loadString(
          'assets/translations/${_currentLocale.languageCode}.json'
      );
      _localizedStrings = json.decode(jsonString) as Map<String, dynamic>;
      if (kDebugMode) {
        print('LocalizationService: Loaded translations for ${_currentLocale.languageCode} (${_localizedStrings.keys.length} root keys)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocalizationService: Failed to load translations for ${_currentLocale.languageCode}, using English fallback');
      }
      _localizedStrings = Map.from(_englishStrings);
    }
  }

  Future<void> changeLocale(BuildContext? context, Locale locale) async {
    if (!isLocaleSupported(locale)) {
      if (kDebugMode) {
        print('LocalizationService: Locale ${locale.languageCode} not supported');
      }
      return;
    }

    if (_currentLocale.languageCode == locale.languageCode) return;

    _currentLocale = locale;
    await _loadTranslations();

    // Save the new locale to SharedPreferences (but don't call changeLocale again to avoid recursion)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePrefsKey, locale.languageCode);
    } catch (e) {
      if (kDebugMode) {
        print('LocalizationService: Failed to save locale to preferences: $e');
      }
    }

    if (kDebugMode) {
      print('LocalizationService: Changed locale to ${locale.languageCode}');
    }

    if (context != null) {
      context.serviceChanged();
    }
  }

  /// Check if a specific locale is supported by the service
  bool isLocaleSupported(Locale locale) {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('LocalizationService: Service not initialized, locale support may not be complete');
      }
      //return false;
    }

    // Check exact match first (language + country)
    bool exactMatch = _supportedLocales.any((supportedLocale) =>
    supportedLocale.languageCode == locale.languageCode &&
        supportedLocale.countryCode == locale.countryCode
    );

    if (exactMatch) {
      return true;
    }

    // Check language-only match (more flexible)
    bool languageMatch = _supportedLocales.any((supportedLocale) =>
    supportedLocale.languageCode == locale.languageCode
    );

    if (kDebugMode && languageMatch) {
      print('LocalizationService: Found language match for ${locale.languageCode} (${locale.countryCode != null ? 'ignoring country code ${locale.countryCode}' : 'no country code'})');
    }

    return languageMatch;
  }

  /// Standard translation method
  String translate(String key, {Map<String, dynamic>? params}) {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('LocalizationService: Service not initialized, returning key: $key');
      }
      return key;
    }

    String result = _getTranslationValue(key, _localizedStrings);

    if (result == key && _currentLocale.languageCode != 'en' && _englishStrings.isNotEmpty) {
      result = _getTranslationValue(key, _englishStrings);
      if (result != key && kDebugMode) {
        print('LocalizationService: Using English fallback for key "$key"');
      }
    }

    if (result == key && kDebugMode) {
      print('LocalizationService: Missing translation for key "$key" in ${_currentLocale.languageCode} and English');
    }

    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{$paramKey}', paramValue.toString());
      });
    }

    return result;
  }

  /// Plural-aware translation method
  String translatePlural(String key, num count, {Map<String, dynamic>? params}) {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('LocalizationService: Service not initialized, returning key: $key');
      }
      return key;
    }

    // Try to get plural translation from current locale
    Map<String, dynamic>? pluralMap = _getPluralTranslations(key, _localizedStrings);

    // Fallback to English if not found
    if (pluralMap == null && _currentLocale.languageCode != 'en' && _englishStrings.isNotEmpty) {
      pluralMap = _getPluralTranslations(key, _englishStrings);
      if (pluralMap != null && kDebugMode) {
        print('LocalizationService: Using English plural fallback for key "$key"');
      }
    }

    String result;
    if (pluralMap != null) {
      result = _selectPluralForm(pluralMap, count, _currentLocale.languageCode);
    } else {
      if (kDebugMode) {
        print('LocalizationService: Missing plural translation for key "$key"');
      }
      result = key;
    }

    // Replace count parameter and other parameters
    Map<String, dynamic> allParams = {'count': count};
    if (params != null) {
      allParams.addAll(params);
    }

    allParams.forEach((paramKey, paramValue) {
      result = result.replaceAll('{$paramKey}', paramValue.toString());
    });

    return result;
  }

  Map<String, dynamic>? _getPluralTranslations(String key, Map<String, dynamic> translations) {
    final keys = key.split('.');
    dynamic value = translations;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }

    if (value is Map<String, dynamic>) {
      // Check if this looks like a plural map
      final pluralKeys = ['zero', 'one', 'two', 'few', 'many', 'other'];
      if (value.keys.any((key) => pluralKeys.contains(key))) {
        return value;
      }
    }

    return null;
  }

  String _selectPluralForm(Map<String, dynamic> pluralMap, num count, String languageCode) {
    // Determine plural category based on language-specific rules
    final category = _getPluralCategory(count, languageCode);

    // Try to get the exact plural form
    if (pluralMap.containsKey(category)) {
      return pluralMap[category].toString();
    }

    // Fallback chain: other -> one -> first available key
    if (pluralMap.containsKey('other')) {
      return pluralMap['other'].toString();
    }

    if (pluralMap.containsKey('one')) {
      return pluralMap['one'].toString();
    }

    // Return first available value
    return pluralMap.values.first.toString();
  }

  String _getPluralCategory(num count, String languageCode) {
    final n = count.abs();
    final i = n.floor();

    switch (languageCode) {
    // English, German, Dutch, Swedish, Danish, Norwegian, Finnish
      case 'en':
      case 'de':
      case 'nl':
      case 'sv':
      case 'da':
      case 'no':
      case 'fi':
        return i == 1 ? 'one' : 'other';

    // French, Portuguese (Brazil)
      case 'fr':
      case 'pt':
        return i == 0 || i == 1 ? 'one' : 'other';

    // Spanish, Italian
      case 'es':
      case 'it':
        return i == 1 ? 'one' : 'other';

    // Russian, Ukrainian, Serbian, Croatian
      case 'ru':
      case 'uk':
      case 'sr':
      case 'hr':
        final mod10 = i % 10;
        final mod100 = i % 100;

        if (mod10 == 1 && mod100 != 11) {
          return 'one';
        } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
          return 'few';
        } else {
          return 'many';
        }

    // Polish
      case 'pl':
        final mod10 = i % 10;
        final mod100 = i % 100;

        if (i == 1) {
          return 'one';
        } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
          return 'few';
        } else {
          return 'many';
        }

    // Czech, Slovak
      case 'cs':
      case 'sk':
        if (i == 1) {
          return 'one';
        } else if (i >= 2 && i <= 4) {
          return 'few';
        } else {
          return 'other';
        }

    // Arabic
      case 'ar':
        if (i == 0) {
          return 'zero';
        } else if (i == 1) {
          return 'one';
        } else if (i == 2) {
          return 'two';
        } else if (i % 100 >= 3 && i % 100 <= 10) {
          return 'few';
        } else if (i % 100 >= 11) {
          return 'many';
        } else {
          return 'other';
        }

    // Japanese, Korean, Chinese, Thai, Vietnamese
      case 'ja':
      case 'ko':
      case 'zh':
      case 'th':
      case 'vi':
        return 'other'; // No plural distinction

    // Default: English-like rules
      default:
        return i == 1 ? 'one' : 'other';
    }
  }

  String _getTranslationValue(String key, Map<String, dynamic> translations) {
    if (translations.isEmpty) return key;

    final keys = key.split('.');
    dynamic value = translations;

    for (int i = 0; i < keys.length; i++) {
      final k = keys[i];
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key;
      }
    }

    return value?.toString() ?? key;
  }

  @override
  void dispose() {
    _localizedStrings.clear();
    _englishStrings.clear();
    _supportedLocales.clear();
    _isInitialized = false;

    if (kDebugMode) {
      print('LocalizationService: Service disposed');
    }
  }
}

// Main extension for accessing services and data
extension MainServicesExtension on BuildContext {
  // Service getters with intuitive names
  LocalizationService get localizationService => getService<LocalizationService>(); // allows usage: context.localizationService.translate('app.title')

  String tr(String key, {Map<String, dynamic>? params}) { // allows usage: context.tr('app.title')
    return localizationService.translate(key, params: params);
  }

  String trPlural(String key, num count, {Map<String, dynamic>? params}) {
    return localizationService.translatePlural(key, count, params: params);
  }
}



// lib/utils/service_based_app_localizations.dart

class ServiceBasedAppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  //final BuildContext context;
  final Function _changeLocale;
  final Function _isLocaleSupported;

  const ServiceBasedAppLocalizationsDelegate(this._isLocaleSupported, this._changeLocale);

  @override
  bool isSupported(Locale locale) {
    return _isLocaleSupported(locale);
    //return context.localizationService.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    await _changeLocale(null, locale);
    //await context.localizationService.changeLocale(locale);
    return AppLocalizations(); // allows usage: Localizations.of(context, AppLocalizations).tr('app.title')
  }

  @override
  bool shouldReload(ServiceBasedAppLocalizationsDelegate old) => false;
}

class AppLocalizations {
  /*static AppLocalizations of(BuildContext context) { // allows usage: AppLocalizations.of(context).tr('app.title')
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Basic translation using context service
  String tr(BuildContext context, String key, {Map<String, dynamic>? params}) {
    return context.localizationService.translate(key, params: params);
  }

  // Plural translation using context service
  String trPlural(BuildContext context, String key, num count, {Map<String, dynamic>? params}) {
    return context.localizationService.translatePlural(key, count, params: params);
  }*/
}
