part of 'authoring_session.dart';

extension AuthoringSessionTasks on AuthoringSession {
  void _addTaskConfiguration(TaskConfiguration taskConfiguration) {
    if (_isTaskNameTaken(taskConfiguration.name)) {
      throw ArgumentError('Task name already taken: ${taskConfiguration.name}');
    }

    taskConfigurations.add(taskConfiguration);
  }

  bool _isTaskNameTaken(String taskName) {
    return taskConfigurations.any((task) => task.name == taskName);
  }

  /*
  TASKS:
    ✔️ AppTask(
    ✔️ BackgroundTask(
    ✔️ HealthAppTask(
    ✔️ RPAppTask(
    ✔️ WebTask(

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

  void createBackgroundTask(String name, String description,
      List<Measure> measures, Duration? duration) {
    final backgroundTask = BackgroundTask(
      name: name,
      description: description,
      measures: measures,
      duration: duration,
    );

    _addTaskConfiguration(backgroundTask);
  }

  List<Map<String, String>> getTasks() {
    return taskConfigurations
        .map((task) => {
              'name': task.name,
              'description': task.description ?? '',
            })
        .toList();
  }
}
