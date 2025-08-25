import 'package:flutter/material.dart';
import 'package:todo_app/models/list.dart';
import 'package:todo_app/services/list_service.dart';

class ListProvider extends ChangeNotifier {
  final ListService _listService = ListService();
  List<TaskList> _lists = [];
  TaskList? _currentList;
  bool _isLoading = false;

  List<TaskList> get lists => _lists.where((list) => list.isActive).toList();
  TaskList? get currentList => _currentList;
  bool get isLoading => _isLoading;

  ListProvider() {
    _loadLists();
  }

  Future<void> _loadLists() async {
    _isLoading = true;
    notifyListeners();

    try {
      _lists = await _listService.getActiveLists();
      _lists.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // Set first list as current if none selected
      if (_currentList == null && _lists.isNotEmpty) {
        _currentList = _lists.first;
      }
    } catch (e) {
      debugPrint('Error loading lists: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addList(String name) async {
    try {
      final newList = TaskList(name: name);
      await _listService.addList(newList);
      await _loadLists();
      
      // Set new list as current
      _currentList = newList;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding list: $e');
    }
  }

  Future<void> updateListName(String id, String newName) async {
    try {
      await _listService.updateListName(id, newName);
      await _loadLists();
    } catch (e) {
      debugPrint('Error updating list name: $e');
    }
  }

  Future<void> deleteList(String id) async {
    try {
      await _listService.deleteList(id);
      
      // If deleted list was current, switch to first available list
      if (_currentList?.id == id) {
        await _loadLists();
        _currentList = _lists.isNotEmpty ? _lists.first : null;
      } else {
        await _loadLists();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting list: $e');
    }
  }

  void setCurrentList(TaskList list) {
    _currentList = list;
    notifyListeners();
  }

  Future<void> refreshLists() async {
    await _loadLists();
  }

  // Create default list if none exist
  Future<void> ensureDefaultList() async {
    if (_lists.isEmpty) {
      await addList('My Tasks');
    }
  }
}