import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'list.g.dart';

@HiveType(typeId: 1)
class TaskList extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  bool isActive;

  TaskList({
    String? id,
    required this.name,
    DateTime? createdAt,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  void deleteList() {
    isActive = false;
    save();
  }

  void restore() {
    isActive = true;
    save();
  }

  void changeName({String? name}) {
    if (name != null) this.name = name;
    save();
  }
}
