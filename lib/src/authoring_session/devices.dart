part of 'authoring_session.dart';

extension AuthoringSessionDevices on AuthoringSession {
  void _addConnectedDevice(
    DeviceConfiguration deviceConfiguration,
    String? requestedRoleName,
  ) {
    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding another device.');
    }
    if (_isServiceRoleNameTaken(deviceConfiguration.roleName)) {
      throw ArgumentError('Device role name already taken: $requestedRoleName');
    }

    protocol!
        .addConnectedDevice(deviceConfiguration, primaryDeviceConfiguration!);
    deviceConfigurations.add(deviceConfiguration);
  }

  // TODO: Understand the reason of `bool? isOptional` and the behavior when it is null. I don't get why a boolean parameter can be nullable - it results in having three states ??¿¿
  void addESenseDevice(String? roleName, bool? isOptional, String? deviceName,
      int? samplingRate) {
    final eSenseDevice = ESenseDevice(
      roleName: roleName ?? ESenseDevice.DEFAULT_ROLENAME,
      isOptional: isOptional,
      deviceName: deviceName,
      samplingRate: samplingRate ?? 10,
    );

    _addConnectedDevice(eSenseDevice, roleName);
  }

  void addMovesenseDevice(String? roleName, bool? isOptional, String? name,
      String? address, String? serial, MovesenseDeviceType? deviceType) {
    final movesenseDevice = MovesenseDevice(
      roleName: MovesenseDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional,
      name: name,
      address: address,
      serial: serial,
      deviceType: deviceType ?? MovesenseDeviceType.UNKNOWN,
    );

    _addConnectedDevice(movesenseDevice, null);
  }

  void addMovisensDevice(
      String? roleName,
      String deviceName,
      SensorLocation? sensorLocation,
      Sex? sex,
      int? height,
      int? weight,
      int? age) {
    final movisensDevice = MovisensDevice(
      roleName: roleName,
      deviceName: deviceName,
      sensorLocation: sensorLocation ?? SensorLocation.Chest,
      sex: sex ?? Sex.Male,
      height: height ?? 178,
      weight: weight ?? 78,
      age: age ?? 25,
    );

    _addConnectedDevice(movisensDevice, roleName);
  }

  void addPolarDevice(String? roleName, bool? isOptional,
      PolarDeviceType? deviceType, String? identifier, String? name) {
    final polarDevice = PolarDevice(
      roleName: roleName ?? PolarDevice.DEFAULT_ROLE_NAME,
      isOptional: isOptional,
      deviceType: deviceType,
      identifier: identifier,
      name: name,
    );

    _addConnectedDevice(polarDevice, null);
  }

  List<String> getDeviceRoleNames() {
    return deviceConfigurations.map((device) => device.roleName).toList();
  }
}
