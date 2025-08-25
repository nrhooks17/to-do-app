import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/models/list.dart';

class ListService {
  static const String _boxName = 'lists';
  
  Future<Box<TaskList>> get _box async => await Hive.openBox<TaskList>(_boxName);
  
  Future<List<TaskList>> getAllLists() async {
    final box = await _box;
    return box.values.toList();
  }
  
  Future<List<TaskList>> getActiveLists() async {
    final box = await _box;
    return box.values.where((list) => list.isActive).toList();
  }
  
  Future<List<TaskList>> getDeletedLists() async {
    final box = await _box;
    return box.values.where((list) => !list.isActive).toList();
  }
  
  Future<TaskList?> getListById(String id) async {
    final box = await _box;
    return box.get(id);
  }
  
  Future<void> addList(TaskList list) async {
    final box = await _box;
    await box.put(list.id, list);
  }
  
  Future<void> updateList(TaskList list) async {
    final box = await _box;
    await box.put(list.id, list);
  }
  
  Future<void> deleteList(String id) async {
    final box = await _box;
    final list = box.get(id);
    if (list != null) {
      list.deleteList();
      await box.put(id, list);
    }
  }
  
  Future<void> restoreList(String id) async {
    final box = await _box;
    final list = box.get(id);
    if (list != null) {
      list.restore();
      await box.put(id, list);
    }
  }
  
  Future<void> updateListName(String id, String newName) async {
    final box = await _box;
    final list = box.get(id);
    if (list != null) {
      list.changeName(name: newName);
      await box.put(id, list);
    }
  }
  
  Future<void> permanentlyDeleteList(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}