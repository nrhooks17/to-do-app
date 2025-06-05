import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? dueDate;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  void toggleComplete() {
    isCompleted = !isCompleted;
    save();
  }

  void updateTask({
    String? title,
    String? description,
    DateTime? dueDate,
  }) {
    if (title != null) this.title = title;
    if (description != null) this.description = description;
    if (dueDate != null) this.dueDate = dueDate;
    save();
  }
}

// Note: After creating this file, run the following command in terminal:
// flutter pub run build_runner build
// This will generate the task.g.dart file with the HiveAdapter
