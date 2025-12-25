import 'package:json_annotation/json_annotation.dart';
import '../../../core/converters/json_string_converter.dart';
import '../../../core/converters/json_string_list_converters.dart';


part 'task_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TaskModel {
  final String id;
  final String title;
  final String? description;

  final String? category;

  final String? priority;
  final String? status;

  @JsonKey(name: 'assigned_to')
  final String? assignedTo;

  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @JsonKey(name: 'extracted_entities')
  @JsonStringToMapConverter()
  final Map<String, dynamic> extractedEntities;

  @JsonKey(name: 'suggested_actions')
  @JsonStringToStringListConverter()
  final List<String> suggestedActions;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.priority,
    this.status,
    this.assignedTo,
    this.dueDate,
    required this.extractedEntities,
    required this.suggestedActions,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}
