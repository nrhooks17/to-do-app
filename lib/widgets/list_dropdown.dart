import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/list.dart';
import 'package:todo_app/providers/list_provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/language_provider.dart';

class ListDropdown extends StatelessWidget {
  const ListDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ListProvider, TaskProvider, LanguageProvider>(
      builder: (context, listProvider, taskProvider, languageProvider, child) {
        final lists = listProvider.lists;
        final currentList = listProvider.currentList;

        if (lists.isEmpty) {
          return Row(
            children: [
              Text(languageProvider.translate('noListsAvailable')),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddListDialog(context, listProvider, taskProvider, languageProvider),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: DropdownButton<TaskList>(
                value: currentList,
                hint: Text(languageProvider.translate('selectList')),
                isExpanded: true,
                items: lists.map((list) {
                  return DropdownMenuItem<TaskList>(
                    value: list,
                    child: Row(
                      children: [
                        Expanded(child: Text(list.name)),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 16),
                          onSelected: (action) => _handleMenuAction(context, action, list, listProvider, languageProvider),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 16),
                                  const SizedBox(width: 8),
                                  Text(languageProvider.translate('edit')),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 16),
                                  const SizedBox(width: 8),
                                  Text(languageProvider.translate('delete')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (selectedList) {
                  if (selectedList != null) {
                    listProvider.setCurrentList(selectedList);
                    taskProvider.setCurrentListId(selectedList.id);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddListDialog(context, listProvider, taskProvider, languageProvider),
              tooltip: languageProvider.translate('addNewList'),
            ),
          ],
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action, TaskList list, ListProvider listProvider, LanguageProvider languageProvider) {
    switch (action) {
      case 'edit':
        _showEditListDialog(context, list, listProvider, languageProvider);
        break;
      case 'delete':
        _showDeleteListDialog(context, list, listProvider, languageProvider);
        break;
    }
  }

  void _showAddListDialog(BuildContext context, ListProvider listProvider, TaskProvider taskProvider, LanguageProvider languageProvider) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.translate('addNewListTitle')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: languageProvider.translate('listName'),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => _addList(context, controller.text.trim(), listProvider, taskProvider),
            child: Text(languageProvider.translate('add')),
          ),
        ],
      ),
    );
  }

  void _addList(BuildContext context, String name, ListProvider listProvider, TaskProvider taskProvider) {
    if (name.isNotEmpty) {
      listProvider.addList(name).then((_) {
        if (listProvider.currentList != null) {
          taskProvider.setCurrentListId(listProvider.currentList!.id);
        }
      });
      Navigator.of(context).pop();
    }
  }

  void _showEditListDialog(BuildContext context, TaskList list, ListProvider listProvider, LanguageProvider languageProvider) {
    final controller = TextEditingController(text: list.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.translate('editListName')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: languageProvider.translate('listName'),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => _editList(context, controller.text.trim(), list, listProvider),
            child: Text(languageProvider.translate('save')),
          ),
        ],
      ),
    );
  }

  void _editList(BuildContext context, String name, TaskList list, ListProvider listProvider) {
    if (name.isNotEmpty && name != list.name) {
      listProvider.updateListName(list.id, name);
      Navigator.of(context).pop();
    }
  }

  void _showDeleteListDialog(BuildContext context, TaskList list, ListProvider listProvider, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.translate('deleteList')),
        content: Text(languageProvider.translate('confirmDeleteList', placeholders: {'name': list.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(languageProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              listProvider.deleteList(list.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(languageProvider.translate('delete')),
          ),
        ],
      ),
    );
  }
}