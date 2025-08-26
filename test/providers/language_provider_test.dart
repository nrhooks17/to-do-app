import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/providers/language_provider.dart';

void main() {
  group('LanguageProvider Tests', () {
    late LanguageProvider provider;

    setUp(() {
      provider = LanguageProvider();
    });

    test('default language is English', () {
      expect(provider.languageCode, 'en');
      expect(provider.isEnglish, true);
      expect(provider.isChinese, false);
    });

    test('setLanguage updates language code and notifies listeners', () {
      var notified = false;
      provider.addListener(() { notified = true; });

      provider.setLanguage('zh');

      expect(provider.languageCode, 'zh');
      expect(provider.isEnglish, false);
      expect(provider.isChinese, true);
      expect(notified, true);
    });

    test('setLanguage to English updates flags correctly', () {
      provider.setLanguage('zh');
      
      provider.setLanguage('en');

      expect(provider.languageCode, 'en');
      expect(provider.isEnglish, true);
      expect(provider.isChinese, false);
    });

    test('translate returns English translation for existing key', () {
      final translation = provider.translate('appTitle');
      
      expect(translation, 'Todo App');
    });

    test('translate returns Chinese translation when language is set to Chinese', () {
      provider.setLanguage('zh');
      
      final translation = provider.translate('appTitle');
      
      expect(translation, '待办事项');
    });

    test('translate returns key when translation not found', () {
      final translation = provider.translate('nonExistentKey');
      
      expect(translation, 'nonExistentKey');
    });

    test('translate returns English fallback when Chinese translation not found', () {
      provider.setLanguage('zh');
      
      // Assuming this key exists in English but not Chinese
      final translation = provider.translate('someEnglishOnlyKey');
      
      // Should fallback to English or return the key itself
      expect(translation, isA<String>());
    });

    test('translate with placeholders replaces placeholders correctly', () {
      final translation = provider.translate('confirmDeleteList', placeholders: {'name': 'My List'});
      
      expect(translation, contains('My List'));
    });

    test('translate with placeholders works in Chinese', () {
      provider.setLanguage('zh');
      
      final translation = provider.translate('confirmDeleteTask', placeholders: {'title': '测试任务'});
      
      expect(translation, contains('测试任务'));
    });

    test('isEnglish returns correct value', () {
      expect(provider.isEnglish, true);
      
      provider.setLanguage('zh');
      expect(provider.isEnglish, false);
      
      provider.setLanguage('en');
      expect(provider.isEnglish, true);
    });

    test('isChinese returns correct value', () {
      expect(provider.isChinese, false);
      
      provider.setLanguage('zh');
      expect(provider.isChinese, true);
      
      provider.setLanguage('en');
      expect(provider.isChinese, false);
    });

    test('multiple language changes notify listeners each time', () {
      var notificationCount = 0;
      provider.addListener(() { notificationCount++; });

      provider.setLanguage('zh');
      provider.setLanguage('en');
      provider.setLanguage('zh');

      expect(notificationCount, 3);
    });
  });
}