part of 'authoring_session.dart';

extension AuthoringSessionDevices on AuthoringSession {
  void _addConnectedDevice(
    DeviceConfiguration deviceConfiguration,
  ) {
    // TODO: There can be more than one primary device
    final primaryDeviceConfiguration =
        deviceConfigurationRegistry.activePrimaryDevice;
    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding another device.');
    }
    deviceConfigurationRegistry
        .ensureRoleNameAvailable(deviceConfiguration.roleName);

    protocol.addConnectedDevice(
        deviceConfiguration, primaryDeviceConfiguration);
    deviceConfigurationRegistry.registerConnectedDevice(deviceConfiguration);
    _authoringRequirements
        .registerDeviceUsageWarning(deviceConfiguration.roleName);
  }

  void addESenseDevice(String? roleName, bool? isOptional, int? samplingRate) {
    final eSenseDevice = ESenseDevice(
      roleName: roleName ?? ESenseDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional ?? true,
      samplingRate: samplingRate ?? 10,
    );

    _addConnectedDevice(eSenseDevice);
  }

  void addMovesenseDevice(String? roleName, bool? isOptional) {
    final movesenseDevice = MovesenseDevice(
      roleName: MovesenseDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional ?? true,
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
      isOptional: isOptional ?? true,
      namePrefix: namePrefix ?? 'Polar',
    );

    _addConnectedDevice(polarDevice);
  }

  List<Map<String, Object?>> getDevices() {
    return deviceConfigurationRegistry.connectedDeviceConfigurations.entries
        .map((entry) => {
              'name': entry.key,
              'device': entry.value.toJson(),
            })
        .toList();
  }
}
