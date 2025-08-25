import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/list_provider.dart';
import 'package:todo_app/providers/language_provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/list.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/theme/app_theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskListAdapter());
  
  // Clear and open boxes (temporary fix for schema migration)
  try {
    await Hive.deleteBoxFromDisk('tasks');
    await Hive.deleteBoxFromDisk('lists');
  } catch (e) {
    // Ignore if boxes don't exist
  }
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<TaskList>('lists');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => ListProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
