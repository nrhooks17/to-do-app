import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/list_provider.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TaskForm extends StatefulWidget {
  final Function(Task) onSave;
  final Task? task;
  final String title;

  const TaskForm({
    super.key,
    required this.onSave,
    this.task,
    required this.title,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }
  
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final listProvider = Provider.of<ListProvider>(context, listen: false);
      final currentList = listProvider.currentList;
      
      if (currentList == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Text(languageProvider.translate('pleaseSelectListFirst'));
              },
            ),
          ),
        );
        return;
      }
      
      final task = widget.task != null
          ? widget.task!
          : Task(
              title: _titleController.text,
              description: _descriptionController.text,
              dueDate: _dueDate,
              listId: currentList.id,
            );
      
      if (widget.task != null) {
        task.updateTask(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
        );
      }
      
      widget.onSave(task);
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate('title'),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return languageProvider.translate('pleaseEnterTitle');
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: languageProvider.translate('description'),
                      prefixIcon: const Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return ListTile(
                    title: Text(languageProvider.translate('dueDate')),
                    subtitle: Text(
                      _dueDate != null
                        ? DateFormat('EEEE, MMM dd, yyyy').format(_dueDate!)
                        : languageProvider.translate('noDueDateSet'),
                ),
                leading: const Icon(Icons.calendar_today),
                trailing: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                      )
                    : null,
                    onTap: () => _selectDate(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "save_task_fab",
        onPressed: _saveForm,
        icon: const Icon(Icons.save),
        label: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(languageProvider.translate('save'));
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
