import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/task_service.dart';

enum TaskFilter {
  all,
  active,
  completed,
}

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;
  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isLoading = false;
  String? _currentListId;

  List<Task> get tasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get currentListId => _currentListId;

  TaskProvider({required TaskService taskService}) : _taskService = taskService {
    // Don't load tasks immediately - wait for list to be selected
  }

  Future<void> _loadTasks() async {
    if (_currentListId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      switch (_currentFilter) {
        case TaskFilter.all:
          _tasks = await _taskService.getTasksForList(_currentListId!);
          break;
        case TaskFilter.active:
          _tasks = await _taskService.getActiveTasksForList(_currentListId!);
          break;
        case TaskFilter.completed:
          _tasks = await _taskService.getCompletedTasksForList(_currentListId!);
          break;
      }
      // Sort by created date, newest first
      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    _loadTasks();
  }

  Future<void> addTask(Task task) async {
    try {
      await _taskService.addTask(task);
      await _loadTasks();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _taskService.updateTask(task);
      await _loadTasks();
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskService.deleteTask(id);
      await _loadTasks();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    try {
      await _taskService.toggleTaskCompletion(id);
      await _loadTasks();
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  Future<void> deleteAllTasks() async {
    try {
      await _taskService.deleteAllTasks();
      await _loadTasks();
    } catch (e) {
      debugPrint('Error deleting all tasks: $e');
    }
  }

  Future<void> deleteCompletedTasks() async {
    try {
      await _taskService.deleteCompletedTasks();
      await _loadTasks();
    } catch (e) {
      debugPrint('Error deleting completed tasks: $e');
    }
  }

  Future<void> refreshTasks() async {
    await _loadTasks();
  }

  void setCurrentListId(String listId) {
    _currentListId = listId;
    _loadTasks();
  }

}
