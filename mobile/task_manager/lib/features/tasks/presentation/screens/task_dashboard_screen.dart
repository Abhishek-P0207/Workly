import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../providers/task_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/filter_section.dart';
import '../widgets/task_card.dart';
import '../widgets/create_task_bottom_sheet.dart';

class TaskDashboardScreen extends ConsumerWidget {
  const TaskDashboardScreen({super.key});

  void _showCreateTaskSheet(BuildContext context, WidgetRef ref) {
    final rootContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateTaskBottomSheet(
        rootContext: rootContext,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksState = ref.watch(taskProvider);
    final activeTasksState = ref.watch(activeTasksProvider);
    final filters = ref.watch(filterProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Use all tasks if status filter is active (to show completed tasks)
    // Otherwise use active tasks only
    final displayTasksState = filters.status != null 
        ? allTasksState 
        : activeTasksState;

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
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: const OfflineBanner(),
        ),
      ),
      body: displayTasksState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) {
          final isOnline = ref.watch(isOnlineProvider);
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOnline ? Icons.error_outline : Icons.cloud_off,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  isOnline ? 'Error loading tasks' : 'No Internet Connection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    isOnline 
                        ? error.toString()
                        : 'Please check your internet connection and try again',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
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
          );
        },
        data: (displayTasks) {
          final taskNotifier = ref.read(taskProvider.notifier);
          final filteredTasks = taskNotifier.getFilteredTasks(displayTasks, filters);
          
          // Get counts from all tasks (including completed)
          final allTasks = allTasksState.maybeWhen(
            data: (tasks) => tasks,
            orElse: () => displayTasks,
          );
          final counts = taskNotifier.getTaskCounts(allTasks);

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(taskProvider.notifier).fetchTasks(
                category: filters.category,
                priority: filters.priority,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                                isSelected: filters.status == 'pending',
                                onTap: () {
                                  final filterNotifier = ref.read(filterProvider.notifier);
                                  if (filters.status == 'pending') {
                                    filterNotifier.setStatus(null);
                                  } else {
                                    filterNotifier.setStatus('pending');
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SummaryCard(
                                title: 'In Progress',
                                count: counts['in_progress'] ?? 0,
                                icon: Icons.hourglass_empty,
                                color: Colors.blue,
                                isSelected: filters.status == 'in_progress',
                                onTap: () {
                                  final filterNotifier = ref.read(filterProvider.notifier);
                                  if (filters.status == 'in_progress') {
                                    filterNotifier.setStatus(null);
                                  } else {
                                    filterNotifier.setStatus('in_progress');
                                  }
                                },
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
                          isSelected: filters.status == 'completed',
                          onTap: () {
                            final filterNotifier = ref.read(filterProvider.notifier);
                            if (filters.status == 'completed') {
                              filterNotifier.setStatus(null);
                            } else {
                              filterNotifier.setStatus('completed');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status filter indicator
                        if (filters.status != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_alt, 
                                    color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Showing ${filters.status == "in_progress" ? "In Progress" : filters.status![0].toUpperCase() + filters.status!.substring(1)} tasks',
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(filterProvider.notifier).setStatus(null);
                                  },
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        FilterSection(
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
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),

                // Tasks List Section
                if (filteredTasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
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
