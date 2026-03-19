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
      String sessionId, String name, String? ownerId) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    session.newProtocol(name, ownerId);
    return {
      'sessionId': sessionId,
      ...session.toStateJson(),
    };
  }

  Map<String, dynamic> getState(String sessionId) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);
    return session.toStateJson();
  }

  Map<String, dynamic> serialize(String sessionId) {
    final session = _sessionStore.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    return session.serialize();
  }
}
