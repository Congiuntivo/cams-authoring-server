part of 'authoring_session.dart';

extension AuthoringSessionTaskControls on AuthoringSession {
  void addTaskControl(
      String taskName, String triggerName, String deviceRoleName) {
    if (protocol == null) {
      throw StateError('Protocol must be set before adding task controls.');
    }
    if (!taskConfigurations.containsKey(taskName)) {
      throw ArgumentError(
          'Task "$taskName" is not defined in task configurations.');
    }
    if (!triggerConfigurations.containsKey(triggerName)) {
      throw ArgumentError(
          'Trigger "$triggerName" is not defined in trigger configurations.');
    }

    final deviceConfig = _getDeviceConfigurationForRoleName(deviceRoleName);
    if (deviceConfig == null) {
      throw ArgumentError(
          'Device role "$deviceRoleName" is not defined in protocol devices or services.');
    }

    protocol!.addTaskControl(triggerConfigurations[triggerName]!,
        taskConfigurations[taskName]!, deviceConfig);
    _authoringRequirements.markTaskUsageWarningFulfilled(taskName);
  }

  DeviceConfiguration? _getDeviceConfigurationForRoleName(String roleName) {
    final sourceCount = _roleNameSourcesCount(roleName);
    if (sourceCount > 1) {
      throw StateError(
          'Role name "$roleName" is duplicated across primary device, devices, or services.');
    }

    if (deviceConfigurations.containsKey(roleName)) {
      return deviceConfigurations[roleName];
    }
    if (serviceConfigurations.containsKey(roleName)) {
      return serviceConfigurations[roleName];
    }
    if (primaryDeviceConfiguration?.roleName == roleName) {
      return primaryDeviceConfiguration;
    }

    return null;
  }

  List<Map<String, Object?>> getTaskControls() {
    return protocol?.taskControls
            .map((taskControl) => {
                  'taskControl': taskControl.toJson(),
                  "trigger":
                      protocol?.triggers['${taskControl.triggerId}']?.toJson(),
                  "task": protocol?.tasks
                      .firstWhere((task) => task.name == taskControl.taskName)
                      .toJson(),
                  "targetDevice": protocol?.devices
                      .firstWhere((device) =>
                          device.roleName ==
                          taskControl.destinationDeviceRoleName)
                      .toJson()
                })
            .toList() ??
        [];
  }
}
