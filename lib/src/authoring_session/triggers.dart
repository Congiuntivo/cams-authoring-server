part of 'authoring_session.dart';

extension AuthoringSessionTriggers on AuthoringSession {
  void _addTriggerConfiguration(
      TriggerConfiguration triggerConfiguration, String triggerName) {
    if (_isTriggerNameTaken(triggerName)) {
      throw ArgumentError('Task name already taken: $triggerName');
    }

    triggerConfigurations[triggerName] = triggerConfiguration;
    _authoringRequirements.registerTriggerUsageWarning(triggerName);
  }

  bool _isTriggerNameTaken(String triggerName) {
    return triggerConfigurations.containsKey(triggerName);
  }

  void createCronScheduledTrigger(
    String triggerName,
    int? minute,
    int? hour,
    int? day,
    int? month,
    int? weekday,
  ) {
    final triggerConfiguration = CronScheduledTrigger(
      minute: minute,
      hour: hour,
      day: day,
      month: month,
      weekday: weekday,
    );

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createDateTimeTrigger(String triggerName, DateTime dateTime) {
    final triggerConfiguration = DateTimeTrigger(schedule: dateTime);

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createDelayedTrigger(String triggerName, Duration delay) {
    final triggerConfiguration = DelayedTrigger(delay: delay);

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createElapsedTimeTrigger(String triggerName, Duration elapsedTime) {
    final triggerConfiguration = ElapsedTimeTrigger(elapsedTime: elapsedTime);

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createImmediateTrigger(String triggerName) {
    final triggerConfiguration = ImmediateTrigger();

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createManualTrigger(
      String triggerName, String? label, String? description) {
    final triggerConfiguration = ManualTrigger(
      label: label,
      description: description,
    );

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createNoOpTrigger(String triggerName) {
    final triggerConfiguration = NoOpTrigger();

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createNoUserTaskTrigger(String triggerName, String taskName) {
    final triggerConfiguration = NoUserTaskTrigger(taskName: taskName);

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createOneTimeTrigger(String triggerName) {
    final triggerConfiguration = OneTimeTrigger();

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createPassiveTrigger(String triggerName) {
    final triggerConfiguration = PassiveTrigger();

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createPeriodicTrigger(String triggerName, Duration period) {
    final triggerConfiguration = PeriodicTrigger(period: period);

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createRandomRecurrentTrigger(
    String triggerName,
    int minNumberOfTriggers,
    int maxNumberOfTriggers,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    final triggerConfiguration = RandomRecurrentTrigger(
      minNumberOfTriggers: minNumberOfTriggers,
      maxNumberOfTriggers: maxNumberOfTriggers,
      startTime: startTime,
      endTime: endTime,
    );

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createRecurrentScheduledTrigger(
    String triggerName,
    RecurrentType type,
    TimeOfDay time,
    DateTime? end,
    int? separationCount,
    int? maxNumberOfSampling,
    int? dayOfWeek,
    int? weekOfMonth,
    int? dayOfMonth,
    Duration? duration,
  ) {
    final triggerConfiguration = RecurrentScheduledTrigger(
      time: time,
      type: type,
      end: end,
      separationCount: separationCount ?? 0,
      maxNumberOfSampling: maxNumberOfSampling,
      dayOfWeek: dayOfWeek,
      weekOfMonth: weekOfMonth,
      dayOfMonth: dayOfMonth,
      duration: duration,
    );

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createSamplingEventTrigger(
    String triggerName,
    String measureType,
    Data? triggerCondition,
  ) {
    final triggerConfiguration = SamplingEventTrigger(
      measureType: measureType,
      triggerCondition: triggerCondition,
    );

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createScheduledTrigger(
      String triggerName, TimeOfDay time, RecurrenceRule recurrenceRule) {
    final triggerConfiguration = ScheduledTrigger(
      time: time,
      recurrenceRule: recurrenceRule,
    );

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  void createUserTaskTrigger(
      String triggerName, String taskName, UserTaskState triggerCondition) {
    final triggerConfiguration =
        UserTaskTrigger(taskName: taskName, triggerCondition: triggerCondition);

    _addTriggerConfiguration(triggerConfiguration, triggerName);
  }

  List<Map<String, Object?>> getTriggers() {
    return triggerConfigurations.entries
        .map((entry) => {
              'name': entry.key,
              'trigger': entry.value.toJson(),
            })
        .toList();
  }
}
