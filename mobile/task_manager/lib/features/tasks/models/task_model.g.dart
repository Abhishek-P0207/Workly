// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  priority: json['priority'] as String,
  status: json['status'],
  assignedTo: json['assigned_to'] as String?,
  dueDate:
      json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
  extractedEntities: const JsonStringToMapConverter().fromJson(
    json['extracted_entities'],
  ),
  suggestedActions: const JsonStringToStringListConverter().fromJson(
    json['suggested_actions'],
  ),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'priority': instance.priority,
  'status': instance.status,
  'assigned_to': instance.assignedTo,
  'due_date': instance.dueDate?.toIso8601String(),
  'extracted_entities': const JsonStringToMapConverter().toJson(
    instance.extractedEntities,
  ),
  'suggested_actions': const JsonStringToStringListConverter().toJson(
    instance.suggestedActions,
  ),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
