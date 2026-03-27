import 'package:carp_backend/carp_backend.dart';

import 'package:study_protocol_authoring_server/src/authoring_session.dart';
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
  })  : _sessionStore = sessionStore ?? InMemoryAuthoringSessionStore(),
        _sessionIdGenerator = sessionIdGenerator ?? _defaultSessionIdGenerator;

  final AuthoringSessionStore _sessionStore;
  final SessionIdGenerator _sessionIdGenerator;

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

  String createSession() {
    var sessionId = _sessionIdGenerator();
    while (_sessionStore.exists(sessionId)) {
      sessionId = _sessionIdGenerator();
    }

    _sessionStore.create(sessionId);
    return sessionId;
  }

  Map<String, dynamic> createNewProtocol(
      String sessionId, String name, String? ownerId) {
    final session = _getSessionOrThrow(sessionId);

    session.newSmartphoneProtocol(name, ownerId);

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

  Map<String, dynamic> addPrimaryDevice(
    String sessionId,
    String deviceType,
    String? roleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addPrimaryDevice(deviceType, roleName);
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
