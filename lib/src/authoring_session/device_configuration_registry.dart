import 'dart:collection';

import 'package:carp_core/carp_core.dart';

class DeviceConfigurationRegistry {
  final Map<String, PrimaryDeviceConfiguration> _primaryDeviceConfigurations =
      {};
  final Map<String, DeviceConfiguration> _connectedDeviceConfigurations = {};
  final Map<String, DeviceConfiguration> _serviceConfigurations = {};

  Map<String, PrimaryDeviceConfiguration> get primaryDeviceConfigurations =>
      UnmodifiableMapView(_primaryDeviceConfigurations);

  Map<String, DeviceConfiguration> get connectedDeviceConfigurations =>
      UnmodifiableMapView(_connectedDeviceConfigurations);

  Map<String, DeviceConfiguration> get serviceConfigurations =>
      UnmodifiableMapView(_serviceConfigurations);

  bool isRoleNameUsed(String roleName) => _roleNameSourcesCount(roleName) > 0;

  void ensureRoleNameAvailable(String roleName) {
    if (isRoleNameUsed(roleName)) {
      throw ArgumentError('Device role name already taken: $roleName');
    }
  }

  void registerPrimaryDevice(PrimaryDeviceConfiguration primaryDevice) {
    ensureRoleNameAvailable(primaryDevice.roleName);
    _primaryDeviceConfigurations[primaryDevice.roleName] = primaryDevice;
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

  void _throwIfDuplicateRoleName(String roleName) {
    final sourceCount = _roleNameSourcesCount(roleName);
    if (sourceCount > 1) {
      throw StateError(
          'Role name "$roleName" is duplicated across primary device, devices, or services.');
    }
  }

  PrimaryDeviceConfiguration? getPrimaryDeviceConfigurationByRoleName(
      String roleName) {
    _throwIfDuplicateRoleName(roleName);
    return _primaryDeviceConfigurations[roleName];
  }

  DeviceConfiguration? getDeviceConfigurationByRoleName(String roleName) {
    _throwIfDuplicateRoleName(roleName);

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
