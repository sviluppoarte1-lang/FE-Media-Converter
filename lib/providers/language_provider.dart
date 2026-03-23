import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  final SharedPreferences prefs;
  
  LanguageProvider(this.prefs) {
    _loadLanguage();
  }

  static const String _languageKey = 'app_language';
  
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  void _loadLanguage() {
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    await prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }
}