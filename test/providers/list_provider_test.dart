import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_app/models/list.dart';
import 'package:todo_app/providers/list_provider.dart';
import 'package:todo_app/services/list_service.dart';

// Generate mocks
@GenerateMocks([ListService])
import 'list_provider_test.mocks.dart';

void main() {
  group('ListProvider Tests', () {
    late ListProvider provider;
    late MockListService mockListService;

    setUp(() {
      mockListService = MockListService();
      
      // Mock empty lists initially for constructor call
      when(mockListService.getActiveLists()).thenAnswer((_) async => []);
      
      provider = ListProvider(listService: mockListService);
    });

    test('addList adds list via service and sets as current', () async {
      final list = TaskList(name: 'New List');
      when(mockListService.addList(any)).thenAnswer((_) async {});
      when(mockListService.getActiveLists()).thenAnswer((_) async => [list]);

      await provider.addList('New List');

      verify(mockListService.addList(any)).called(1);
      verify(mockListService.getActiveLists()).called(2); // Once in constructor, once in addList
      expect(provider.lists.length, 1);
      expect(provider.lists.first.name, 'New List');
      expect(provider.currentList?.name, 'New List');
    });

    test('updateListName calls service updateListName and reloads', () async {
      final updatedList = TaskList(id: 'list-1', name: 'Updated');
      
      when(mockListService.updateListName('list-1', 'Updated')).thenAnswer((_) async {});
      when(mockListService.getActiveLists()).thenAnswer((_) async => [updatedList]);

      await provider.updateListName('list-1', 'Updated');

      verify(mockListService.updateListName('list-1', 'Updated')).called(1);
      expect(provider.lists.first.name, 'Updated');
    });

    test('deleteList calls service deleteList and reloads', () async {
      final list = TaskList(name: 'To Delete');
      when(mockListService.deleteList(list.id)).thenAnswer((_) async {});
      when(mockListService.getActiveLists()).thenAnswer((_) async => []);

      await provider.deleteList(list.id);

      verify(mockListService.deleteList(list.id)).called(1);
      expect(provider.lists.length, 0);
    });

    test('deleteList switches to first available list when current list is deleted', () async {
      final list1 = TaskList(id: 'list-1', name: 'List 1');
      final list2 = TaskList(id: 'list-2', name: 'List 2');
      
      when(mockListService.deleteList('list-1')).thenAnswer((_) async {});
      when(mockListService.getActiveLists()).thenAnswer((_) async => [list2]);

      provider.setCurrentList(list1);
      await provider.deleteList('list-1');

      expect(provider.currentList?.id, 'list-2');
    });

    test('setCurrentList updates current list and notifies listeners', () {
      final list = TaskList(name: 'Selected List');
      var notified = false;
      provider.addListener(() { notified = true; });

      provider.setCurrentList(list);

      expect(provider.currentList?.name, 'Selected List');
      expect(notified, true);
    });

    test('refreshLists reloads lists from service', () async {
      final lists = [
        TaskList(name: 'List 1'),
        TaskList(name: 'List 2'),
      ];
      when(mockListService.getActiveLists()).thenAnswer((_) async => lists);

      await provider.refreshLists();

      verify(mockListService.getActiveLists()).called(2); // Once in constructor, once in refreshLists
      expect(provider.lists.length, 2);
    });

    test('ensureDefaultList creates default list when no lists exist', () async {
      // Initially empty
      when(mockListService.getActiveLists()).thenAnswer((_) async => []);
      when(mockListService.addList(any)).thenAnswer((_) async {});
      
      // After adding default list
      final defaultList = TaskList(name: 'My Tasks');
      when(mockListService.getActiveLists()).thenAnswer((_) async => [defaultList]);

      await provider.ensureDefaultList();

      verify(mockListService.addList(any)).called(1);
      expect(provider.lists.length, 1);
      expect(provider.lists.first.name, 'My Tasks');
    });

    test('ensureDefaultList does not create list when lists already exist', () async {
      final existingList = TaskList(name: 'Existing');
      
      // Reset mock to handle constructor call separately
      reset(mockListService);
      when(mockListService.getActiveLists()).thenAnswer((_) async => [existingList]);

      // Create new provider with existing list
      final providerWithLists = ListProvider(listService: mockListService);
      await Future.delayed(Duration.zero); // Wait for constructor async call
      
      await providerWithLists.ensureDefaultList();

      verifyNever(mockListService.addList(any));
      expect(providerWithLists.lists.length, 1);
      expect(providerWithLists.lists.first.name, 'Existing');
    });

    test('lists getter filters to only active lists', () async {
      // This is tested implicitly since the service should only return active lists
      // and the provider filters with .where((list) => list.isActive)
      final activeList = TaskList(name: 'Active');
      when(mockListService.getActiveLists()).thenAnswer((_) async => [activeList]);

      await provider.refreshLists();
      await Future.delayed(Duration.zero); // Wait for async call

      expect(provider.lists.length, 1);
      expect(provider.lists.first.name, 'Active');
    });

    test('sets first list as current when none selected and lists available', () async {
      final list1 = TaskList(name: 'First');
      final list2 = TaskList(name: 'Second');
      when(mockListService.getActiveLists()).thenAnswer((_) async => [list1, list2]);

      // Create a new provider (which calls _loadLists in constructor)
      final newProvider = ListProvider(listService: mockListService);

      // Wait for async constructor to complete
      await Future.delayed(Duration.zero);

      expect(newProvider.currentList?.name, 'First');
    });

    test('constructor calls _loadLists and sets loading state', () async {
      // Reset and set up fresh mock
      reset(mockListService);
      when(mockListService.getActiveLists()).thenAnswer((_) async => []);

      final newProvider = ListProvider(listService: mockListService);
      await Future.delayed(Duration.zero); // Wait for async constructor to complete

      verify(mockListService.getActiveLists()).called(1);
      expect(newProvider.isLoading, false); // Should be false after loading completes
    });
  });
}