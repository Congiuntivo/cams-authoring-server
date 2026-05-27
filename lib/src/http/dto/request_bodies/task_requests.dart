import '../request_parsing_utils.dart';
import 'duration_request.dart';

class _TaskCoreFields {
  const _TaskCoreFields({
    required this.name,
    required this.description,
    required this.measures,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
}

_TaskCoreFields _parseTaskCoreFields(
  Map<String, dynamic> json, {
  required String context,
}) {
  final name = requireNonBlankString(
    json,
    'name',
    context: context,
  );
  final description = requireNonBlankString(
    json,
    'description',
    context: context,
  );

  final rawMeasures = json['measures'];
  if (rawMeasures is! List) {
    throw FormatException(
      'Invalid measures in $context. Use an array.',
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

  return _TaskCoreFields(
    name: name,
    description: description,
    measures: measures,
  );
}

class BackgroundTaskRequest {
  const BackgroundTaskRequest({
    required this.name,
    required this.description,
    required this.measures,
    this.duration,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
  final DurationRequest? duration;

  factory BackgroundTaskRequest.fromJson(Map<String, dynamic> json) {
    const context = 'background task request body';

    ensureNoUnknownFields(
      json,
      const <String>{'name', 'description', 'measures', 'duration'},
      context,
    );
    final taskCore = _parseTaskCoreFields(json, context: context);

    final duration = DurationRequest.fromOptionalJson(
      json['duration'],
      'duration',
      context: context,
    );

    return BackgroundTaskRequest(
      name: taskCore.name,
      description: taskCore.description,
      measures: taskCore.measures,
      duration: duration,
    );
  }
}

class WebTaskRequest {
  const WebTaskRequest({
    required this.name,
    required this.description,
    required this.measures,
    required this.url,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
  final String url;

  factory WebTaskRequest.fromJson(Map<String, dynamic> json) {
    const context = 'web task request body';

    ensureNoUnknownFields(
      json,
      const <String>{'name', 'description', 'measures', 'url'},
      context,
    );

    final taskCore = _parseTaskCoreFields(json, context: context);
    final url = requireValidUrlString(
      json,
      'url',
      context: context,
    );

    return WebTaskRequest(
      name: taskCore.name,
      description: taskCore.description,
      measures: taskCore.measures,
      url: url,
    );
  }
}

class AppTaskRequest {
  const AppTaskRequest({
    required this.name,
    required this.description,
    required this.measures,
    required this.type,
    this.title,
    this.instructions,
    this.minutesToComplete,
    this.expire,
    this.notification,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
  final String type;
  final String? title;
  final String? instructions;
  final int? minutesToComplete;
  final DurationRequest? expire;
  final bool? notification;

  factory AppTaskRequest.fromJson(Map<String, dynamic> json) {
    const context = 'app task request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'name',
        'description',
        'measures',
        'type',
        'title',
        'instructions',
        'minutesToComplete',
        'expire',
        'notification',
      },
      context,
    );

    final taskCore = _parseTaskCoreFields(json, context: context);

    return AppTaskRequest(
      name: taskCore.name,
      description: taskCore.description,
      measures: taskCore.measures,
      type: requireNonBlankString(
        json,
        'type',
        context: context,
      ),
      title: parseOptionalString(
        json['title'],
        'title',
        context: context,
      ),
      instructions: parseOptionalString(
        json['instructions'],
        'instructions',
        context: context,
      ),
      minutesToComplete: parseOptionalInt(
        json['minutesToComplete'],
        'minutesToComplete',
        context: context,
      ),
      expire: DurationRequest.fromOptionalJson(
        json['expire'],
        'expire',
        context: context,
      ),
      notification: parseOptionalBool(
        json['notification'],
        'notification',
        context: context,
      ),
    );
  }
}

class HealthAppTaskRequest {
  const HealthAppTaskRequest({
    required this.name,
    required this.description,
    required this.measures,
    required this.types,
    this.title,
    this.instructions,
    this.minutesToComplete,
    this.expire,
    this.notification,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
  final List<String> types;
  final String? title;
  final String? instructions;
  final int? minutesToComplete;
  final DurationRequest? expire;
  final bool? notification;

  factory HealthAppTaskRequest.fromJson(Map<String, dynamic> json) {
    const context = 'health app task request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'name',
        'description',
        'measures',
        'types',
        'title',
        'instructions',
        'minutesToComplete',
        'expire',
        'notification',
      },
      context,
    );

    final taskCore = _parseTaskCoreFields(json, context: context);
    final rawTypes = json['types'];
    if (rawTypes is! List) {
      throw const FormatException(
        'Invalid types in health app task request body. Use an array.',
      );
    }

    final types = <String>[];
    for (var index = 0; index < rawTypes.length; index++) {
      final rawType = rawTypes[index];
      if (rawType is! String || rawType.trim().isEmpty) {
        throw FormatException(
          'Invalid types[$index] in health app task request body. Use non-empty strings.',
        );
      }
      types.add(rawType.trim());
    }

    return HealthAppTaskRequest(
      name: taskCore.name,
      description: taskCore.description,
      measures: taskCore.measures,
      types: types,
      title: parseOptionalString(
        json['title'],
        'title',
        context: context,
      ),
      instructions: parseOptionalString(
        json['instructions'],
        'instructions',
        context: context,
      ),
      minutesToComplete: parseOptionalInt(
        json['minutesToComplete'],
        'minutesToComplete',
        context: context,
      ),
      expire: DurationRequest.fromOptionalJson(
        json['expire'],
        'expire',
        context: context,
      ),
      notification: parseOptionalBool(
        json['notification'],
        'notification',
        context: context,
      ),
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
    ensureNoUnknownFields(
      json,
      const <String>{'measureType', 'samplingConfiguration'},
      'task measure',
    );

    final measureType = requireNonBlankString(
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
    this.interval,
    this.duration,
    this.once,
    this.usePriorContexts,
    this.stopRadius,
    this.placeRadius,
    this.stopDuration,
    this.healthDataTypes,
    this.days,
  });

  final String samplingType;
  final DurationRequest? interval;
  final DurationRequest? duration;
  final bool? once;
  final bool? usePriorContexts;
  final double? stopRadius;
  final double? placeRadius;
  final DurationRequest? stopDuration;

  /// Health data types to collect (only used when [samplingType] is `"health"`).
  /// Each value must be a valid `HealthDataType` enum name, e.g. `"STEPS"`.
  final List<String>? healthDataTypes;

  /// How many days back to sample health data (only used when [samplingType]
  /// is `"health"`). Defaults to 30 when omitted. Must be >= 1.
  final int? days;

  factory TaskSamplingConfigurationRequest.fromJson(Map<String, dynamic> json) {
    const context = 'task samplingConfiguration';

    ensureNoUnknownFields(
      json,
      const <String>{
        'samplingType',
        'interval',
        'duration',
        'once',
        'usePriorContexts',
        'stopRadius',
        'placeRadius',
        'stopDuration',
        'healthDataTypes',
        'days',
      },
      context,
    );

    return TaskSamplingConfigurationRequest(
      samplingType: requireNonBlankString(
        json,
        'samplingType',
        context: context,
      ),
      interval: DurationRequest.fromOptionalJson(
        json['interval'],
        'interval',
        context: context,
      ),
      duration: DurationRequest.fromOptionalJson(
        json['duration'],
        'duration',
        context: context,
      ),
      once: parseOptionalBool(
        json['once'],
        'once',
        context: context,
      ),
      usePriorContexts: parseOptionalBool(
        json['usePriorContexts'],
        'usePriorContexts',
        context: context,
      ),
      stopRadius: parseOptionalDouble(
        json['stopRadius'],
        'stopRadius',
        context: context,
      ),
      placeRadius: parseOptionalDouble(
        json['placeRadius'],
        'placeRadius',
        context: context,
      ),
      stopDuration: DurationRequest.fromOptionalJson(
        json['stopDuration'],
        'stopDuration',
        context: context,
      ),
      healthDataTypes: _parseOptionalStringList(
        json['healthDataTypes'],
        'healthDataTypes',
        context: context,
      ),
      days: parseOptionalInt(
        json['days'],
        'days',
        context: context,
      ),
    );
  }
}

List<String>? _parseOptionalStringList(Object? raw, String key,
    {required String context}) {
  if (raw == null) return null;
  if (raw is! List) {
    throw FormatException('Invalid $key in $context. Use an array of strings.');
  }
  final result = <String>[];
  for (var i = 0; i < raw.length; i++) {
    final item = raw[i];
    if (item is! String || item.trim().isEmpty) {
      throw FormatException(
        'Invalid $key[$i] in $context. Use non-empty strings.',
      );
    }
    result.add(item.trim());
  }
  return result;
}
