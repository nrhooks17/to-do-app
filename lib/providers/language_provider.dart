import 'package:flutter/material.dart';
import 'package:todo_app/utils/translations.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'en';

  String get languageCode => _languageCode;

  void setLanguage(String languageCode) {
    _languageCode = languageCode;
    notifyListeners();
  }

  String translate(String key, {Map<String, String>? placeholders}) {
    return Translations.get(key, _languageCode, placeholders: placeholders);
  }

  bool get isEnglish => _languageCode == 'en';
  bool get isChinese => _languageCode == 'zh';
}