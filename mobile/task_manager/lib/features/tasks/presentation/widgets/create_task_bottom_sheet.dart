import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/task_api.dart';
import '../providers/task_provider.dart';
import 'task_preview_sheet.dart';

class CreateTaskBottomSheet extends ConsumerStatefulWidget {
  final BuildContext rootContext;

  const CreateTaskBottomSheet({
    super.key,
    required this.rootContext,
  });

  @override
  ConsumerState<CreateTaskBottomSheet> createState() =>
      _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends ConsumerState<CreateTaskBottomSheet> {
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = TaskApi();
      final preview = await api.previewTask(
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      // Override with user-provided values if any
      final updatedPreview = TaskPreview(
        title: preview.title,
        description: preview.description,
        category: preview.category,
        priority: preview.priority,
        assignedTo: _assignedToController.text.trim().isEmpty
            ? preview.assignedTo
            : _assignedToController.text.trim(),
        dueDate: _selectedDueDate ?? preview.dueDate,
        extractedEntities: preview.extractedEntities,
        suggestedActions: preview.suggestedActions,
      );

      // Store ref before navigation
      final taskNotifier = ref.read(taskProvider.notifier);
      
      // Close current sheet
      Navigator.pop(context);

      // Show preview sheet using root context
      await showModalBottomSheet(
        context: widget.rootContext,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => TaskPreviewSheet(
          preview: updatedPreview,
          onConfirm: ({
            required title,
            required description,
            required category,
            required priority,
            assignedTo,
            dueDate,
            extractedEntities,
            suggestedActions,
          }) async {
            await taskNotifier.createTaskFromPreview(
              title: title,
              description: description,
              category: category,
              priority: priority,
              assignedTo: assignedTo,
              dueDate: dueDate,
              extractedEntities: extractedEntities,
              suggestedActions: suggestedActions,
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.add_task, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Step 1 of 2 - Fill in the details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Description Field
                  Text(
                    'Description *',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    autofocus: true,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Describe your task...\n\nExample: "Buy groceries tomorrow at 5pm - high priority"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Due Date Field
                  Text(
                    'Due Date (Optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _isLoading ? null : _selectDueDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDueDate != null
                                  ? _formatDate(_selectedDueDate!)
                                  : 'Select due date',
                              style: TextStyle(
                                color: _selectedDueDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          if (_selectedDueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(() => _selectedDueDate = null),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Assigned To Field
                  Text(
                    'Assigned To (Optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _assignedToController,
                    decoration: InputDecoration(
                      hintText: 'Enter person name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: const Icon(Icons.person),
                    ),
                    enabled: !_isLoading,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Next Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Next - Review Classification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
