import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
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
    return TaskForm(
      title: task == null ? 'Add Task' : 'Edit Task',
      task: task,
      onSave: onTaskAdded,
    );
  }
}
