part of 'authoring_service.dart';

extension ProtocolAuthoringServiceTasks on ProtocolAuthoringService {
  Map<String, dynamic> addBackgroundTask(
    String sessionId,
    String name,
    String description,
    List<TaskMeasureInput> measures,
    Duration? duration,
  ) {
    final session = _getSessionOrThrow(sessionId);

    if (duration != null && duration.inMicroseconds < 0) {
      throw ArgumentError(
        'Invalid duration. Use a non-negative duration.',
      );
    }

    final parsedMeasures = _taskMeasureParser.parseMeasures(
      measures,
      policy: backgroundTaskMeasurePolicy,
    );

    session.createBackgroundTask(name, description, parsedMeasures, duration);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addWebTask(
    String sessionId,
    String name,
    String description,
    List<TaskMeasureInput> measures,
    String url,
  ) {
    final session = _getSessionOrThrow(sessionId);

    final parsedMeasures = _taskMeasureParser.parseMeasures(
      measures,
      policy: backgroundTaskMeasurePolicy,
    );

    session.createWebTask(name, description, parsedMeasures, url);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addAppTask(
    String sessionId,
    String name,
    String description,
    List<TaskMeasureInput> measures,
    String type,
    String? title,
    String? instructions,
    int? minutesToComplete,
    Duration? expire,
    bool? notification,
  ) {
    final session = _getSessionOrThrow(sessionId);

    final parsedMeasures = _taskMeasureParser.parseMeasures(
      measures,
      policy: backgroundTaskMeasurePolicy,
    );
    final growableMeasures = List<Measure>.from(parsedMeasures);

    session.createAppTask(
      name,
      description,
      growableMeasures,
      type,
      title,
      instructions,
      minutesToComplete,
      expire,
      notification,
    );

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addHealthAppTask(
    String sessionId,
    String name,
    String description,
    List<TaskMeasureInput> measures,
    String? title,
    String? instructions,
    int? minutesToComplete,
    Duration? expire,
    bool? notification,
    List<String> types,
  ) {
    final session = _getSessionOrThrow(sessionId);

    final parsedMeasures = _taskMeasureParser.parseMeasures(
      measures,
      policy: backgroundTaskMeasurePolicy,
    );
    final growableMeasures = List<Measure>.from(parsedMeasures);
    final parsedTypes = _parseHealthDataTypes(types);

    session.createHealthAppTask(
      name,
      description,
      growableMeasures,
      title,
      instructions,
      minutesToComplete,
      expire,
      notification,
      parsedTypes,
    );

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }
}
