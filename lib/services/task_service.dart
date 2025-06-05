import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/models/task.dart';

class TaskService {
  static const String _boxName = 'tasks';
  
  Future<Box<Task>> get _box async => await Hive.openBox<Task>(_boxName);
  
  Future<List<Task>> getAllTasks() async {
    final box = await _box;
    return box.values.toList();
  }
  
  Future<List<Task>> getCompletedTasks() async {
    final box = await _box;
    return box.values.where((task) => task.isCompleted).toList();
  }
  
  Future<List<Task>> getActiveTasks() async {
    final box = await _box;
    return box.values.where((task) => !task.isCompleted).toList();
  }
  
  Future<void> addTask(Task task) async {
    final box = await _box;
    await box.put(task.id, task);
  }
  
  Future<void> updateTask(Task task) async {
    final box = await _box;
    await box.put(task.id, task);
  }
  
  Future<void> deleteTask(String id) async {
    final box = await _box;
    await box.delete(id);
  }
  
  Future<void> toggleTaskCompletion(String id) async {
    final box = await _box;
    final task = box.get(id);
    if (task != null) {
      task.toggleComplete();
      await box.put(id, task);
    }
  }
  
  Future<void> deleteAllTasks() async {
    final box = await _box;
    await box.clear();
  }
  
  Future<void> deleteCompletedTasks() async {
    final box = await _box;
    final completedTaskKeys = box.values
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList();
    
    for (var key in completedTaskKeys) {
      await box.delete(key);
    }
  }
}
