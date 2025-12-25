import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_provider.dart';
import '../../models/task_model.dart';

class TaskDashboardScreen extends ConsumerWidget {
  const TaskDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
      ),
      body: taskState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (tasks) {
          print('Tasks received: ${tasks.length}'); // Debug print
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet'),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              print('Rendering task: ${task.title}'); // Debug print
              return _TaskTile(task: task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // create task sheet next
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    print('Building TaskTile for: ${task.title}'); // Debug print
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description?.isNotEmpty ?? false)
              Text(task.description!),
            const SizedBox(height: 4),
            if (task.category?.isNotEmpty ?? false)
              Chip(
                label: Text(task.category!),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        trailing: Text(
          task.status ?? 'pending',
          style: TextStyle(
            color: task.status == 'completed'
                ? Colors.green
                : Colors.orange,
          ),
        ),
      ),
    );
  }
}
