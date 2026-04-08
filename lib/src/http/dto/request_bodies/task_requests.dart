class BackgroundTaskRequest {
  const BackgroundTaskRequest({
    required this.name,
    required this.description,
    required this.measures,
    this.durationSeconds,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
  final int? durationSeconds;

  factory BackgroundTaskRequest.fromJson(Map<String, dynamic> json) {
    _ensureNoUnknownFields(
      json,
      const <String>{'name', 'description', 'measures', 'durationSeconds'},
      'background task request body',
    );

    final name = _requireNonBlankString(
      json,
      'name',
      context: 'background task request body',
    );
    final description = _requireNonBlankString(
      json,
      'description',
      context: 'background task request body',
    );

    final rawMeasures = json['measures'];
    if (rawMeasures is! List) {
      throw const FormatException(
        'Invalid measures in background task request body. Use an array.',
      );
    }
    if (rawMeasures.isEmpty) {
      throw const FormatException(
        'Missing measures. Provide a non-empty measures array in request body.',
      );
    }

    final measures = <TaskMeasureRequest>[];
    for (var index = 0; index < rawMeasures.length; index++) {
      final rawMeasure = rawMeasures[index];
      if (rawMeasure is! Map<String, dynamic>) {
        throw FormatException(
          'Invalid measures[$index]. Each measure must be an object.',
        );
      }
      measures.add(TaskMeasureRequest.fromJson(rawMeasure));
    }

    final durationSeconds = _parseOptionalInt(
      json['durationSeconds'],
      'durationSeconds',
      context: 'background task request body',
    );
    if (durationSeconds != null && durationSeconds < 0) {
      throw const FormatException(
        'Invalid durationSeconds in background task request body. Use a non-negative integer.',
      );
    }

    return BackgroundTaskRequest(
      name: name,
      description: description,
      measures: measures,
      durationSeconds: durationSeconds,
    );
  }
}

class TaskMeasureRequest {
  const TaskMeasureRequest({
    required this.measureType,
    this.samplingConfiguration,
  });

  final String measureType;
  final TaskSamplingConfigurationRequest? samplingConfiguration;

  factory TaskMeasureRequest.fromJson(Map<String, dynamic> json) {
    _ensureNoUnknownFields(
      json,
      const <String>{'measureType', 'samplingConfiguration'},
      'task measure',
    );

    final measureType = _requireNonBlankString(
      json,
      'measureType',
      context: 'task measure',
    );

    final rawSamplingConfiguration = json['samplingConfiguration'];
    if (rawSamplingConfiguration != null &&
        rawSamplingConfiguration is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid samplingConfiguration in task measure. Use an object.',
      );
    }

    return TaskMeasureRequest(
      measureType: measureType,
      samplingConfiguration: rawSamplingConfiguration == null
          ? null
          : TaskSamplingConfigurationRequest.fromJson(
              rawSamplingConfiguration,
            ),
    );
  }
}

class TaskSamplingConfigurationRequest {
  const TaskSamplingConfigurationRequest({
    required this.samplingType,
    this.intervalSeconds,
    this.durationSeconds,
    this.once,
    this.usePriorContexts,
    this.stopRadius,
    this.placeRadius,
    this.stopDurationSeconds,
  });

  final String samplingType;
  final int? intervalSeconds;
  final int? durationSeconds;
  final bool? once;
  final bool? usePriorContexts;
  final double? stopRadius;
  final double? placeRadius;
  final int? stopDurationSeconds;

  factory TaskSamplingConfigurationRequest.fromJson(Map<String, dynamic> json) {
    _ensureNoUnknownFields(
      json,
      const <String>{
        'samplingType',
        'intervalSeconds',
        'durationSeconds',
        'once',
        'usePriorContexts',
        'stopRadius',
        'placeRadius',
        'stopDurationSeconds',
      },
      'task samplingConfiguration',
    );

    return TaskSamplingConfigurationRequest(
      samplingType: _requireNonBlankString(
        json,
        'samplingType',
        context: 'task samplingConfiguration',
      ),
      intervalSeconds: _parseOptionalInt(
        json['intervalSeconds'],
        'intervalSeconds',
        context: 'task samplingConfiguration',
      ),
      durationSeconds: _parseOptionalInt(
        json['durationSeconds'],
        'durationSeconds',
        context: 'task samplingConfiguration',
      ),
      once: _parseOptionalBool(
        json['once'],
        'once',
        context: 'task samplingConfiguration',
      ),
      usePriorContexts: _parseOptionalBool(
        json['usePriorContexts'],
        'usePriorContexts',
        context: 'task samplingConfiguration',
      ),
      stopRadius: _parseOptionalDouble(
        json['stopRadius'],
        'stopRadius',
        context: 'task samplingConfiguration',
      ),
      placeRadius: _parseOptionalDouble(
        json['placeRadius'],
        'placeRadius',
        context: 'task samplingConfiguration',
      ),
      stopDurationSeconds: _parseOptionalInt(
        json['stopDurationSeconds'],
        'stopDurationSeconds',
        context: 'task samplingConfiguration',
      ),
    );
  }
}

void _ensureNoUnknownFields(
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

String _requireNonBlankString(
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

int? _parseOptionalInt(
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

double? _parseOptionalDouble(
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

bool? _parseOptionalBool(
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
