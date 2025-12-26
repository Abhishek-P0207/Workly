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

// Provider for active tasks (pending and in_progress only)
final activeTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final allTasks = ref.watch(taskProvider);
  return allTasks.whenData((tasks) {
    return tasks.where((task) {
      final status = task.status?.toLowerCase() ?? 'pending';
      return status != 'completed';
    }).toList();
  });
});

class TaskFilters {
  final String? category;
  final String? priority;
  final String? status;

  const TaskFilters({
    this.category,
    this.priority,
    this.status,
  });

  TaskFilters copyWith({
    String? category,
    String? priority,
    String? status,
    bool clearCategory = false,
    bool clearPriority = false,
    bool clearStatus = false,
  }) {
    return TaskFilters(
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  bool get hasFilters => category != null || priority != null || status != null;
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

  void setStatus(String? status) {
    state = state.copyWith(
      status: status,
      clearStatus: status == null,
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
      // Store all tasks including completed ones
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTask(String input) async {
    try {
      // This is now handled by the bottom sheet with preview flow
      // Keeping for backward compatibility
      final preview = await _api.previewTask(description: input);
      final newTask = await _api.createTask(
        title: preview.title,
        description: preview.description,
        category: preview.category,
        priority: preview.priority,
        assignedTo: preview.assignedTo,
        dueDate: preview.dueDate,
        extractedEntities: preview.extractedEntities,
        suggestedActions: preview.suggestedActions,
      );
      state = state.whenData(
        (tasks) => [newTask, ...tasks],
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> createTaskFromPreview({
    required String title,
    required String description,
    required String category,
    required String priority,
    String? assignedTo,
    DateTime? dueDate,
    Map<String, dynamic>? extractedEntities,
    List<String>? suggestedActions,
  }) async {
    try {
      final newTask = await _api.createTask(
        title: title,
        description: description,
        category: category,
        priority: priority,
        assignedTo: assignedTo,
        dueDate: dueDate,
        extractedEntities: extractedEntities,
        suggestedActions: suggestedActions,
      );
      state = state.whenData(
        (tasks) => [newTask, ...tasks],
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      final updatedTask = await _api.updateTask(
        taskId: taskId,
        status: status,
      );
      
      state = state.whenData((tasks) {
        // Update the task in the list with new status
        return tasks.map((task) {
          if (task.id == taskId) {
            return updatedTask;
          }
          return task;
        }).toList();
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      final updatedTask = await _api.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        category: category,
        priority: priority,
        status: status,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );
      
      state = state.whenData((tasks) {
        return tasks.map((task) {
          if (task.id == taskId) {
            return updatedTask;
          }
          return task;
        }).toList();
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _api.deleteTask(taskId);
      
      state = state.whenData((tasks) {
        return tasks.where((task) => task.id != taskId).toList();
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
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
      if (filters.status != null) {
        final taskStatus = (task.status?.toLowerCase() ?? 'pending').replaceAll(' ', '_');
        final filterStatus = filters.status?.toLowerCase().replaceAll(' ', '_');
        if (taskStatus != filterStatus) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Map<String, int> getTaskCounts(List<TaskModel> tasks) {
    int pending = 0;
    int inProgress = 0;
    int completed = 0;

    for (var task in tasks) {
      final status = task.status?.toLowerCase()?.replaceAll(' ', '_') ?? 'pending';
      if (status == 'completed') {
        completed++;
      } else if (status == 'in_progress') {
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