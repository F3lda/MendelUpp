// lib/extensions/string_extensions_service_injection.dart
import 'package:flutter/material.dart';
import '../services/localization_service.dart';

// lib/utils/service_based_app_localizations.dart
import 'package:flutter/material.dart';
import '../services/localization_service.dart';

/*extension StringTranslation on String {
  /// Basic translation using context-based service injection
  String tr(BuildContext context, {Map<String, dynamic>? params}) {
    return context.localizationService.translate(this, params: params);
  }

  /// Plural translation using context-based service injection
  String trPlural(BuildContext context, num count, {Map<String, dynamic>? params}) {
    return context.localizationService.translatePlural(this, count, params: params);
  }
}*/
/*
// lib/extensions/context_extensions.dart
import 'package:flutter/material.dart';
import '../services/localization_service.dart';

// Your existing service extension - make sure this is properly implemented
extension MainServicesExtension on BuildContext {
  // This should connect to your actual service locator
  LocalizationService get localizationService => getService<LocalizationService>();
}*/

// lib/utils/service_based_app_localizations.dart
/*
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
    await _changeLocale(locale);
    //await context.localizationService.changeLocale(locale);
    return AppLocalizations();
  }

  @override
  bool shouldReload(ServiceBasedAppLocalizationsDelegate old) => false;
}

class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Basic translation using context service
  String tr(BuildContext context, String key, {Map<String, dynamic>? params}) {
    return context.localizationService.translate(key, params: params);
  }

  /// Plural translation using context service
  String trPlural(BuildContext context, String key, num count, {Map<String, dynamic>? params}) {
    return context.localizationService.translatePlural(key, count, params: params);
  }
}
*/
