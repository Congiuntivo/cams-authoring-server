import 'dart:collection';

import 'package:carp_core/carp_core.dart';

class DeviceConfigurationRegistry {
  final Map<String, PrimaryDeviceConfiguration> _primaryDeviceConfigurations =
      {};
  final Map<String, DeviceConfiguration> _connectedDeviceConfigurations = {};
  final Map<String, DeviceConfiguration> _serviceConfigurations = {};

  String? _activePrimaryDeviceRoleName;

  Map<String, PrimaryDeviceConfiguration> get primaryDeviceConfigurations =>
      UnmodifiableMapView(_primaryDeviceConfigurations);

  Map<String, DeviceConfiguration> get connectedDeviceConfigurations =>
      UnmodifiableMapView(_connectedDeviceConfigurations);

  Map<String, DeviceConfiguration> get serviceConfigurations =>
      UnmodifiableMapView(_serviceConfigurations);

  // TODO: We need to allow more than one primary device, so this method needs to go
  PrimaryDeviceConfiguration? get activePrimaryDevice =>
      _activePrimaryDeviceRoleName == null
          ? null
          : _primaryDeviceConfigurations[_activePrimaryDeviceRoleName];

  bool isRoleNameUsed(String roleName) => _roleNameSourcesCount(roleName) > 0;

  void ensureRoleNameAvailable(String roleName) {
    if (isRoleNameUsed(roleName)) {
      throw ArgumentError('Device role name already taken: $roleName');
    }
  }

  void registerPrimaryDevice(PrimaryDeviceConfiguration primaryDevice) {
    ensureRoleNameAvailable(primaryDevice.roleName);
    _primaryDeviceConfigurations[primaryDevice.roleName] = primaryDevice;
    // TODO: We need to allow more than one primary device, so this assignment needs to go
    _activePrimaryDeviceRoleName = primaryDevice.roleName;
  }

  void registerConnectedDevice(DeviceConfiguration deviceConfiguration) {
    ensureRoleNameAvailable(deviceConfiguration.roleName);
    _connectedDeviceConfigurations[deviceConfiguration.roleName] =
        deviceConfiguration;
  }

  void registerService(DeviceConfiguration serviceConfiguration) {
    ensureRoleNameAvailable(serviceConfiguration.roleName);
    _serviceConfigurations[serviceConfiguration.roleName] =
        serviceConfiguration;
  }

  DeviceConfiguration? getDeviceConfigurationByRoleName(String roleName) {
    final sourceCount = _roleNameSourcesCount(roleName);
    if (sourceCount > 1) {
      throw StateError(
          'Role name "$roleName" is duplicated across primary device, devices, or services.');
    }

    if (_connectedDeviceConfigurations.containsKey(roleName)) {
      return _connectedDeviceConfigurations[roleName];
    }
    if (_serviceConfigurations.containsKey(roleName)) {
      return _serviceConfigurations[roleName];
    }
    if (_primaryDeviceConfigurations.containsKey(roleName)) {
      return _primaryDeviceConfigurations[roleName];
    }

    return null;
  }

  int _roleNameSourcesCount(String roleName) {
    var count = 0;
    if (_connectedDeviceConfigurations.containsKey(roleName)) count++;
    if (_serviceConfigurations.containsKey(roleName)) count++;
    if (_primaryDeviceConfigurations.containsKey(roleName)) count++;
    return count;
  }
}
