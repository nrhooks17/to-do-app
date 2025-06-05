import 'package:flutter/material.dart';
import 'package:todo_app/services/task_service.dart';

class AIProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  String _userMessage = '';
  String _aiMessage = '';
  bool _isLoading = false;
  
  String get userMessage => _userMessage;
  String get aiMessage => _aiMessage;
  bool get isLoading => _isLoading;

 
  Future<void> getAiResponse() async {
    _isLoading = true;
    notifyListeners();

    try {
      _aiMessage = await _aiService.askAI(_userMessage);

      _userMessage = '';

    } catch (e) {
      debugPrint('Error sending message: $e');
    } {
      _isLoading = false;
      notifyListeners();
    }

  }
}
