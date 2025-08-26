import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/models/list.dart';

void main() {
  group('TaskList Model Tests', () {
    late Directory tempDir;
    late Box<TaskList> listBox;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      Hive.registerAdapter(TaskListAdapter());
      listBox = await Hive.openBox<TaskList>('test_lists');
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    tearDown(() async {
      await listBox.clear();
    });
    test('creates list with auto-generated ID when not provided', () {
      final list = TaskList(name: 'My List');

      expect(list.id, isNotEmpty);
      expect(list.id.length, greaterThan(0));
      expect(list.name, 'My List');
      expect(list.isActive, true);
    });

    test('creates list with provided ID', () {
      final list = TaskList(
        id: 'custom-id',
        name: 'My List',
      );

      expect(list.id, 'custom-id');
    });

    test('creates list with isActive flag set to false', () {
      final list = TaskList(
        name: 'Inactive List',
        isActive: false,
      );

      expect(list.name, 'Inactive List');
      expect(list.isActive, false);
    });

    test('deleteList sets isActive flag to false', () async {
      final list = TaskList(name: 'Active List');

      // Put list in box so it can call save()
      await listBox.put(list.id, list);

      expect(list.isActive, true);
      
      list.deleteList();
      
      expect(list.isActive, false);
    });

    test('deleteList on already inactive list remains inactive', () async {
      final list = TaskList(
        name: 'Already Inactive',
        isActive: false,
      );

      // Put list in box so it can call save()
      await listBox.put(list.id, list);

      expect(list.isActive, false);
      
      list.deleteList();
      
      expect(list.isActive, false);
    });

    test('restore sets isActive flag to true', () async {
      final list = TaskList(
        name: 'Inactive List',
        isActive: false,
      );

      // Put list in box so it can call save()
      await listBox.put(list.id, list);

      expect(list.isActive, false);
      
      list.restore();
      
      expect(list.isActive, true);
    });

    test('restore on active list remains active', () async {
      final list = TaskList(name: 'Active List');

      // Put list in box so it can call save()
      await listBox.put(list.id, list);

      expect(list.isActive, true);
      
      list.restore();
      
      expect(list.isActive, true);
    });

    test('different lists have different IDs', () {
      final list1 = TaskList(name: 'List 1');
      final list2 = TaskList(name: 'List 2');

      expect(list1.id, isNot(equals(list2.id)));
    });

    test('name property is correctly set and retrieved', () {
      const listName = 'Shopping List';
      final list = TaskList(name: listName);

      expect(list.name, listName);
    });

    test('default isActive is true when not specified', () {
      final list = TaskList(name: 'Default List');

      expect(list.isActive, true);
    });
  });
}