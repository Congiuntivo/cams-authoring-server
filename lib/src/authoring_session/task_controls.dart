part of 'authoring_session.dart';

extension AuthoringSessionTaskControls on AuthoringSession {
  void addTaskControl(
      String taskName, String triggerName, String deviceRoleName) {
    if (!taskConfigurations.containsKey(taskName)) {
      throw ArgumentError(
          'Task "$taskName" is not defined in task configurations.');
    }
    if (!triggerConfigurations.containsKey(triggerName)) {
      throw ArgumentError(
          'Trigger "$triggerName" is not defined in trigger configurations.');
    }

    final deviceConfig = deviceConfigurationRegistry
        .getDeviceConfigurationByRoleName(deviceRoleName);
    if (deviceConfig == null) {
      throw ArgumentError(
          'Device role "$deviceRoleName" is not defined in protocol devices or services.');
    }

    protocol.addTaskControl(triggerConfigurations[triggerName]!,
        taskConfigurations[taskName]!, deviceConfig);
    _authoringRequirements.markTaskUsageWarningFulfilled(taskName);
    _authoringRequirements.markTriggerUsageWarningFulfilled(triggerName);
    _authoringRequirements.markDeviceUsageWarningFulfilled(deviceRoleName);
    _authoringRequirements.markServiceUsageWarningFulfilled(deviceRoleName);
  }

  List<Map<String, Object?>> getTaskControls() {
    DeviceConfiguration resolveTargetDevice(TaskControl taskControl) {
      final destinationDeviceRoleName = taskControl.destinationDeviceRoleName;
      if (destinationDeviceRoleName == null) {
        throw StateError(
            'Task control "${taskControl.taskName}" is missing destination device role name.');
      }

      final targetDevice = deviceConfigurationRegistry
          .getDeviceConfigurationByRoleName(destinationDeviceRoleName);
      if (targetDevice == null) {
        throw StateError(
            'Device role "$destinationDeviceRoleName" from task control "${taskControl.taskName}" is not defined in protocol devices or services.');
      }

      return targetDevice;
    }

    return protocol.taskControls
        .map((taskControl) => {
              'taskControl': taskControl.toJson(),
              "trigger":
                  protocol.triggers['${taskControl.triggerId}']?.toJson(),
              "task": protocol.tasks
                  .firstWhere((task) => task.name == taskControl.taskName)
                  .toJson(),
              "targetDevice": resolveTargetDevice(taskControl).toJson()
            })
        .toList();
  }
}
