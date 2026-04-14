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
  }

  List<Map<String, Object?>> getTaskControls() {
    return protocol?.taskControls
            .map((taskControl) => taskControl.toJson())
            .toList() ??
        [];
  }
}
