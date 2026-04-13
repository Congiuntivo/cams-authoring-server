import '../request_parsing_utils.dart';

class DurationRequest {
  const DurationRequest({
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
    this.milliseconds,
    this.microseconds,
  });

  final int? days;
  final int? hours;
  final int? minutes;
  final int? seconds;
  final int? milliseconds;
  final int? microseconds;

  factory DurationRequest.fromJson(
    Map<String, dynamic> json, {
    required String context,
  }) {
    ensureNoUnknownFields(
      json,
      const <String>{
        'days',
        'hours',
        'minutes',
        'seconds',
        'milliseconds',
        'microseconds',
      },
      context,
    );

    final days = _parseOptionalNonNegativeInt(
      json['days'],
      'days',
      context: context,
    );
    final hours = _parseOptionalNonNegativeInt(
      json['hours'],
      'hours',
      context: context,
    );
    final minutes = _parseOptionalNonNegativeInt(
      json['minutes'],
      'minutes',
      context: context,
    );
    final seconds = _parseOptionalNonNegativeInt(
      json['seconds'],
      'seconds',
      context: context,
    );
    final milliseconds = _parseOptionalNonNegativeInt(
      json['milliseconds'],
      'milliseconds',
      context: context,
    );
    final microseconds = _parseOptionalNonNegativeInt(
      json['microseconds'],
      'microseconds',
      context: context,
    );

    if (days == null &&
        hours == null &&
        minutes == null &&
        seconds == null &&
        milliseconds == null &&
        microseconds == null) {
      throw FormatException(
        'Invalid $context. Provide at least one duration field.',
      );
    }

    return DurationRequest(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
      microseconds: microseconds,
    );
  }

  Duration toDuration() => Duration(
        days: days ?? 0,
        hours: hours ?? 0,
        minutes: minutes ?? 0,
        seconds: seconds ?? 0,
        milliseconds: milliseconds ?? 0,
        microseconds: microseconds ?? 0,
      );

  static DurationRequest? fromOptionalJson(
    Object? raw,
    String key, {
    required String context,
  }) {
    if (raw == null) return null;
    if (raw is! Map<String, dynamic>) {
      throw FormatException(
        'Invalid $key in $context. Use an object.',
      );
    }

    return DurationRequest.fromJson(
      raw,
      context: '$key in $context',
    );
  }

  static int? _parseOptionalNonNegativeInt(
    Object? raw,
    String key, {
    required String context,
  }) {
    final parsed = parseOptionalInt(raw, key, context: context);
    if (parsed != null && parsed < 0) {
      throw FormatException(
        'Invalid $key in $context. Use a non-negative integer.',
      );
    }
    return parsed;
  }
}
