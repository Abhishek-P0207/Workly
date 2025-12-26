import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_details_sheet.dart';

class TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  DateTime? _lastTapTime;
  bool _isUpdating = false;

  void _handleTap() async {
    final now = DateTime.now();
    
    // Check if this is a double tap (within 500ms)
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!) < const Duration(milliseconds: 500)) {
      // Double tap detected - mark as completed
      if (_isUpdating) return;
      
      setState(() => _isUpdating = true);
      
      try {
        await ref.read(taskProvider.notifier).updateTaskStatus(
          widget.task.id,
          'completed',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${widget.task.title}" marked as completed!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
      
      _lastTapTime = null; // Reset after double tap
    } else {
      // Single tap - open details sheet after delay to check for double tap
      _lastTapTime = now;
      
      // Wait to see if there's a second tap
      await Future.delayed(const Duration(milliseconds: 500));
      
      // If still the same tap time, it was a single tap
      if (_lastTapTime == now && mounted) {
        _lastTapTime = null;
        _openDetailsSheet();
      }
    }
  }

  void _openDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TaskDetailsSheet(task: widget.task),
    );
  }

  Color _getStatusColor() {
    switch (widget.task.status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'in progress':
        return Colors.blue;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Color _getPriorityColor() {
    switch (widget.task.priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String? status) {
    if (status == null) return 'Pending';
    return status.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Opacity(
        opacity: _isUpdating ? 0.5 : 1.0,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _getStatusColor().withValues(alpha: 0.3)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor()),
                          ),
                          child: Text(
                            _formatStatus(widget.task.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.task.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.task.category?.isNotEmpty ?? false)
                          _buildChip(
                            label: widget.task.category!,
                            icon: Icons.category,
                            color: Colors.blue,
                          ),
                        if (widget.task.priority?.isNotEmpty ?? false)
                          _buildChip(
                            label: widget.task.priority!.toUpperCase(),
                            icon: Icons.flag,
                            color: _getPriorityColor(),
                          ),
                        if (widget.task.dueDate != null)
                          _buildChip(
                            label: DateFormat('MMM dd').format(widget.task.dueDate!),
                            icon: Icons.calendar_today,
                            color: Colors.purple,
                          ),
                        if (widget.task.assignedTo?.isNotEmpty ?? false)
                          _buildChip(
                            label: widget.task.assignedTo!,
                            icon: Icons.person,
                            color: Colors.teal,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isUpdating)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
