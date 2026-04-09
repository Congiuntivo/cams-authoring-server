import 'package:is_valid/is_valid.dart';

void ensureNoUnknownFields(
  Map<String, dynamic> json,
  Set<String> allowed,
  String context,
) {
  final unknown = json.keys.where((key) => !allowed.contains(key)).toList()
    ..sort();

  if (unknown.isNotEmpty) {
    throw FormatException(
      'Unsupported field(s) in $context: ${unknown.join(', ')}.',
    );
  }
}

String requireNonBlankString(
  Map<String, dynamic> json,
  String key, {
  required String context,
}) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException(
      'Invalid $key in $context. Use a non-empty string.',
    );
  }

  return value.trim();
}

String requireValidUrlString(
  Map<String, dynamic> json,
  String key, {
  required String context,
}) {
  final value = requireNonBlankString(
    json,
    key,
    context: context,
  );

  if (!IsValid.validateURL(url: value)) {
    final fieldName = key.toLowerCase() == 'url' ? 'URL' : key;
    throw FormatException(
      'Invalid $fieldName in $context. Use a valid URL.',
    );
  }

  return value;
}

String? parseOptionalString(
  Object? raw,
  String key, {
  required String context,
}) {
  if (raw == null) return null;
  if (raw is String) return raw.trim();

  throw FormatException(
    'Invalid $key in $context. Use a string.',
  );
}

int? parseOptionalInt(
  Object? raw,
  String key, {
  required String context,
}) {
  if (raw == null) return null;
  if (raw is int) return raw;

  throw FormatException(
    'Invalid $key in $context. Use an integer.',
  );
}

double? parseOptionalDouble(
  Object? raw,
  String key, {
  required String context,
}) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();

  throw FormatException(
    'Invalid $key in $context. Use a number.',
  );
}

bool? parseOptionalBool(
  Object? raw,
  String key, {
  required String context,
}) {
  if (raw == null) return null;
  if (raw is bool) return raw;

  throw FormatException(
    'Invalid $key in $context. Use true or false.',
  );
}
