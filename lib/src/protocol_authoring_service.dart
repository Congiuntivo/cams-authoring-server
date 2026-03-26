import 'package:carp_backend/carp_backend.dart';

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

  String createSession() {
    var sessionId = _sessionIdGenerator();
    while (_sessionStore.exists(sessionId)) {
      sessionId = _sessionIdGenerator();
    }

    _sessionStore.create(sessionId);
    return sessionId;
  }

  Map<String, dynamic> createNewProtocol(
      String protocolType, String sessionId, String name, String? ownerId) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    switch (protocolType) {
      case 'smartphoneProtocol':
        session.newSmartphoneProtocol(name, ownerId);
        break;
      case 'studyProtocol':
        session.newStudyProtocol(name, ownerId);
        break;
      default:
        throw ArgumentError('Unknown protocol type: $protocolType');
    }

    return {'sessionId': sessionId};
  }

  Map<String, dynamic> getRequirements(String sessionId) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);
    return session.toRequirementsJson();
  }

  Map<String, dynamic> addDataEndPoint(
    String sessionId,
    String endPointType,
    CarpUploadMethod? method,
    String? name,
    bool? deleteWhenUploaded,
  ) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

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
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    session.addPrimaryDevice(deviceType, roleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addParticipantRole(
    String sessionId,
    String roleName,
    bool? isOptional,
  ) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

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
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

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
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    session.addExpectedParticipantData(null, dataType);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> serialize(String sessionId) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    return session.serialize();
  }
}
