import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

class JsonStringToStringListConverter
    implements JsonConverter<List<String>, dynamic> {
  const JsonStringToStringListConverter();

  @override
  List<String> fromJson(dynamic json) {
    if (json == null) return [];

    // Backend sends stringified JSON array
    if (json is String) {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    }

    // Backend sends proper JSON array
    if (json is List) {
      return json.map((e) => e.toString()).toList();
    }

    throw FormatException('Invalid format for suggested_actions');
  }

  @override
  dynamic toJson(List<String> object) {
    return jsonEncode(object);
  }
}
