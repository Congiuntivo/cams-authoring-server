part of 'authoring_session.dart';

extension AuthoringSessionDevices on AuthoringSession {
  // ignore: unused_element
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

  List<String> getDeviceRoleNames() {
    return deviceConfigurations.map((device) => device.roleName).toList();
  }
}
