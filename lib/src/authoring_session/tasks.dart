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

  Tuple2<String, String> _validateRequiredFields(
      String name, String description, List<Measure> measures) {
    final trimmedName = name.trim();
    final trimmedDescription = description.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Task name cannot be empty.');
    }
    if (trimmedDescription.isEmpty) {
      throw ArgumentError('Task description cannot be empty.');
    }
    if (measures.isEmpty) {
      throw ArgumentError(
          'Missing measures. Provide at least one measure for background tasks.');
    }

    return Tuple2(trimmedName, trimmedDescription);
  }

  /*
  TASKS:
    ✔️ AppTask(
✅  ✔️ BackgroundTask(
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
    final Tuple2<String, String> validatedFields =
        _validateRequiredFields(name, description, measures);

    final backgroundTask = BackgroundTask(
      name: validatedFields.item1,
      description: validatedFields.item2,
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
