part of 'authoring_session.dart';

extension AuthoringSessionDevices on AuthoringSession {
  void _addConnectedDevice(
    DeviceConfiguration deviceConfiguration,
  ) {
    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding another device.');
    }
    if (_isRoleNameTaken(deviceConfiguration.roleName)) {
      throw ArgumentError(
          'Device role name already taken: ${deviceConfiguration.roleName}');
    }

    protocol!
        .addConnectedDevice(deviceConfiguration, primaryDeviceConfiguration!);
    deviceConfigurations[deviceConfiguration.roleName] = deviceConfiguration;
  }

  // ASK: Understand the reason of `bool? isOptional` and the behavior when it is null. I don't get why a boolean parameter can be nullable - it results in having three states ??¿¿
  void addESenseDevice(String? roleName, bool? isOptional, int? samplingRate) {
    final eSenseDevice = ESenseDevice(
      roleName: roleName ?? ESenseDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional,
      samplingRate: samplingRate ?? 10,
    );

    _addConnectedDevice(eSenseDevice);
  }

  void addMovesenseDevice(String? roleName, bool? isOptional) {
    final movesenseDevice = MovesenseDevice(
      roleName: MovesenseDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional,
    );

    _addConnectedDevice(movesenseDevice);
  }

  void addMovisensDevice(String? roleName, SensorLocation? sensorLocation,
      Sex? sex, int? height, int? weight, int? age) {
    final movisensDevice = MovisensDevice(
      roleName: roleName,
      sensorLocation: sensorLocation ?? SensorLocation.Chest,
      sex: sex ?? Sex.Male,
      height: height ?? 178,
      weight: weight ?? 78,
      age: age ?? 25,
    );

    _addConnectedDevice(movisensDevice);
  }

  void addPolarDevice(String? roleName, bool? isOptional, String? namePrefix) {
    final polarDevice = PolarDevice(
      roleName: roleName ?? PolarDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional,
      namePrefix: namePrefix ?? 'Polar',
    );

    _addConnectedDevice(polarDevice);
  }

  List<Map<String, Object?>> getDevices() {
    return deviceConfigurations.entries
        .map((entry) => {
              'name': entry.key,
              'device': entry.value.toJson(),
            })
        .toList();
  }
}
