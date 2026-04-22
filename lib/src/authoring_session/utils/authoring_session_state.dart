import 'package:carp_core/carp_core.dart' hide Smartphone;
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';

abstract class AuthoringSessionState {
  // Protocol
  SmartphoneStudyProtocol get protocol;
  void initProtocol(SmartphoneStudyProtocol protocol);

  // Primary devices
  void addPrimaryDevice(PrimaryDeviceConfiguration device);
  PrimaryDeviceConfiguration? findPrimaryDevice(String roleName);
  Iterable<MapEntry<String, PrimaryDeviceConfiguration>>
      get primaryDeviceEntries;

  // Connected devices
  void addConnectedDevice(DeviceConfiguration device);
  Iterable<MapEntry<String, DeviceConfiguration>> get connectedDeviceEntries;

  // Services
  void addService(DeviceConfiguration service);
  Iterable<DeviceConfiguration> get allServices;

  // Cross-collection helpers
  bool isDeviceRoleNameUsed(String roleName);
  DeviceConfiguration? findAnyDevice(String roleName);

  // Tasks
  void putTask(String name, TaskConfiguration task);
  TaskConfiguration? findTask(String name);
  bool hasTask(String name);
  Iterable<MapEntry<String, TaskConfiguration>> get taskEntries;

  // Triggers
  void putTrigger(String name, TriggerConfiguration trigger);
  TriggerConfiguration? findTrigger(String name);
  bool hasTrigger(String name);
  Iterable<MapEntry<String, TriggerConfiguration>> get triggerEntries;
}
