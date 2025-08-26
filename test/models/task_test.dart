import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/models/task.dart';

void main() {
  group('Task Model Tests', () {
    late Directory tempDir;
    late Box<Task> taskBox;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      Hive.registerAdapter(TaskAdapter());
      taskBox = await Hive.openBox<Task>('test_tasks');
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    tearDown(() async {
      await taskBox.clear();
    });
    test('creates task with auto-generated ID when not provided', () {
      final task = Task(
        title: 'Test Task',
        listId: 'list1',
      );

      expect(task.id, isNotEmpty);
      expect(task.id.length, greaterThan(0));
      expect(task.title, 'Test Task');
      expect(task.listId, 'list1');
      expect(task.isCompleted, false);
      expect(task.description, '');
      expect(task.createdAt, isA<DateTime>());
    });

    test('creates task with provided ID', () {
      final task = Task(
        id: 'custom-id',
        title: 'Test Task',
        listId: 'list1',
      );

      expect(task.id, 'custom-id');
    });

    test('creates task with custom createdAt date', () {
      final customDate = DateTime(2023, 1, 1);
      final task = Task(
        title: 'Test Task',
        listId: 'list1',
        createdAt: customDate,
      );

      expect(task.createdAt, customDate);
    });

    test('toggleComplete changes completion state from false to true', () async {
      final task = Task(
        title: 'Test Task',
        listId: 'list1',
        isCompleted: false,
      );

      // Put task in box so it can call save()
      await taskBox.put(task.id, task);

      expect(task.isCompleted, false);
      task.toggleComplete();
      expect(task.isCompleted, true);
    });

    test('toggleComplete changes completion state from true to false', () async {
      final task = Task(
        title: 'Test Task',
        listId: 'list1',
        isCompleted: true,
      );

      // Put task in box so it can call save()
      await taskBox.put(task.id, task);

      expect(task.isCompleted, true);
      task.toggleComplete();
      expect(task.isCompleted, false);
    });

    test('updateTask updates only provided title field', () async {
      final task = Task(
        title: 'Original Title',
        description: 'Original Description',
        listId: 'list1',
        dueDate: DateTime(2023, 12, 25),
      );

      // Put task in box so it can call save()
      await taskBox.put(task.id, task);

      task.updateTask(title: 'Updated Title');

      expect(task.title, 'Updated Title');
      expect(task.description, 'Original Description'); // unchanged
      expect(task.dueDate, DateTime(2023, 12, 25)); // unchanged
    });

    test('updateTask updates only provided description field', () async {
      final task = Task(
        title: 'Original Title',
        description: 'Original Description',
        listId: 'list1',
      );

      // Put task in box so it can call save()
      await taskBox.put(task.id, task);

      task.updateTask(description: 'Updated Description');

      expect(task.title, 'Original Title'); // unchanged
      expect(task.description, 'Updated Description');
    });

    test('updateTask updates only provided dueDate field', () async {
      final task = Task(
        title: 'Original Title',
        listId: 'list1',
        dueDate: DateTime(2023, 12, 25),
      );

      // Put task in box so it can call save()
      await taskBox.put(task.id, task);

      final newDueDate = DateTime(2024, 1, 1);
      task.updateTask(dueDate: newDueDate);

      expect(task.title, 'Original Title'); // unchanged
      expect(task.dueDate, newDueDate);
    });

    test('updateTask updates multiple fields simultaneously', () async {
      final task = Task(
        title: 'Original Title',
        description: 'Original Description',
        listId: 'list1',
        dueDate: DateTime(2023, 12, 25),
      );

      // Put task in box so it can call save()
      await taskBox.put(task.id, task);

      final newDueDate = DateTime(2024, 1, 1);
      task.updateTask(
        title: 'New Title',
        description: 'New Description',
        dueDate: newDueDate,
      );

      expect(task.title, 'New Title');
      expect(task.description, 'New Description');
      expect(task.dueDate, newDueDate);
    });

    test('updateTask with null values does not change existing values', () async {
      final task = Task(
        title: 'Original Title',
        description: 'Original Description',
        listId: 'list1',
        dueDate: DateTime(2023, 12, 25),
      );

      // Put task in box so it can call save()
      await taskBox.put(task.id, task);

      task.updateTask(
        title: null,
        description: null,
        dueDate: null,
      );

      expect(task.title, 'Original Title');
      expect(task.description, 'Original Description');
      expect(task.dueDate, DateTime(2023, 12, 25));
    });

    test('task with dueDate creates correctly', () {
      final dueDate = DateTime(2024, 6, 15);
      final task = Task(
        title: 'Task with due date',
        listId: 'list1',
        dueDate: dueDate,
      );

      expect(task.dueDate, dueDate);
    });

    test('task without dueDate has null dueDate', () {
      final task = Task(
        title: 'Task without due date',
        listId: 'list1',
      );

      expect(task.dueDate, isNull);
    });
  });
}