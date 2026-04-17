import 'authoring_session/authoring_session.dart';

abstract class AuthoringSessionStore {
  AuthoringSession create(
    String sessionId,
    String name,
    String? ownerId,
    bool isSmartphone, {
    String? protocolVersionTag,
    String? protocolApiLevel,
    String? applicationName,
    String? privacySchemaName,
  });

  AuthoringSession? getById(String sessionId);

  bool exists(String sessionId);
}

class InMemoryAuthoringSessionStore implements AuthoringSessionStore {
  final Map<String, AuthoringSession> _sessions = <String, AuthoringSession>{};

  @override
  AuthoringSession create(
    String sessionId,
    String name,
    String? ownerId,
    bool isSmartphone, {
    String? protocolVersionTag,
    String? protocolApiLevel,
    String? applicationName,
    String? privacySchemaName,
  }) {
    final session = AuthoringSession(
      name,
      ownerId,
      isSmartphone,
      protocolVersionTag: protocolVersionTag,
      protocolApiLevel: protocolApiLevel,
      applicationName: applicationName,
      privacySchemaName: privacySchemaName,
    );
    _sessions[sessionId] = session;
    return session;
  }

  @override
  AuthoringSession? getById(String sessionId) => _sessions[sessionId];

  @override
  bool exists(String sessionId) => _sessions.containsKey(sessionId);
}
