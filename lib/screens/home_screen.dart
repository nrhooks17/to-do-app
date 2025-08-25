import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/list_provider.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/screens/add_task_screen.dart';
import 'package:todo_app/widgets/task_item.dart';
import 'package:todo_app/widgets/list_dropdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listProvider = Provider.of<ListProvider>(context, listen: false);
      listProvider.ensureDefaultList().then((_) {
        if (listProvider.currentList != null) {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          taskProvider.setCurrentListId(listProvider.currentList!.id);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Text(languageProvider.translate('appTitle'));
              },
            ),
            actions: [
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.language),
                    onSelected: (value) {
                      languageProvider.setLanguage(value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            if (languageProvider.isEnglish) const Icon(Icons.check),
                            const SizedBox(width: 8),
                            Text(languageProvider.translate('english')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'zh',
                        child: Row(
                          children: [
                            if (languageProvider.isChinese) const Icon(Icons.check),
                            const SizedBox(width: 8),
                            Text(languageProvider.translate('chinese')),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete_completed') {
                    _showDeleteCompletedDialog(context);
                  } else if (value == 'delete_all') {
                    _showDeleteAllDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete_completed',
                    child: Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        return Text(languageProvider.translate('deleteCompletedTasks'));
                      },
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete_all',
                    child: Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        return Text(languageProvider.translate('deleteAllTasks'));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // List selector
              Container(
                padding: const EdgeInsets.all(16),
                child: const ListDropdown(),
              ),
              
              // Filter options
              _buildFilterOptions(context),
              
              // Task list
              Expanded(
                child: _buildTaskList(context),
              ),
            ],
          ),
          floatingActionButton: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: 30,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: "ai_fab",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskScreen(
                          onTaskAdded: (task) {
                            context.read<TaskProvider>().addTask(task);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.smart_toy),
                ),
              ),  
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: "add_task_fab",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskScreen(
                          onTaskAdded: (task) {
                            context.read<TaskProvider>().addTask(task);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ),  
            ]),
        );
      },
      
    );
  }

  Widget _buildFilterOptions(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return _buildFilterButton(
                context,
                languageProvider.translate('all'),
                TaskFilter.all,
                taskProvider.currentFilter,
                () => taskProvider.setFilter(TaskFilter.all),
              );
            },
          ),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return _buildFilterButton(
                context,
                languageProvider.translate('active'),
                TaskFilter.active,
                taskProvider.currentFilter,
                () => taskProvider.setFilter(TaskFilter.active),
              );
            },
          ),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return _buildFilterButton(
                context,
                languageProvider.translate('completed'),
                TaskFilter.completed,
                taskProvider.currentFilter,
                () => taskProvider.setFilter(TaskFilter.completed),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String text,
    TaskFilter filter,
    TaskFilter currentFilter,
    VoidCallback onPressed,
  ) {
    final isSelected = filter == currentFilter;
    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    final tasks = taskProvider.tasks;
    
    if (taskProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(taskProvider.currentFilter),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (taskProvider.currentFilter != TaskFilter.all)
              ElevatedButton(
                onPressed: () => taskProvider.setFilter(TaskFilter.all),
                child: Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return Text(languageProvider.translate('showAllTasks'));
                  },
                ),
              ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => taskProvider.refreshTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskItem(
            task: task,
            onCheckboxChanged: (isChecked) {
              taskProvider.toggleTaskCompletion(task.id);
            },
            onDelete: () {
              taskProvider.deleteTask(task.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return Text(languageProvider.translate('taskDeleted'));
                    },
                  ),
                  action: SnackBarAction(
                    label: context.read<LanguageProvider>().translate('undo'),
                    onPressed: () {
                      taskProvider.addTask(task);
                    },
                  ),
                ),
              );
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(
                    task: task,
                    onTaskAdded: (updatedTask) {
                      taskProvider.updateTask(updatedTask);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getEmptyStateMessage(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'No tasks yet\nTap the + button to add a new task';
      case TaskFilter.active:
        return 'No active tasks\nEnjoy your free time!';
      case TaskFilter.completed:
        return 'No completed tasks yet\nTime to be productive!';
    }
  }

  void _showDeleteCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(languageProvider.translate('deleteCompletedTasks'));
          },
        ),
        content: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(languageProvider.translate('confirmDeleteCompleted'));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Text(languageProvider.translate('cancel'));
              },
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteCompletedTasks();
              Navigator.pop(context);
            },
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Text(languageProvider.translate('delete'));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(languageProvider.translate('deleteAllTasks'));
          },
        ),
        content: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(languageProvider.translate('confirmDeleteAll'));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Text(languageProvider.translate('cancel'));
              },
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteAllTasks();
              Navigator.pop(context);
            },
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Text(languageProvider.translate('delete'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
