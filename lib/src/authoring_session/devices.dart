part of 'authoring_session.dart';

extension AuthoringSessionDevices on AuthoringSession {
  void _addConnectedDevice(
      DeviceConfiguration deviceConfiguration, String primaryDeviceRoleName) {
    final primaryDeviceConfiguration = deviceConfigurationRegistry
        .getPrimaryDeviceConfigurationByRoleName(primaryDeviceRoleName);
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

  void addESenseDevice(String? connectedDeviceRoleName,
      String primaryDeviceRoleName, bool? isOptional, int? samplingRate) {
    final eSenseDevice = ESenseDevice(
      roleName: connectedDeviceRoleName ?? ESenseDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional ?? true,
      samplingRate: samplingRate ?? 10,
    );

    _addConnectedDevice(eSenseDevice, primaryDeviceRoleName);
  }

  void addMovesenseDevice(String? connectedDeviceRoleName,
      String primaryDeviceRoleName, bool? isOptional) {
    final movesenseDevice = MovesenseDevice(
      roleName: MovesenseDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional ?? true,
    );

    _addConnectedDevice(movesenseDevice, primaryDeviceRoleName);
  }

  void addMovisensDevice(
      String? connectedDeviceRoleName,
      String primaryDeviceRoleName,
      SensorLocation? sensorLocation,
      Sex? sex,
      int? height,
      int? weight,
      int? age) {
    final movisensDevice = MovisensDevice(
      roleName: connectedDeviceRoleName,
      sensorLocation: sensorLocation ?? SensorLocation.Chest,
      sex: sex ?? Sex.Male,
      height: height ?? 178,
      weight: weight ?? 78,
      age: age ?? 25,
    );

    _addConnectedDevice(movisensDevice, primaryDeviceRoleName);
  }

  void addPolarDevice(String? connectedDeviceRoleName,
      String primaryDeviceRoleName, bool? isOptional, String? namePrefix) {
    final polarDevice = PolarDevice(
      roleName: connectedDeviceRoleName ?? PolarDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional ?? true,
      namePrefix: namePrefix ?? 'Polar',
    );

    _addConnectedDevice(polarDevice, primaryDeviceRoleName);
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
