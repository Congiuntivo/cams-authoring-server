part of 'authoring_session.dart';

extension AuthoringSessionTasks on AuthoringSession {
  void _addTaskConfiguration(TaskConfiguration taskConfiguration) {
    if (_state.hasTask(taskConfiguration.name)) {
      throw ArgumentError('Task name already taken: ${taskConfiguration.name}');
    }

    _state.putTask(taskConfiguration.name, taskConfiguration);
    _authoringRequirements.registerTaskUsageWarning(taskConfiguration.name);
  }

  ({String name, String description}) _validateRequiredFields(
      String name, String description) {
    final trimmedName = name.trim();
    final trimmedDescription = description.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Task name cannot be empty.');
    }
    if (trimmedDescription.isEmpty) {
      throw ArgumentError('Task description cannot be empty.');
    }

    return (name: trimmedName, description: trimmedDescription);
  }

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

  void createAppTask(
    String name,
    String description,
    List<Measure> measures,
    String type,
    String? title,
    String? instructions,
    int? minutesToComplete,
    Duration? expire,
    bool? notification,
  ) {
    final validatedFields = _validateRequiredFields(name, description);

    if (!_appTaskTypes.contains(type)) {
      throw ArgumentError('Unsupported app task type: $type');
    }

    final appTask = AppTask(
      name: validatedFields.name,
      description: validatedFields.description,
      measures: measures,
      type: type,
      title: title ?? '',
      instructions: instructions ?? '',
      minutesToComplete: minutesToComplete,
      expire: expire,
      notification: notification ?? false,
    );

    _addTaskConfiguration(appTask);
  }

  void createBackgroundTask(
    String name,
    String description,
    List<Measure> measures,
    Duration? duration,
  ) {
    final validatedFields = _validateRequiredFields(name, description);

    final backgroundTask = BackgroundTask(
      name: validatedFields.name,
      description: validatedFields.description,
      measures: measures,
      duration: duration,
    );
    _addTaskConfiguration(backgroundTask);
  }

  void createHealthAppTask(
    String name,
    String description,
    List<Measure> measures,
    String? title,
    String? instructions,
    int? minutesToComplete,
    Duration? expire,
    bool? notification,
    List<HealthDataType> types,
  ) {
    final validatedFields = _validateRequiredFields(name, description);

    final healthAppTask = HealthAppTask(
      name: validatedFields.name,
      description: validatedFields.description,
      measures: measures,
      instructions: instructions ?? '',
      title: title ?? '',
      minutesToComplete: minutesToComplete,
      expire: expire,
      notification: notification ?? false,
      types: types,
    );

    _addTaskConfiguration(healthAppTask);
  }

  // TODO: Implement RPAppTask.
  void createRPAppTask(
    String name,
    String description,
    List<Measure> measures,
  ) {}

  void createWebTask(
    String name,
    String description,
    List<Measure> measures,
    String url,
  ) {
    final validatedFields = _validateRequiredFields(name, description);
    final trimmedUrl = url.trim();
    if (!IsValid.validateURL(url: trimmedUrl)) {
      throw ArgumentError('Invalid URL: $url');
    }

    final webTask = WebTask(
      name: validatedFields.name,
      description: validatedFields.description,
      measures: measures,
      url: trimmedUrl,
    );

    _addTaskConfiguration(webTask);
  }

  List<Map<String, Object?>> getTasks() {
    return _state.taskEntries
        .map((entry) => {
              'name': entry.key,
              'serializedObj': entry.value.toJson(),
            })
        .toList();
  }
}
