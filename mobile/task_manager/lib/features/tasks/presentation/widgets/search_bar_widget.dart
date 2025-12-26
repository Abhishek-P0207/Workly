import 'package:flutter/material.dart';
import 'dart:async';

class SearchBarWidget extends StatefulWidget {
  final String? initialValue;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    this.initialValue,
    required this.onSearchChanged,
    this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  Timer? _debounce;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(query);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search tasks by title or description...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: _isFocused
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
                size: 24,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: _clearSearch,
                      tooltip: 'Clear search',
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

