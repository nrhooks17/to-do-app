import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/screens/add_task_screen.dart';
import 'package:todo_app/theme/app_theme.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(languageProvider.translate('taskDetails')),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskScreen(
                    task: task,
                    onTaskAdded: (updatedTask) {
                      // Get the provider from the closest Provider ancestor
                      final provider = Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      );
                      provider.updateTask(updatedTask);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, languageProvider);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task status and created date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.isCompleted 
                          ? languageProvider.translate('completed') 
                          : languageProvider.translate('active'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                const Spacer(),
                Text(
                  'Created: ${DateFormat('MMM dd, yyyy').format(task.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Task title
            Text(
              languageProvider.translate('title'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Due date, if any
            if (task.dueDate != null) ...[
              Text(
                languageProvider.translate('dueDate'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(task.dueDate!),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getDueDateColor(task.dueDate!),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            
            // Description, if any
            if (task.description.isNotEmpty) ...[
              Text(
                languageProvider.translate('description'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            
            const Spacer(),
            
            // Toggle completion button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final provider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );
                  provider.toggleTaskCompletion(task.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.isCompleted
                      ? Colors.grey
                      : AppTheme.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  task.isCompleted
                      ? languageProvider.translate('markAsIncomplete')
                      : languageProvider.translate('markAsComplete'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (dueDay.isBefore(today)) {
      return AppTheme.errorColor;
    } else if (dueDay.isAtSameMomentAs(today)) {
      return AppTheme.accentColor;
    } else {
      return Colors.grey;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.translate('deleteTask')),
        content: Text(languageProvider.translate('confirmDeleteTask', placeholders: {'title': task.title})),
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
              final provider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              provider.deleteTask(task.id);
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context); // Go back to the list screen
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
