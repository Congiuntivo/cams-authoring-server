part of 'authoring_service.dart';

extension ProtocolAuthoringServiceServices on ProtocolAuthoringService {
  Map<String, dynamic> addWeatherService(
    String sessionId,
    String? roleName,
    String primaryDeviceRoleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addWeatherService(roleName, primaryDeviceRoleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addAirQualityService(
    String sessionId,
    String? roleName,
    String primaryDeviceRoleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addAirQualityService(roleName, primaryDeviceRoleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addHealthService(
    String sessionId,
    String? roleName,
    String primaryDeviceRoleName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addHealthService(roleName, primaryDeviceRoleName);
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addLocationService(
    String sessionId,
    String? roleName,
    String primaryDeviceRoleName,
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
      primaryDeviceRoleName,
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
}
