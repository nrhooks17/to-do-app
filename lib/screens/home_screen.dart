import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/screens/add_task_screen.dart';
import 'package:todo_app/widgets/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Todo App'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete_completed') {
                    _showDeleteCompletedDialog(context);
                  } else if (value == 'delete_all') {
                    _showDeleteAllDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete_completed',
                    child: Text('Delete Completed Tasks'),
                  ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Text('Delete All Tasks'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
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
          _buildFilterButton(
            context,
            'All',
            TaskFilter.all,
            taskProvider.currentFilter,
            () => taskProvider.setFilter(TaskFilter.all),
          ),
          _buildFilterButton(
            context,
            'Active',
            TaskFilter.active,
            taskProvider.currentFilter,
            () => taskProvider.setFilter(TaskFilter.active),
          ),
          _buildFilterButton(
            context,
            'Completed',
            TaskFilter.completed,
            taskProvider.currentFilter,
            () => taskProvider.setFilter(TaskFilter.completed),
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
                child: const Text('Show All Tasks'),
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
                  content: const Text('Task deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
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
        title: const Text('Delete Completed Tasks'),
        content: const Text('Are you sure you want to delete all completed tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteCompletedTasks();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Tasks'),
        content: const Text('Are you sure you want to delete all tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteAllTasks();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
