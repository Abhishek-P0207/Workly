import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

class JsonStringToMapConverter
    implements JsonConverter<Map<String, dynamic>, dynamic> {
  const JsonStringToMapConverter();

  @override
  Map<String, dynamic> fromJson(dynamic json) {
    if (json == null) return {};

    // Backend sends stringified JSON
    if (json is String) {
      return jsonDecode(json) as Map<String, dynamic>;
    }

    // Backend sends proper JSON (future-proof)
    if (json is Map<String, dynamic>) {
      return json;
    }

    throw FormatException('Invalid JSON format for extracted_entities');
  }

  @override
  dynamic toJson(Map<String, dynamic> object) {
    return jsonEncode(object);
  }
}
