import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskDetailsSheet extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskDetailsSheet({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<TaskDetailsSheet> createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends ConsumerState<TaskDetailsSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assignedToController;
  late String _selectedCategory;
  late String _selectedPriority;
  late String _selectedStatus;
  DateTime? _selectedDueDate;
  bool _isEditing = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'general',
    'scheduling',
    'finance',
    'technical',
    'safety',
  ];

  final List<String> _priorities = ['low', 'medium', 'high'];
  final List<String> _statuses = ['pending', 'in_progress', 'completed'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _assignedToController = TextEditingController(text: widget.task.assignedTo ?? '');
    _selectedCategory = widget.task.category ?? 'general';
    _selectedPriority = widget.task.priority ?? 'medium';
    _selectedStatus = widget.task.status ?? 'pending';
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'finance':
        return Colors.green;
      case 'technical':
        return Colors.blue;
      case 'safety':
        return Colors.red;
      case 'scheduling':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    final normalizedStatus = status.toLowerCase().replaceAll(' ', '_');
    switch (normalizedStatus) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'finance':
        return Icons.attach_money;
      case 'technical':
        return Icons.code;
      case 'safety':
        return Icons.warning;
      case 'scheduling':
        return Icons.calendar_today;
      default:
        return Icons.task;
    }
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(taskProvider.notifier).updateTask(
            taskId: widget.task.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            priority: _selectedPriority,
            status: _selectedStatus,
            assignedTo: _assignedToController.text.trim().isEmpty 
                ? null 
                : _assignedToController.text.trim(),
            dueDate: _selectedDueDate,
          );

      if (!mounted) return;
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully!'),
          backgroundColor: Colors.green,
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

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(taskProvider.notifier).deleteTask(widget.task.id);

      if (!mounted) return;
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully!'),
          backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _isLoading ? null : () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  _isEditing ? 'Edit Task' : 'Task Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _isLoading ? null : () => setState(() => _isEditing = true),
                  tooltip: 'Edit',
                )
              else
                TextButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _isEditing = false;
                      // Reset to original values
                      _titleController.text = widget.task.title;
                      _descriptionController.text = widget.task.description ?? '';
                      _assignedToController.text = widget.task.assignedTo ?? '';
                      _selectedCategory = widget.task.category ?? 'general';
                      _selectedPriority = widget.task.priority ?? 'medium';
                      _selectedStatus = widget.task.status ?? 'pending';
                      _selectedDueDate = widget.task.dueDate;
                    });
                  },
                  child: const Text('Cancel'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Title',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Task title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: _isEditing ? Colors.white : Colors.grey[100],
                      prefixIcon: const Icon(Icons.title),
                    ),
                    enabled: _isEditing && !_isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Task description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: _isEditing ? Colors.white : Colors.grey[100],
                    ),
                    enabled: _isEditing && !_isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Status
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_selectedStatus).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(_selectedStatus).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _getStatusColor(_selectedStatus),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedStatus.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(_selectedStatus),
                          ),
                        ),
                        const Spacer(),
                        if (_isEditing && !_isLoading)
                          TextButton(
                            onPressed: () => _showStatusPicker(),
                            child: const Text('Change'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(_selectedCategory).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor(_selectedCategory).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(_selectedCategory),
                          color: _getCategoryColor(_selectedCategory),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedCategory.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(_selectedCategory),
                          ),
                        ),
                        const Spacer(),
                        if (_isEditing && !_isLoading)
                          TextButton(
                            onPressed: () => _showCategoryPicker(),
                            child: const Text('Change'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority
                  Text(
                    'Priority',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(_selectedPriority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getPriorityColor(_selectedPriority).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: _getPriorityColor(_selectedPriority),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedPriority.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(_selectedPriority),
                          ),
                        ),
                        const Spacer(),
                        if (_isEditing && !_isLoading)
                          TextButton(
                            onPressed: () => _showPriorityPicker(),
                            child: const Text('Change'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Due Date
                  Text(
                    'Due Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _isEditing && !_isLoading ? _selectDueDate : null,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: _isEditing ? Colors.white : Colors.grey[100],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.purple),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDueDate != null
                                  ? _formatDate(_selectedDueDate!)
                                  : 'No due date',
                              style: TextStyle(
                                color: _selectedDueDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          if (_isEditing && !_isLoading && _selectedDueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () => setState(() => _selectedDueDate = null),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Assigned To
                  Text(
                    'Assigned To',
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
                      fillColor: _isEditing ? Colors.white : Colors.grey[100],
                      prefixIcon: const Icon(Icons.person),
                    ),
                    enabled: _isEditing && !_isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Metadata
                  if (widget.task.createdAt != null || widget.task.updatedAt != null) ...[
                    Text(
                      'Metadata',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.task.createdAt != null)
                            Row(
                              children: [
                                const Icon(Icons.add_circle_outline, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Created: ${_formatDate(widget.task.createdAt!)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          if (widget.task.updatedAt != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.update, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Updated: ${_formatDate(widget.task.updatedAt!)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
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
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._statuses.map((status) => ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: _getStatusColor(status),
                  ),
                  title: Text(status.replaceAll('_', ' ').toUpperCase()),
                  trailing: _selectedStatus == status
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() => _selectedStatus = status);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._categories.map((category) => ListTile(
                  leading: Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                  ),
                  title: Text(category.toUpperCase()),
                  trailing: _selectedCategory == category
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Priority',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._priorities.map((priority) => ListTile(
                  leading: Icon(
                    Icons.flag,
                    color: _getPriorityColor(priority),
                  ),
                  title: Text(priority.toUpperCase()),
                  trailing: _selectedPriority == priority
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() => _selectedPriority = priority);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
