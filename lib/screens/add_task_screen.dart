import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/widgets/task_form.dart';

class AddTaskScreen extends StatelessWidget {
  final Function(Task) onTaskAdded;
  final Task? task;

  const AddTaskScreen({
    super.key,
    required this.onTaskAdded,
    this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return TaskForm(
          title: task == null 
            ? languageProvider.translate('addTask') 
            : languageProvider.translate('editTask'),
          task: task,
          onSave: onTaskAdded,
        );
      },
    );
  }
}
