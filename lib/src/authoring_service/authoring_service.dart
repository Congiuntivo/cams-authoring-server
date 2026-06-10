import 'package:carp_backend/carp_backend.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_movisens_package/carp_movisens_package.dart';
import 'package:health/health.dart';

import 'package:study_protocol_authoring_server/src/authoring_service/utils/task_measure_parser.dart';
import 'package:study_protocol_authoring_server/src/authoring_session/authoring_session.dart';
import '../authoring_session_store.dart';

part 'devices.dart';
part 'services.dart';
part 'tasks.dart';
part 'triggers.dart';

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
    String name,
    String? ownerId, {
    String? protocolVersionTag,
    String? applicationName,
    String? privacySchemaName,
  }) {
    final sessionId = _createSessionId();
    _sessionStore.create(
      sessionId,
      name,
      ownerId,
      protocolVersionTag: protocolVersionTag,
      applicationName: applicationName,
      privacySchemaName: privacySchemaName,
    );

    return {'sessionId': sessionId};
  }

  Map<String, dynamic> setApplicationData(
    String sessionId,
    Map<String, dynamic> data,
  ) {
    final session = _getSessionOrThrow(sessionId);
    session.setApplicationData(data);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
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
    bool? deleteWhenUploaded, {
    int? bufferSize,
    bool? zip,
    bool? encrypt,
    String? publicKey,
  }) {
    final session = _getSessionOrThrow(sessionId);

    session.addDataEndPoint(
      endPointType,
      method,
      name,
      deleteWhenUploaded,
      bufferSize: bufferSize,
      zip: zip,
      encrypt: encrypt,
      publicKey: publicKey,
    );
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

  Map<String, dynamic> getPrimaryDevices(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'primaryDevices': session.getPrimaryDevices(),
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
      'services': session.getServices(),
    };
  }

  Map<String, dynamic> getDevices(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'devices': session.getDevices(),
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

  Map<String, dynamic> getTaskControls(String sessionId) {
    final session = _getSessionOrThrow(sessionId);

    return {
      'taskControls': session.getTaskControls(),
    };
  }

  Map<String, dynamic> addTaskControl(
    String sessionId,
    String taskName,
    String triggerName,
    String deviceRoleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addTaskControl(taskName, triggerName, deviceRoleName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
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
