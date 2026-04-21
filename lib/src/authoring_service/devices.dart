part of 'authoring_service.dart';

extension ProtocolAuthoringServiceDevices on ProtocolAuthoringService {
  Map<String, dynamic> addESenseDevice(
    String sessionId,
    String? roleName,
    String primaryDeviceRoleName,
    bool? isOptional,
    int? samplingRate,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addESenseDevice(
      roleName,
      primaryDeviceRoleName,
      isOptional,
      samplingRate,
    );
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addMovesenseDevice(
    String sessionId,
    String? roleName,
    String primaryDeviceRoleName,
    bool? isOptional,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addMovesenseDevice(
      roleName,
      primaryDeviceRoleName,
      isOptional,
    );
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addMovisensDevice(
    String sessionId,
    String? roleName,
    String primaryDeviceRoleName,
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
      primaryDeviceRoleName,
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
    String primaryDeviceRoleName,
    bool? isOptional,
    String? namePrefix,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.addPolarDevice(
      roleName,
      primaryDeviceRoleName,
      isOptional,
      namePrefix,
    );
    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
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
}
