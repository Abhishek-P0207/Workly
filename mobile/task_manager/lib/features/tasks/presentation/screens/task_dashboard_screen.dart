import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/filter_section.dart';
import '../widgets/task_card.dart';
import '../widgets/create_task_bottom_sheet.dart';

class TaskDashboardScreen extends ConsumerWidget {
  const TaskDashboardScreen({super.key});

  void _showCreateTaskSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateTaskBottomSheet(
        onSubmit: (input) async {
          await ref.read(taskProvider.notifier).createTask(input);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final filters = ref.watch(filterProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Tasks',
            onPressed: () {
              ref.read(taskProvider.notifier).fetchTasks(
                    category: filters.category,
                    priority: filters.priority,
                  );
            },
          ),
        ],
      ),
      body: taskState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(taskProvider.notifier).fetchTasks();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tasks) {
          final taskNotifier = ref.read(taskProvider.notifier);
          final filteredTasks = taskNotifier.getFilteredTasks(tasks, filters);
          final counts = taskNotifier.getTaskCounts(filteredTasks);

          return RefreshIndicator(
            onRefresh: () => ref.read(taskProvider.notifier).fetchTasks(
                  category: filters.category,
                  priority: filters.priority,
                ),
            child: CustomScrollView(
              slivers: [
                // Summary Cards Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'Pending',
                                count: counts['pending'] ?? 0,
                                icon: Icons.pending_actions,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SummaryCard(
                                title: 'In Progress',
                                count: counts['in_progress'] ?? 0,
                                icon: Icons.hourglass_empty,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SummaryCard(
                          title: 'Completed',
                          count: counts['completed'] ?? 0,
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FilterSection(
                      selectedCategory: filters.category,
                      selectedPriority: filters.priority,
                      onCategoryChanged: (category) {
                        ref.read(filterProvider.notifier).setCategory(category);
                      },
                      onPriorityChanged: (priority) {
                        ref.read(filterProvider.notifier).setPriority(priority);
                      },
                      onClearFilters: () {
                        ref.read(filterProvider.notifier).clearFilters();
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),

                // Tasks List Section
                if (filteredTasks.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            filters.hasFilters
                                ? Icons.filter_list_off
                                : Icons.task_alt,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            filters.hasFilters
                                ? 'No tasks match your filters'
                                : 'No tasks yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            filters.hasFilters
                                ? 'Try adjusting your filters'
                                : 'Tap + to create your first task',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return TaskCard(task: filteredTasks[index]);
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}
