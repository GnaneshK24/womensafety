import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = Locale('en'); // Default language is English

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (Intl.verifiedLocale(newLocale.languageCode, (locale) => true, onFailure: (locale) => null) == null) return;
    _locale = newLocale;
    notifyListeners();
  }
}
