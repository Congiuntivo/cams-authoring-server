import '../request_parsing_utils.dart';

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
    this.durationSeconds,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
  final int? durationSeconds;

  factory BackgroundTaskRequest.fromJson(Map<String, dynamic> json) {
    const context = 'background task request body';

    ensureNoUnknownFields(
      json,
      const <String>{'name', 'description', 'measures', 'durationSeconds'},
      context,
    );
    final taskCore = _parseTaskCoreFields(json, context: context);

    final durationSeconds = parseOptionalInt(
      json['durationSeconds'],
      'durationSeconds',
      context: context,
    );
    if (durationSeconds != null && durationSeconds < 0) {
      throw const FormatException(
        'Invalid durationSeconds in background task request body. Use a non-negative integer.',
      );
    }

    return BackgroundTaskRequest(
      name: taskCore.name,
      description: taskCore.description,
      measures: taskCore.measures,
      durationSeconds: durationSeconds,
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
    this.expireSeconds,
    this.notification,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
  final String type;
  final String? title;
  final String? instructions;
  final int? minutesToComplete;
  final int? expireSeconds;
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
        'expireSeconds',
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
      expireSeconds: parseOptionalInt(
        json['expireSeconds'],
        'expireSeconds',
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
    this.expireSeconds,
    this.notification,
  });

  final String name;
  final String description;
  final List<TaskMeasureRequest> measures;
  final List<String> types;
  final String? title;
  final String? instructions;
  final int? minutesToComplete;
  final int? expireSeconds;
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
        'expireSeconds',
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
      expireSeconds: parseOptionalInt(
        json['expireSeconds'],
        'expireSeconds',
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
    ensureNoUnknownFields(
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
      samplingType: requireNonBlankString(
        json,
        'samplingType',
        context: 'task samplingConfiguration',
      ),
      intervalSeconds: parseOptionalInt(
        json['intervalSeconds'],
        'intervalSeconds',
        context: 'task samplingConfiguration',
      ),
      durationSeconds: parseOptionalInt(
        json['durationSeconds'],
        'durationSeconds',
        context: 'task samplingConfiguration',
      ),
      once: parseOptionalBool(
        json['once'],
        'once',
        context: 'task samplingConfiguration',
      ),
      usePriorContexts: parseOptionalBool(
        json['usePriorContexts'],
        'usePriorContexts',
        context: 'task samplingConfiguration',
      ),
      stopRadius: parseOptionalDouble(
        json['stopRadius'],
        'stopRadius',
        context: 'task samplingConfiguration',
      ),
      placeRadius: parseOptionalDouble(
        json['placeRadius'],
        'placeRadius',
        context: 'task samplingConfiguration',
      ),
      stopDurationSeconds: parseOptionalInt(
        json['stopDurationSeconds'],
        'stopDurationSeconds',
        context: 'task samplingConfiguration',
      ),
    );
  }
}
