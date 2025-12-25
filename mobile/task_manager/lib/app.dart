import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/presentation/screens/task_dashboard_screen.dart';

class SmartTaskManagerApp extends StatelessWidget {
  const SmartTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const TaskDashboardScreen(),
    );
  }
}
