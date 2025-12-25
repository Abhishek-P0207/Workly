import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task_model.dart';
import '../../data/sources/task_api.dart';

final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskModel>>>(
  (ref) => TaskNotifier(),
);

final filterProvider = StateNotifierProvider<FilterNotifier, TaskFilters>(
  (ref) => FilterNotifier(),
);

class TaskFilters {
  final String? category;
  final String? priority;

  const TaskFilters({
    this.category,
    this.priority,
  });

  TaskFilters copyWith({
    String? category,
    String? priority,
    bool clearCategory = false,
    bool clearPriority = false,
  }) {
    return TaskFilters(
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
    );
  }

  bool get hasFilters => category != null || priority != null;
}

class FilterNotifier extends StateNotifier<TaskFilters> {
  FilterNotifier() : super(const TaskFilters());

  void setCategory(String? category) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
    );
  }

  void setPriority(String? priority) {
    state = state.copyWith(
      priority: priority,
      clearPriority: priority == null,
    );
  }

  void clearFilters() {
    state = const TaskFilters();
  }
}

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskApi _api = TaskApi();

  TaskNotifier() : super(const AsyncValue.loading()) {
    fetchTasks();
  }

  Future<void> fetchTasks({String? category, String? priority}) async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _api.getTasks(
        category: category,
        priority: priority,
      );
      state = AsyncValue.data(tasks);
    } catch (e, st) {
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

  List<TaskModel> getFilteredTasks(List<TaskModel> tasks, TaskFilters filters) {
    return tasks.where((task) {
      if (filters.category != null &&
          task.category?.toLowerCase() != filters.category?.toLowerCase()) {
        return false;
      }
      if (filters.priority != null &&
          task.priority?.toLowerCase() != filters.priority?.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  Map<String, int> getTaskCounts(List<TaskModel> tasks) {
    int pending = 0;
    int inProgress = 0;
    int completed = 0;

    for (var task in tasks) {
      final status = task.status?.toLowerCase() ?? 'pending';
      if (status == 'completed') {
        completed++;
      } else if (status == 'in_progress' || status == 'in progress') {
        inProgress++;
      } else {
        pending++;
      }
    }

    return {
      'pending': pending,
      'in_progress': inProgress,
      'completed': completed,
    };
  }
}