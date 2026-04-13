import 'package:carp_backend/carp_backend.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_movesense_package/carp_movesense_package.dart';
import 'package:carp_movisens_package/carp_movisens_package.dart';
import 'package:carp_polar_package/carp_polar_package.dart';
import 'package:health/health.dart';

import 'package:study_protocol_authoring_server/src/authoring_session/authoring_session.dart';
import 'package:study_protocol_authoring_server/src/task_measure_parser.dart';
import 'authoring_session_store.dart';

typedef SessionIdGenerator = String Function();

class SessionNotFoundException implements Exception {
  SessionNotFoundException(this.sessionId);

  final String sessionId;

  @override
  String toString() => 'Session not found: $sessionId';
}

class ProtocolAuthoringService {
  ProtocolAuthoringService({
    AuthoringSessionStore? sessionStore,
    SessionIdGenerator? sessionIdGenerator,
    TaskMeasureParser? taskMeasureParser,
  })  : _sessionStore = sessionStore ?? InMemoryAuthoringSessionStore(),
        _sessionIdGenerator = sessionIdGenerator ?? _defaultSessionIdGenerator,
        _taskMeasureParser = taskMeasureParser ?? TaskMeasureParser();

  final AuthoringSessionStore _sessionStore;
  final SessionIdGenerator _sessionIdGenerator;
  final TaskMeasureParser _taskMeasureParser;

  static int _sessionCounter = 0;

  static String _defaultSessionIdGenerator() {
    _sessionCounter++;
    final micros = DateTime.now().microsecondsSinceEpoch;
    return 'session_${micros}_$_sessionCounter';
  }

  AuthoringSession _getSessionOrThrow(String sessionId) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);
    return session;
  }

  String _createSessionId() {
    var sessionId = _sessionIdGenerator();
    while (_sessionStore.exists(sessionId)) {
      sessionId = _sessionIdGenerator();
    }

    // _sessionStore.create(sessionId);
    return sessionId;
  }

  Map<String, dynamic> createNewProtocol(
      String name, String? ownerId, bool isSmartphone) {
    final sessionId = _createSessionId();
    _sessionStore.create(sessionId, name, ownerId, isSmartphone);

    return {'sessionId': sessionId};
  }

  Map<String, dynamic> getRequirements(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return session.toRequirementsJson();
  }

  Map<String, dynamic> addDataEndPoint(
    String sessionId,
    String endPointType,
    CarpUploadMethod? method,
    String? name,
    bool? deleteWhenUploaded,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addDataEndPoint(endPointType, method, name, deleteWhenUploaded);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addSmartphonePrimaryDevice(
    String sessionId,
    String? roleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addSmartphonePrimaryDevice(roleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addBrowserPrimaryDevice(
    String sessionId,
    String? roleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addBrowserPrimaryDevice(roleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> getPrimarydevice(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'roleName': session.getPrimaryDeviceRoleName(),
    };
  }

  Map<String, dynamic> addParticipantRole(
    String sessionId,
    String roleName,
    bool? isOptional,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addParticipantRole(roleName, isOptional);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> getParticipantRoles(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'roleNames': session.getParticipantRoleNames(),
    };
  }

  Map<String, dynamic> getServices(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'roleNames': session.getServiceRoleNames(),
    };
  }

  Map<String, dynamic> getDevices(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'roleNames': session.getDeviceRoleNames(),
    };
  }

  Map<String, dynamic> getTasks(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'tasks': session.getTasks(),
    };
  }

  Map<String, dynamic> getTriggers(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'triggers': session.getTriggers(),
    };
  }

  /// Create a cron scheduled trigger based on specifying:
  ///   * [minute] - The minute to trigger. `int` [0-59] or `null` (= match all).
  ///   * [hour] - The hour to trigger. `int` [0-23] or `null` (= match all).
  ///   * [day] - The day of the month to trigger. `int` [1-31] or `null` (= match all).
  ///   * [month] - The month to trigger. `int` [1-12] or `null` (= match all).
  ///   * [weekday] - The week day to trigger. `int` [0-6] or `null` (= match all).
  Map<String, dynamic> addCronScheduledTrigger(
    String sessionId,
    String triggerName,
    int? minute,
    int? hour,
    int? day,
    int? month,
    int? weekday,
  ) {
    final session = _getSessionOrThrow(sessionId);

    _validateCronField('minute', minute, 0, 59);
    _validateCronField('hour', hour, 0, 23);
    _validateCronField('day', day, 1, 31);
    _validateCronField('month', month, 1, 12);
    _validateCronField('weekday', weekday, 0, 6);

    session.createCronScheduledTrigger(
      triggerName,
      minute,
      hour,
      day,
      month,
      weekday,
    );

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addDateTimeTrigger(
    String sessionId,
    String triggerName,
    DateTime schedule,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createDateTimeTrigger(triggerName, schedule);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addDelayedTrigger(
    String sessionId,
    String triggerName,
    Duration delay,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createDelayedTrigger(triggerName, delay);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addElapsedTimeTrigger(
    String sessionId,
    String triggerName,
    Duration elapsedTime,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createElapsedTimeTrigger(triggerName, elapsedTime);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addImmediateTrigger(
    String sessionId,
    String triggerName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createImmediateTrigger(triggerName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addManualTrigger(
    String sessionId,
    String triggerName,
    String? label,
    String? description,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createManualTrigger(triggerName, label, description);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addNoOpTrigger(
    String sessionId,
    String triggerName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createNoOpTrigger(triggerName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addNoUserTaskTrigger(
    String sessionId,
    String triggerName,
    String taskName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createNoUserTaskTrigger(triggerName, taskName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  void _validateCronField(String fieldName, int? value, int min, int max) {
    if (value == null) return;
    if (value < min || value > max) {
      throw ArgumentError(
        '$fieldName must be in the range [$min-$max] or null (= match all).',
      );
    }
  }

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

    session.createAppTask(
      name,
      description,
      parsedMeasures,
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

  Map<String, dynamic> addESenseDevice(
    String sessionId,
    String? roleName,
    bool? isOptional,
    String? deviceName,
    int? samplingRate,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addESenseDevice(roleName, isOptional, deviceName, samplingRate);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addMovesenseDevice(
    String sessionId,
    String? roleName,
    bool? isOptional,
    String? name,
    String? address,
    String? serial,
    String? deviceType,
  ) {
    final session = _getSessionOrThrow(sessionId);
    final parsedDeviceType = _parseOptionalMovesenseDeviceType(deviceType);

    session.addMovesenseDevice(
      roleName,
      isOptional,
      name,
      address,
      serial,
      parsedDeviceType,
    );
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addMovisensDevice(
    String sessionId,
    String? roleName,
    String deviceName,
    String? sensorLocation,
    String? sex,
    int? height,
    int? weight,
    int? age,
  ) {
    final session = _getSessionOrThrow(sessionId);
    final parsedSensorLocation = _parseOptionalSensorLocation(sensorLocation);
    final parsedSex = _parseOptionalSex(sex);

    session.addMovisensDevice(
      roleName,
      deviceName,
      parsedSensorLocation,
      parsedSex,
      height,
      weight,
      age,
    );
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addPolarDevice(
    String sessionId,
    String? roleName,
    bool? isOptional,
    String? deviceType,
    String? identifier,
    String? name,
  ) {
    final session = _getSessionOrThrow(sessionId);
    final parsedDeviceType = _parseOptionalPolarDeviceType(deviceType);

    session.addPolarDevice(
      roleName,
      isOptional,
      parsedDeviceType,
      identifier,
      name,
    );
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addWeatherService(
    String sessionId,
    String? roleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addWeatherService(roleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addAirQualityService(
    String sessionId,
    String? roleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addAirQualityService(roleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addHealthService(
    String sessionId,
    String? roleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addHealthService(roleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addLocationService(
    String sessionId,
    String? roleName,
    String? accuracy,
    double? distance,
    Duration? interval,
    String? notificationTitle,
    String? notificationMessage,
    String? notificationDescription,
    String? notificationIconName,
    bool? notificationOnTapBringToFront,
  ) {
    final session = _getSessionOrThrow(sessionId);
    final parsedAccuracy = _parseOptionalLocationAccuracy(accuracy);

    session.addLocationService(
      roleName,
      parsedAccuracy,
      distance,
      interval,
      notificationTitle,
      notificationMessage,
      notificationDescription,
      notificationIconName,
      notificationOnTapBringToFront,
    );
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  GeolocationAccuracy? _parseOptionalLocationAccuracy(String? raw) {
    if (raw == null) return null;

    for (final value in GeolocationAccuracy.values) {
      if (value.name == raw) return value;
    }

    throw ArgumentError(
      'Unsupported accuracy. Supported values: '
      '${GeolocationAccuracy.values.map((value) => value.name).join(', ')}.',
    );
  }

  MovesenseDeviceType? _parseOptionalMovesenseDeviceType(String? raw) {
    if (raw == null) return null;

    for (final value in MovesenseDeviceType.values) {
      if (value.name == raw) return value;
    }

    throw ArgumentError(
      'Unsupported deviceType. Supported values: '
      '${MovesenseDeviceType.values.map((value) => value.name).join(', ')}.',
    );
  }

  SensorLocation? _parseOptionalSensorLocation(String? raw) {
    if (raw == null) return null;

    for (final value in SensorLocation.values) {
      if (value.name == raw) return value;
    }

    throw ArgumentError(
      'Unsupported sensorLocation. Supported values: '
      '${SensorLocation.values.map((value) => value.name).join(', ')}.',
    );
  }

  Sex? _parseOptionalSex(String? raw) {
    if (raw == null) return null;

    for (final value in Sex.values) {
      if (value.name == raw) return value;
    }

    throw ArgumentError(
      'Unsupported sex. Supported values: '
      '${Sex.values.map((value) => value.name).join(', ')}.',
    );
  }

  PolarDeviceType? _parseOptionalPolarDeviceType(String? raw) {
    if (raw == null) return null;

    for (final value in PolarDeviceType.values) {
      if (value.name == raw) return value;
    }

    throw ArgumentError(
      'Unsupported deviceType. Supported values: '
      '${PolarDeviceType.values.map((value) => value.name).join(', ')}.',
    );
  }

  List<HealthDataType> _parseHealthDataTypes(List<String> rawTypes) {
    final parsedTypes = <HealthDataType>[];

    for (final rawType in rawTypes) {
      var matched = false;
      for (final value in HealthDataType.values) {
        if (value.name == rawType) {
          parsedTypes.add(value);
          matched = true;
          break;
        }
      }

      if (!matched) {
        throw ArgumentError(
          'Unsupported healthDataType: $rawType. Supported values: '
          '${HealthDataType.values.map((value) => value.name).join(', ')}.',
        );
      }
    }

    return parsedTypes;
  }

  Map<String, dynamic> addExpectedParticipantDataForRole(
    String sessionId,
    String roleName,
    String dataType,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addExpectedParticipantData(roleName, dataType);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addExpectedParticipantDataForAllRoles(
    String sessionId,
    String dataType,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addExpectedParticipantData(null, dataType);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> serialize(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return session.serialize();
  }
}
