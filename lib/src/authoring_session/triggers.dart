part of 'authoring_session.dart';

extension AuthoringSessionTriggers on AuthoringSession {
  void _addTriggerConfiguration(
      TriggerConfiguration triggerConfiguration, String triggerName) {
    if (_isTriggerNameTaken(triggerName)) {
      throw ArgumentError('Task name already taken: $triggerName');
    }

    triggerConfigurations[triggerName] = triggerConfiguration;
  }

  bool _isTriggerNameTaken(String triggerName) {
    return triggerConfigurations.containsKey(triggerName);
  }

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

  /*
  TRIGGERS:
✅  ✔️ CronScheduledTrigger(
✅     DateTimeTrigger(
✅     DelayedTrigger(
✅     ElapsedTimeTrigger(
✅     ImmediateTrigger(
✅     ManualTrigger(
✅     NoOpTrigger(
✅     NoUserTaskTrigger(
✅     OneTimeTrigger(
✅     PassiveTrigger(
✅     PeriodicTrigger(
✅     RandomRecurrentTrigger(
✅     RecurrentScheduledTrigger(
✅     RemoteTrigger(
✅     SamplingEventTrigger(
✅     ScheduledTrigger(
✅     UserTaskTrigger(


// ASK: Conditional triggers take a Function as an argument. a) it's an hazard; b) how do you do it? metaprogramming? should have a look at how it serializes
// I tested the serialization and apparently it does not serialize. So there should be no reason to implement it.
❓     ConditionalPeriodicTrigger(
❓     ConditionalSamplingEventTrigger(

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
