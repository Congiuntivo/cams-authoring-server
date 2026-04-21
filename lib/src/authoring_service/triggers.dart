part of 'authoring_service.dart';

extension ProtocolAuthoringServiceTriggers on ProtocolAuthoringService {
  /// Create a cron scheduled trigger based on specifying:
  ///   * [minute] - The minute to trigger. `int` [0-59] or `null` (= match all).
  ///   * [hour] - The hour to trigger. `int` [0-23] or `null` (= match all).
  ///   * [day] - The day of the month to trigger. `int` [1-31] or `null` (= match all).
  ///   * [month] - The month to trigger. `int` [1-12] or `null` (= match all).
  ///   * [weekday] - The week day to trigger. `int` [0-6] or `null` (= match all).
  Map<String, dynamic> addCronScheduledTrigger(
    String sessionId,
    String triggerName,
    int? minute,
    int? hour,
    int? day,
    int? month,
    int? weekday,
  ) {
    final session = _getSessionOrThrow(sessionId);

    _validateCronField('minute', minute, 0, 59);
    _validateCronField('hour', hour, 0, 23);
    _validateCronField('day', day, 1, 31);
    _validateCronField('month', month, 1, 12);
    _validateCronField('weekday', weekday, 0, 6);

    session.createCronScheduledTrigger(
      triggerName,
      minute,
      hour,
      day,
      month,
      weekday,
    );

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addDateTimeTrigger(
    String sessionId,
    String triggerName,
    DateTime schedule,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createDateTimeTrigger(triggerName, schedule);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addDelayedTrigger(
    String sessionId,
    String triggerName,
    Duration delay,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createDelayedTrigger(triggerName, delay);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addElapsedTimeTrigger(
    String sessionId,
    String triggerName,
    Duration elapsedTime,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createElapsedTimeTrigger(triggerName, elapsedTime);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addImmediateTrigger(
    String sessionId,
    String triggerName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createImmediateTrigger(triggerName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addManualTrigger(
    String sessionId,
    String triggerName,
    String? label,
    String? description,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createManualTrigger(triggerName, label, description);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addNoOpTrigger(
    String sessionId,
    String triggerName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createNoOpTrigger(triggerName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addNoUserTaskTrigger(
    String sessionId,
    String triggerName,
    String taskName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createNoUserTaskTrigger(triggerName, taskName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addOneTimeTrigger(
    String sessionId,
    String triggerName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createOneTimeTrigger(triggerName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addPassiveTrigger(
    String sessionId,
    String triggerName,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createPassiveTrigger(triggerName);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addPeriodicTrigger(
    String sessionId,
    String triggerName,
    Duration period,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createPeriodicTrigger(triggerName, period);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addRandomRecurrentTrigger(
    String sessionId,
    String triggerName,
    int minNumberOfTriggers,
    int maxNumberOfTriggers,
    int startHour,
    int startMinute,
    int startSecond,
    int endHour,
    int endMinute,
    int endSecond,
  ) {
    final session = _getSessionOrThrow(sessionId);

    final startTime =
        TimeOfDay(hour: startHour, minute: startMinute, second: startSecond);
    final endTime =
        TimeOfDay(hour: endHour, minute: endMinute, second: endSecond);

    session.createRandomRecurrentTrigger(
      triggerName,
      minNumberOfTriggers,
      maxNumberOfTriggers,
      startTime,
      endTime,
    );

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addRecurrentScheduledTrigger(
    String sessionId,
    String triggerName,
    String recurrentType,
    int timeHour,
    int timeMinute,
    int timeSecond,
    DateTime? end,
    int? separationCount,
    int? maxNumberOfSampling,
    int? dayOfWeek,
    int? weekOfMonth,
    int? dayOfMonth,
    Duration? duration,
  ) {
    final session = _getSessionOrThrow(sessionId);

    final type = _parseRecurrentType(recurrentType);
    final time =
        TimeOfDay(hour: timeHour, minute: timeMinute, second: timeSecond);

    session.createRecurrentScheduledTrigger(
      triggerName,
      type,
      time,
      end,
      separationCount,
      maxNumberOfSampling,
      dayOfWeek,
      weekOfMonth,
      dayOfMonth,
      duration,
    );

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addScheduledTrigger(
    String sessionId,
    String triggerName,
    int timeHour,
    int timeMinute,
    int timeSecond,
    String recurrenceFrequency,
    int? recurrenceInterval,
    String? recurrenceEndType,
    Duration? recurrenceEndElapsedTime,
    int? recurrenceEndCount,
  ) {
    final session = _getSessionOrThrow(sessionId);

    final time =
        TimeOfDay(hour: timeHour, minute: timeMinute, second: timeSecond);
    final recurrenceRule = RecurrenceRule(
      _parseRecurrenceFrequency(recurrenceFrequency),
      interval: recurrenceInterval ?? 1,
      end: _parseRecurrenceEnd(
        recurrenceEndType,
        recurrenceEndElapsedTime,
        recurrenceEndCount,
      ),
    );

    session.createScheduledTrigger(triggerName, time, recurrenceRule);

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addUserTaskTrigger(
    String sessionId,
    String triggerName,
    String taskName,
    String triggerCondition,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createUserTaskTrigger(
      triggerName,
      taskName,
      _parseUserTaskState(triggerCondition),
    );

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  Map<String, dynamic> addSamplingEventTrigger(
    String sessionId,
    String triggerName,
    String measureType,
    Map<String, dynamic>? triggerConditionJson,
  ) {
    final session = _getSessionOrThrow(sessionId);

    session.createSamplingEventTrigger(
      triggerName,
      measureType,
      _parseOptionalTriggerConditionData(triggerConditionJson),
    );

    return {
      'sessionId': sessionId,
      ...session.toRequirementsJson(),
    };
  }

  RecurrentType _parseRecurrentType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'daily':
        return RecurrentType.daily;
      case 'weekly':
        return RecurrentType.weekly;
      case 'monthly':
        return RecurrentType.monthly;
      default:
        throw ArgumentError(
          'Unsupported recurrent trigger type: $value. Use one of: daily, weekly, monthly.',
        );
    }
  }

  Frequency _parseRecurrenceFrequency(String value) {
    final normalized = value.trim().toLowerCase();
    for (final frequency in Frequency.values) {
      if (frequency.name.toLowerCase() == normalized) return frequency;
    }

    throw ArgumentError(
      'Unsupported recurrence frequency: $value. Supported values: '
      '${Frequency.values.map((entry) => entry.name.toLowerCase()).join(', ')}.',
    );
  }

  End _parseRecurrenceEnd(
    String? type,
    Duration? elapsedTime,
    int? count,
  ) {
    if (type == null) return End.never();

    final normalized = type.trim().toLowerCase();
    switch (normalized) {
      case 'until':
        if (elapsedTime == null) {
          throw ArgumentError(
            'Recurrence end type until requires elapsedTime.',
          );
        }
        if (count != null) {
          throw ArgumentError(
            'Recurrence end type until does not allow count.',
          );
        }
        return End.until(elapsedTime);
      case 'count':
        if (count == null || count <= 0) {
          throw ArgumentError(
            'Recurrence end type count requires a positive count.',
          );
        }
        if (elapsedTime != null) {
          throw ArgumentError(
            'Recurrence end type count does not allow elapsedTime.',
          );
        }
        return End.count(count);
      case 'never':
        if (elapsedTime != null || count != null) {
          throw ArgumentError(
            'Recurrence end type never does not allow elapsedTime or count.',
          );
        }
        return End.never();
      default:
        throw ArgumentError(
          'Unsupported recurrence end type: $type. Use one of: until, count, never.',
        );
    }
  }

  UserTaskState _parseUserTaskState(String value) {
    final normalized = value.trim().toLowerCase();
    for (final state in UserTaskState.values) {
      if (state.name.toLowerCase() == normalized) return state;
    }

    throw ArgumentError(
      'Unsupported triggerCondition: $value. Supported values: '
      '${UserTaskState.values.map((entry) => entry.name).join(', ')}.',
    );
  }

  Data? _parseOptionalTriggerConditionData(Map<String, dynamic>? json) {
    if (json == null) return null;

    try {
      return Data.fromJson(json);
    } catch (_) {
      throw ArgumentError(
        'Invalid triggerCondition. Use a valid serialized CARP Data object.',
      );
    }
  }

  void _validateCronField(String fieldName, int? value, int min, int max) {
    if (value == null) return;
    if (value < min || value > max) {
      throw ArgumentError(
        '$fieldName must be in the range [$min-$max] or null (= match all).',
      );
    }
  }
}
