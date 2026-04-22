import 'package:carp_core/carp_core.dart' hide Smartphone;
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';

import 'authoring_session_state.dart';

class InMemoryAuthoringSessionState implements AuthoringSessionState {
  late SmartphoneStudyProtocol _protocol;

  final Map<String, PrimaryDeviceConfiguration> _primaryDevices = {};
  final Map<String, DeviceConfiguration> _connectedDevices = {};
  final Map<String, DeviceConfiguration> _services = {};
  final Map<String, TaskConfiguration> _tasks = {};
  final Map<String, TriggerConfiguration> _triggers = {};

  @override
  SmartphoneStudyProtocol get protocol => _protocol;

  @override
  void initProtocol(SmartphoneStudyProtocol protocol) => _protocol = protocol;

  @override
  void addPrimaryDevice(PrimaryDeviceConfiguration device) =>
      _primaryDevices[device.roleName] = device;

  @override
  PrimaryDeviceConfiguration? findPrimaryDevice(String roleName) =>
      _primaryDevices[roleName];

  @override
  Iterable<MapEntry<String, PrimaryDeviceConfiguration>>
      get primaryDeviceEntries => _primaryDevices.entries;

  @override
  void addConnectedDevice(DeviceConfiguration device) =>
      _connectedDevices[device.roleName] = device;

  @override
  Iterable<MapEntry<String, DeviceConfiguration>> get connectedDeviceEntries =>
      _connectedDevices.entries;

  @override
  void addService(DeviceConfiguration service) =>
      _services[service.roleName] = service;

  @override
  Iterable<DeviceConfiguration> get allServices => _services.values;

  @override
  bool isDeviceRoleNameUsed(String roleName) =>
      _primaryDevices.containsKey(roleName) ||
      _connectedDevices.containsKey(roleName) ||
      _services.containsKey(roleName);

  @override
  DeviceConfiguration? findAnyDevice(String roleName) =>
      _connectedDevices[roleName] ??
      _services[roleName] ??
      _primaryDevices[roleName];

  @override
  void putTask(String name, TaskConfiguration task) => _tasks[name] = task;

  @override
  TaskConfiguration? findTask(String name) => _tasks[name];

  @override
  bool hasTask(String name) => _tasks.containsKey(name);

  @override
  Iterable<MapEntry<String, TaskConfiguration>> get taskEntries =>
      _tasks.entries;

  @override
  void putTrigger(String name, TriggerConfiguration trigger) =>
      _triggers[name] = trigger;

  @override
  TriggerConfiguration? findTrigger(String name) => _triggers[name];

  @override
  bool hasTrigger(String name) => _triggers.containsKey(name);

  @override
  Iterable<MapEntry<String, TriggerConfiguration>> get triggerEntries =>
      _triggers.entries;
}
