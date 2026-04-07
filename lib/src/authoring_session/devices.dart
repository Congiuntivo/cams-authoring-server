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

  void addPolarDevice() {}

  List<String> getDeviceRoleNames() {
    return deviceConfigurations.map((device) => device.roleName).toList();
  }
}
