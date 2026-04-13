part of 'authoring_session.dart';

extension AuthoringSessionTriggers on AuthoringSession {
  // void _addTaskConfiguration(TaskConfiguration taskConfiguration) {
  //   if (_isTaskNameTaken(taskConfiguration.name)) {
  //     throw ArgumentError('Task name already taken: ${taskConfiguration.name}');
  //   }

  //   taskConfigurations.add(taskConfiguration);
  // }

  // bool _isTaskNameTaken(String taskName) {
  //   return taskConfigurations.any((task) => task.name == taskName);
  // }

  // ({String name, String description}) _validateRequiredFields(
  //     String name, String description) {
  //   final trimmedName = name.trim();
  //   final trimmedDescription = description.trim();

  //   if (trimmedName.isEmpty) {
  //     throw ArgumentError('Task name cannot be empty.');
  //   }
  //   if (trimmedDescription.isEmpty) {
  //     throw ArgumentError('Task description cannot be empty.');
  //   }

  //   return (name: trimmedName, description: trimmedDescription);
  // }

  /*
  TASKS:
✅  ✔️ AppTask(
✅  ✔️ BackgroundTask(
✅  ✔️ HealthAppTask(
    ✔️ RPAppTask(
✅  ✔️ WebTask(

    ❓ CustomProtocolTask(
    ❓ FunctionTask(
    ❓ RPNavigableOrderedTask(
    ❓ RPOrderedTask(
    ❓ RPTask(
    ❓ RPUITask(

    ❌ AutomaticTask(
    ❌ BackgroundSensingUserTask(
    ❌ CompletedAppTask(
    ❌ CompletedTask(
    ❌ HealthUserTask(
    ❌ SurveyUserTask(
    ❌ TriggeredTask(
    ❌ UserTask(
  */

  List<Map<String, Object?>> getTriggers() {
    return triggerConfigurations.entries
        .map((entry) => {
              'name': entry.key,
              'trigger': entry.value.toJson(),
            })
        .toList();
  }
}
