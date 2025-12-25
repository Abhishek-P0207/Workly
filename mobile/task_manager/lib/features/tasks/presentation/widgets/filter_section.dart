import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedPriority;
  final Function(String?) onCategoryChanged;
  final Function(String?) onPriorityChanged;
  final VoidCallback onClearFilters;

  const FilterSection({
    super.key,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedCategory != null || selectedPriority != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (hasFilters)
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isSmallScreen) ...[
          // Category filters on first line
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'General',
                  isSelected: selectedCategory == 'general',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'general' ? null : 'general',
                  ),
                  color: Colors.grey,
                ),
                _buildFilterChip(
                  label: 'Scheduling',
                  isSelected: selectedCategory == 'scheduling',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'scheduling' ? null : 'scheduling',
                  ),
                  color: Colors.blue,
                ),
                _buildFilterChip(
                  label: 'Finance',
                  isSelected: selectedCategory == 'finance',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'finance' ? null : 'finance',
                  ),
                  color: Colors.green,
                ),
                _buildFilterChip(
                  label: 'Technical',
                  isSelected: selectedCategory == 'technical',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'technical' ? null : 'technical',
                  ),
                  color: Colors.purple,
                ),
                _buildFilterChip(
                  label: 'Safety',
                  isSelected: selectedCategory == 'safety',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'safety' ? null : 'safety',
                  ),
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Priority filters on second line
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'High',
                  isSelected: selectedPriority == 'high',
                  onTap: () => onPriorityChanged(
                    selectedPriority == 'high' ? null : 'high',
                  ),
                  color: Colors.red,
                  icon: Icons.priority_high,
                ),
                _buildFilterChip(
                  label: 'Medium',
                  isSelected: selectedPriority == 'medium',
                  onTap: () => onPriorityChanged(
                    selectedPriority == 'medium' ? null : 'medium',
                  ),
                  color: Colors.orange,
                  icon: Icons.remove,
                ),
                _buildFilterChip(
                  label: 'Low',
                  isSelected: selectedPriority == 'low',
                  onTap: () => onPriorityChanged(
                    selectedPriority == 'low' ? null : 'low',
                  ),
                  color: Colors.grey,
                  icon: Icons.arrow_downward,
                ),
              ],
            ),
          ),
        ] else
          // Single line for larger screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'General',
                  isSelected: selectedCategory == 'general',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'general' ? null : 'general',
                  ),
                  color: Colors.grey,
                ),
                _buildFilterChip(
                  label: 'Scheduling',
                  isSelected: selectedCategory == 'scheduling',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'scheduling' ? null : 'scheduling',
                  ),
                  color: Colors.blue,
                ),
                _buildFilterChip(
                  label: 'Finance',
                  isSelected: selectedCategory == 'finance',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'finance' ? null : 'finance',
                  ),
                  color: Colors.green,
                ),
                _buildFilterChip(
                  label: 'Technical',
                  isSelected: selectedCategory == 'technical',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'technical' ? null : 'technical',
                  ),
                  color: Colors.purple,
                ),
                _buildFilterChip(
                  label: 'Safety',
                  isSelected: selectedCategory == 'safety',
                  onTap: () => onCategoryChanged(
                    selectedCategory == 'safety' ? null : 'safety',
                  ),
                  color: Colors.red,
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                _buildFilterChip(
                  label: 'High',
                  isSelected: selectedPriority == 'high',
                  onTap: () => onPriorityChanged(
                    selectedPriority == 'high' ? null : 'high',
                  ),
                  color: Colors.red,
                  icon: Icons.priority_high,
                ),
                _buildFilterChip(
                  label: 'Medium',
                  isSelected: selectedPriority == 'medium',
                  onTap: () => onPriorityChanged(
                    selectedPriority == 'medium' ? null : 'medium',
                  ),
                  color: Colors.orange,
                  icon: Icons.remove,
                ),
                _buildFilterChip(
                  label: 'Low',
                  isSelected: selectedPriority == 'low',
                  onTap: () => onPriorityChanged(
                    selectedPriority == 'low' ? null : 'low',
                  ),
                  color: Colors.grey,
                  icon: Icons.arrow_downward,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.white : color),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(color: color),
      ),
    );
  }
}
