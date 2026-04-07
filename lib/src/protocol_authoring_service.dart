import 'package:carp_backend/carp_backend.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_movesense_package/carp_movesense_package.dart';

import 'package:study_protocol_authoring_server/src/authoring_session/authoring_session.dart';
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
