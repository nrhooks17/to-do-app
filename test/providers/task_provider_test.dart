import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/services/task_service.dart';

// Generate mocks
@GenerateMocks([TaskService])
import 'task_provider_test.mocks.dart';

void main() {
  group('TaskProvider Tests', () {
    late TaskProvider provider;
    late MockTaskService mockTaskService;

    setUp(() {
      mockTaskService = MockTaskService();
      provider = TaskProvider(taskService: mockTaskService);
    });

    test('addTask calls service addTask and reloads tasks', () async {
      final task = Task(title: 'Test Task', listId: 'list1');
      when(mockTaskService.addTask(task)).thenAnswer((_) async {});
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => [task]);
      
      provider.setCurrentListId('list1');
      await provider.addTask(task);
      
      verify(mockTaskService.addTask(task)).called(1);
      verify(mockTaskService.getTasksForList('list1')).called(2); // Once for setCurrentListId, once for addTask
      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.title, 'Test Task');
    });

    test('updateTask calls service updateTask and reloads tasks', () async {
      final task = Task(title: 'Updated Task', listId: 'list1');
      when(mockTaskService.updateTask(task)).thenAnswer((_) async {});
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => [task]);
      
      provider.setCurrentListId('list1');
      await provider.updateTask(task);
      
      verify(mockTaskService.updateTask(task)).called(1);
      expect(provider.tasks.first.title, 'Updated Task');
    });

    test('deleteTask calls service deleteTask and reloads tasks', () async {
      when(mockTaskService.deleteTask('task-id')).thenAnswer((_) async {});
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => []);
      
      provider.setCurrentListId('list1');
      await provider.deleteTask('task-id');
      
      verify(mockTaskService.deleteTask('task-id')).called(1);
      expect(provider.tasks.length, 0);
    });

    test('toggleTaskCompletion calls service and reloads tasks', () async {
      final task = Task(title: 'Task', listId: 'list1', isCompleted: true);
      when(mockTaskService.toggleTaskCompletion('task-id')).thenAnswer((_) async {});
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => [task]);
      
      provider.setCurrentListId('list1');
      await provider.toggleTaskCompletion('task-id');
      
      verify(mockTaskService.toggleTaskCompletion('task-id')).called(1);
      expect(provider.tasks.first.isCompleted, true);
    });

    test('setFilter to all loads all tasks for current list', () async {
      final tasks = [
        Task(title: 'Active', isCompleted: false, listId: 'list1'),
        Task(title: 'Completed', isCompleted: true, listId: 'list1'),
      ];
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => tasks);

      provider.setCurrentListId('list1');
      await Future.delayed(Duration.zero); // Wait for async call
      provider.setFilter(TaskFilter.all);
      await Future.delayed(Duration.zero); // Wait for async call

      verify(mockTaskService.getTasksForList('list1')).called(2); // Once for setCurrentListId, once for setFilter
      expect(provider.tasks.length, 2);
    });

    test('setFilter to active loads only active tasks for current list', () async {
      final activeTasks = [
        Task(title: 'Active 1', isCompleted: false, listId: 'list1'),
        Task(title: 'Active 2', isCompleted: false, listId: 'list1'),
      ];
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => []);
      when(mockTaskService.getActiveTasksForList('list1')).thenAnswer((_) async => activeTasks);

      provider.setCurrentListId('list1');
      await Future.delayed(Duration.zero); // Wait for async call
      provider.setFilter(TaskFilter.active);
      await Future.delayed(Duration.zero); // Wait for async call

      verify(mockTaskService.getActiveTasksForList('list1')).called(1);
      expect(provider.tasks.length, 2);
      expect(provider.tasks.every((t) => !t.isCompleted), true);
    });

    test('setFilter to completed loads only completed tasks for current list', () async {
      final completedTasks = [
        Task(title: 'Completed 1', isCompleted: true, listId: 'list1'),
        Task(title: 'Completed 2', isCompleted: true, listId: 'list1'),
      ];
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => []);
      when(mockTaskService.getCompletedTasksForList('list1')).thenAnswer((_) async => completedTasks);

      provider.setCurrentListId('list1');
      await Future.delayed(Duration.zero); // Wait for async call
      provider.setFilter(TaskFilter.completed);
      await Future.delayed(Duration.zero); // Wait for async call

      verify(mockTaskService.getCompletedTasksForList('list1')).called(1);
      expect(provider.tasks.length, 2);
      expect(provider.tasks.every((t) => t.isCompleted), true);
    });

    test('setCurrentListId loads tasks for new list', () async {
      final tasks = [Task(title: 'List Task', listId: 'list2')];
      when(mockTaskService.getTasksForList('list2')).thenAnswer((_) async => tasks);

      provider.setCurrentListId('list2');
      await Future.delayed(Duration.zero); // Wait for async call

      verify(mockTaskService.getTasksForList('list2')).called(1);
      expect(provider.currentListId, 'list2');
      expect(provider.tasks.length, 1);
    });

    test('deleteCompletedTasks calls service and reloads tasks', () async {
      when(mockTaskService.deleteCompletedTasks()).thenAnswer((_) async {});
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => []);

      provider.setCurrentListId('list1');
      await provider.deleteCompletedTasks();

      verify(mockTaskService.deleteCompletedTasks()).called(1);
      verify(mockTaskService.getTasksForList('list1')).called(2); // Once for setCurrentListId, once for deleteCompletedTasks
    });

    test('deleteAllTasks calls service and reloads tasks', () async {
      when(mockTaskService.deleteAllTasks()).thenAnswer((_) async {});
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => []);

      provider.setCurrentListId('list1');
      await provider.deleteAllTasks();

      verify(mockTaskService.deleteAllTasks()).called(1);
      expect(provider.tasks.length, 0);
    });

    test('refreshTasks reloads tasks from service', () async {
      final tasks = [Task(title: 'Refreshed Task', listId: 'list1')];
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => tasks);

      provider.setCurrentListId('list1');
      await provider.refreshTasks();

      verify(mockTaskService.getTasksForList('list1')).called(2); // Once for setCurrentListId, once for refreshTasks
      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.title, 'Refreshed Task');
    });

    test('setCurrentListId updates current list and notifies listeners', () async {
      var notified = false;
      when(mockTaskService.getTasksForList('new-list')).thenAnswer((_) async => []);
      provider.addListener(() { notified = true; });

      provider.setCurrentListId('new-list');

      expect(provider.currentListId, 'new-list');
      expect(notified, true);
    });

    test('setFilter updates filter and notifies listeners', () async {
      var notified = false;
      when(mockTaskService.getTasksForList('list1')).thenAnswer((_) async => []);
      when(mockTaskService.getActiveTasksForList('list1')).thenAnswer((_) async => []);
      provider.addListener(() { notified = true; });

      provider.setCurrentListId('list1');
      provider.setFilter(TaskFilter.active);

      expect(provider.currentFilter, TaskFilter.active);
      expect(notified, true);
    });
  });
}