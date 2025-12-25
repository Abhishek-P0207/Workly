import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task_model.dart';
import '../../data/sources/task_api.dart';

final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskModel>>>(
  (ref) => TaskNotifier(),
);

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskApi _api = TaskApi();

  TaskNotifier() : super(const AsyncValue.loading()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      print('Fetching tasks...'); // Debug print
      final tasks = await _api.getTasks();
      print('Tasks fetched successfully: ${tasks.length}'); // Debug print
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      print('Error fetching tasks: $e'); // Debug print
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTask(String input) async {
    try {
      final newTask = await _api.createTask(rawInput: input);

      state = state.whenData(
        (tasks) => [newTask, ...tasks],
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}