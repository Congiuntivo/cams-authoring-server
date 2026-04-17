import '../request_parsing_utils.dart';
import 'duration_request.dart';

class CreateSmartphoneProtocolRequest {
  const CreateSmartphoneProtocolRequest({
    required this.name,
    this.ownerId,
    this.protocolVersionTag,
    this.protocolApiLevel,
    this.applicationName,
    this.privacySchemaName,
  });

  final String name;
  final String? ownerId;
  final String? protocolVersionTag;
  final String? protocolApiLevel;
  final String? applicationName;
  final String? privacySchemaName;

  factory CreateSmartphoneProtocolRequest.fromJson(Map<String, dynamic> json) {
    const context = 'create smartphone protocol request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'name',
        'ownerId',
        'protocolVersionTag',
        'protocolApiLevel',
        'applicationName',
        'privacySchemaName',
      },
      context,
    );

    return CreateSmartphoneProtocolRequest(
      name: requireNonBlankString(
        json,
        'name',
        context: context,
      ),
      ownerId: parseOptionalString(
        json['ownerId'],
        'ownerId',
        context: context,
      ),
      protocolVersionTag: parseOptionalString(
        json['protocolVersionTag'],
        'protocolVersionTag',
        context: context,
      ),
      protocolApiLevel: parseOptionalString(
        json['protocolApiLevel'],
        'protocolApiLevel',
        context: context,
      ),
      applicationName: parseOptionalString(
        json['applicationName'],
        'applicationName',
        context: context,
      ),
      privacySchemaName: parseOptionalString(
        json['privacySchemaName'],
        'privacySchemaName',
        context: context,
      ),
    );
  }
}

class CreateDefaultProtocolRequest {
  const CreateDefaultProtocolRequest({
    required this.name,
    this.ownerId,
  });

  final String name;
  final String? ownerId;

  factory CreateDefaultProtocolRequest.fromJson(Map<String, dynamic> json) {
    const context = 'create default protocol request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'name',
        'ownerId',
      },
      context,
    );

    return CreateDefaultProtocolRequest(
      name: requireNonBlankString(
        json,
        'name',
        context: context,
      ),
      ownerId: parseOptionalString(
        json['ownerId'],
        'ownerId',
        context: context,
      ),
    );
  }
}

class PrimaryDeviceRequest {
  const PrimaryDeviceRequest({
    required this.deviceType,
    this.roleName,
  });

  final String deviceType;
  final String? roleName;

  factory PrimaryDeviceRequest.fromJson(Map<String, dynamic> json) {
    const context = 'primary device request body';

    ensureNoUnknownFields(
      json,
      const <String>{'deviceType', 'roleName'},
      context,
    );

    return PrimaryDeviceRequest(
      deviceType: parseOptionalString(
            json['deviceType'],
            'deviceType',
            context: context,
          ) ??
          '',
      roleName: parseOptionalString(
        json['roleName'],
        'roleName',
        context: context,
      ),
    );
  }
}

class DataEndpointRequest {
  const DataEndpointRequest({
    required this.endpointType,
    this.uploadMethod,
    this.name,
    this.deleteWhenUploaded,
    this.bufferSize,
    this.zip,
    this.encrypt,
    this.publicKey,
  });

  final String endpointType;
  final String? uploadMethod;
  final String? name;
  final bool? deleteWhenUploaded;
  final int? bufferSize;
  final bool? zip;
  final bool? encrypt;
  final String? publicKey;

  factory DataEndpointRequest.fromJson(Map<String, dynamic> json) {
    const context = 'data endpoint request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'endpointType',
        'uploadMethod',
        'name',
        'deleteWhenUploaded',
        'bufferSize',
        'zip',
        'encrypt',
        'publicKey',
      },
      context,
    );

    return DataEndpointRequest(
      endpointType: parseOptionalString(
            json['endpointType'],
            'endpointType',
            context: context,
          ) ??
          '',
      uploadMethod: parseOptionalString(
        json['uploadMethod'],
        'uploadMethod',
        context: context,
      ),
      name: parseOptionalString(
        json['name'],
        'name',
        context: context,
      ),
      deleteWhenUploaded: parseOptionalBool(
        json['deleteWhenUploaded'],
        'deleteWhenUploaded',
        context: context,
      ),
      bufferSize: parseOptionalInt(
        json['bufferSize'],
        'bufferSize',
        context: context,
      ),
      zip: parseOptionalBool(
        json['zip'],
        'zip',
        context: context,
      ),
      encrypt: parseOptionalBool(
        json['encrypt'],
        'encrypt',
        context: context,
      ),
      publicKey: parseOptionalString(
        json['publicKey'],
        'publicKey',
        context: context,
      ),
    );
  }
}

class LocationServiceRequest {
  const LocationServiceRequest({
    this.roleName,
    this.accuracy,
    this.distance,
    this.interval,
    this.notificationTitle,
    this.notificationMessage,
    this.notificationDescription,
    this.notificationIconName,
    this.notificationOnTapBringToFront,
  });

  final String? roleName;
  final String? accuracy;
  final double? distance;
  final DurationRequest? interval;
  final String? notificationTitle;
  final String? notificationMessage;
  final String? notificationDescription;
  final String? notificationIconName;
  final bool? notificationOnTapBringToFront;

  factory LocationServiceRequest.fromJson(Map<String, dynamic> json) {
    const context = 'location service request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'roleName',
        'accuracy',
        'distance',
        'interval',
        'notificationTitle',
        'notificationMessage',
        'notificationDescription',
        'notificationIconName',
        'notificationOnTapBringToFront',
      },
      context,
    );

    return LocationServiceRequest(
      roleName: parseOptionalString(
        json['roleName'],
        'roleName',
        context: context,
      ),
      accuracy: parseOptionalString(
        json['accuracy'],
        'accuracy',
        context: context,
      ),
      distance: parseOptionalDouble(
        json['distance'],
        'distance',
        context: context,
      ),
      interval: DurationRequest.fromOptionalJson(
        json['interval'],
        'interval',
        context: context,
      ),
      notificationTitle: parseOptionalString(
        json['notificationTitle'],
        'notificationTitle',
        context: context,
      ),
      notificationMessage: parseOptionalString(
        json['notificationMessage'],
        'notificationMessage',
        context: context,
      ),
      notificationDescription: parseOptionalString(
        json['notificationDescription'],
        'notificationDescription',
        context: context,
      ),
      notificationIconName: parseOptionalString(
        json['notificationIconName'],
        'notificationIconName',
        context: context,
      ),
      notificationOnTapBringToFront: parseOptionalBool(
        json['notificationOnTapBringToFront'],
        'notificationOnTapBringToFront',
        context: context,
      ),
    );
  }
}

class CronScheduledTriggerRequest {
  const CronScheduledTriggerRequest({
    required this.triggerName,
    this.minute,
    this.hour,
    this.day,
    this.month,
    this.weekday,
  });

  final String triggerName;
  final int? minute;
  final int? hour;
  final int? day;
  final int? month;
  final int? weekday;

  factory CronScheduledTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'cron trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'triggerName',
        'minute',
        'hour',
        'day',
        'month',
        'weekday',
      },
      context,
    );

    return CronScheduledTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      minute: parseOptionalInt(
        json['minute'],
        'minute',
        context: context,
      ),
      hour: parseOptionalInt(
        json['hour'],
        'hour',
        context: context,
      ),
      day: parseOptionalInt(
        json['day'],
        'day',
        context: context,
      ),
      month: parseOptionalInt(
        json['month'],
        'month',
        context: context,
      ),
      weekday: parseOptionalInt(
        json['weekday'],
        'weekday',
        context: context,
      ),
    );
  }
}

class DateTimeTriggerRequest {
  const DateTimeTriggerRequest({
    required this.triggerName,
    required this.schedule,
  });

  final String triggerName;
  final DateTime schedule;

  factory DateTimeTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'date-time trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'schedule'},
      context,
    );

    final scheduleText = requireNonBlankString(
      json,
      'schedule',
      context: context,
    );

    try {
      return DateTimeTriggerRequest(
        triggerName: requireNonBlankString(
          json,
          'triggerName',
          context: context,
        ),
        schedule: DateTime.parse(scheduleText),
      );
    } on FormatException {
      throw const FormatException(
        'Invalid schedule in date-time trigger request body. Use an ISO-8601 date-time string.',
      );
    }
  }
}

class DelayedTriggerRequest {
  const DelayedTriggerRequest({
    required this.triggerName,
    required this.delay,
  });

  final String triggerName;
  final DurationRequest delay;

  factory DelayedTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'delayed trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'delay'},
      context,
    );

    final rawDelay = json['delay'];
    if (rawDelay is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid delay in delayed trigger request body. Use an object.',
      );
    }

    return DelayedTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      delay: DurationRequest.fromJson(
        rawDelay,
        context: 'delay in delayed trigger request body',
      ),
    );
  }
}

class ElapsedTimeTriggerRequest {
  const ElapsedTimeTriggerRequest({
    required this.triggerName,
    required this.elapsedTime,
  });

  final String triggerName;
  final DurationRequest elapsedTime;

  factory ElapsedTimeTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'elapsed-time trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'elapsedTime'},
      context,
    );

    final rawElapsedTime = json['elapsedTime'];
    if (rawElapsedTime is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid elapsedTime in elapsed-time trigger request body. Use an object.',
      );
    }

    return ElapsedTimeTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      elapsedTime: DurationRequest.fromJson(
        rawElapsedTime,
        context: 'elapsedTime in elapsed-time trigger request body',
      ),
    );
  }
}

class ImmediateTriggerRequest {
  const ImmediateTriggerRequest({required this.triggerName});

  final String triggerName;

  factory ImmediateTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'immediate trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName'},
      context,
    );

    return ImmediateTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
    );
  }
}

class ManualTriggerRequest {
  const ManualTriggerRequest({
    required this.triggerName,
    this.label,
    this.description,
  });

  final String triggerName;
  final String? label;
  final String? description;

  factory ManualTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'manual trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'label', 'description'},
      context,
    );

    return ManualTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      label: parseOptionalString(
        json['label'],
        'label',
        context: context,
      ),
      description: parseOptionalString(
        json['description'],
        'description',
        context: context,
      ),
    );
  }
}

class NoOpTriggerRequest {
  const NoOpTriggerRequest({required this.triggerName});

  final String triggerName;

  factory NoOpTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'no-op trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName'},
      context,
    );

    return NoOpTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
    );
  }
}

class NoUserTaskTriggerRequest {
  const NoUserTaskTriggerRequest({
    required this.triggerName,
    required this.taskName,
  });

  final String triggerName;
  final String taskName;

  factory NoUserTaskTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'no-user-task trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'taskName'},
      context,
    );

    return NoUserTaskTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      taskName: requireNonBlankString(
        json,
        'taskName',
        context: context,
      ),
    );
  }
}

class OneTimeTriggerRequest {
  const OneTimeTriggerRequest({required this.triggerName});

  final String triggerName;

  factory OneTimeTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'one-time trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName'},
      context,
    );

    return OneTimeTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
    );
  }
}

class PassiveTriggerRequest {
  const PassiveTriggerRequest({required this.triggerName});

  final String triggerName;

  factory PassiveTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'passive trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName'},
      context,
    );

    return PassiveTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
    );
  }
}

class PeriodicTriggerRequest {
  const PeriodicTriggerRequest({
    required this.triggerName,
    required this.period,
  });

  final String triggerName;
  final DurationRequest period;

  factory PeriodicTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'periodic trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'period'},
      context,
    );

    final rawPeriod = json['period'];
    if (rawPeriod is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid period in periodic trigger request body. Use an object.',
      );
    }

    return PeriodicTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      period: DurationRequest.fromJson(
        rawPeriod,
        context: 'period in periodic trigger request body',
      ),
    );
  }
}

class TimeOfDayRequest {
  const TimeOfDayRequest({
    required this.hour,
    required this.minute,
    this.second,
  });

  final int hour;
  final int minute;
  final int? second;

  factory TimeOfDayRequest.fromJson(
    Map<String, dynamic> json, {
    required String context,
  }) {
    ensureNoUnknownFields(
      json,
      const <String>{'hour', 'minute', 'second'},
      context,
    );

    final hour = parseOptionalInt(json['hour'], 'hour', context: context);
    final minute = parseOptionalInt(json['minute'], 'minute', context: context);
    final second = parseOptionalInt(json['second'], 'second', context: context);

    if (hour == null || hour < 0 || hour > 23) {
      throw FormatException(
        'Invalid hour in $context. Use an integer in the range [0-23].',
      );
    }
    if (minute == null || minute < 0 || minute > 59) {
      throw FormatException(
        'Invalid minute in $context. Use an integer in the range [0-59].',
      );
    }
    if (second != null && (second < 0 || second > 59)) {
      throw FormatException(
        'Invalid second in $context. Use an integer in the range [0-59].',
      );
    }

    return TimeOfDayRequest(
      hour: hour,
      minute: minute,
      second: second,
    );
  }
}

class RandomRecurrentTriggerRequest {
  const RandomRecurrentTriggerRequest({
    required this.triggerName,
    required this.minNumberOfTriggers,
    required this.maxNumberOfTriggers,
    required this.startTime,
    required this.endTime,
  });

  final String triggerName;
  final int minNumberOfTriggers;
  final int maxNumberOfTriggers;
  final TimeOfDayRequest startTime;
  final TimeOfDayRequest endTime;

  factory RandomRecurrentTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'random recurrent trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'triggerName',
        'minNumberOfTriggers',
        'maxNumberOfTriggers',
        'startTime',
        'endTime',
      },
      context,
    );

    final minTriggers = parseOptionalInt(
      json['minNumberOfTriggers'],
      'minNumberOfTriggers',
      context: context,
    );
    final maxTriggers = parseOptionalInt(
      json['maxNumberOfTriggers'],
      'maxNumberOfTriggers',
      context: context,
    );

    if (minTriggers == null || minTriggers < 0) {
      throw const FormatException(
        'Invalid minNumberOfTriggers in random recurrent trigger request body. Use a non-negative integer.',
      );
    }
    if (maxTriggers == null || maxTriggers < 0) {
      throw const FormatException(
        'Invalid maxNumberOfTriggers in random recurrent trigger request body. Use a non-negative integer.',
      );
    }

    final rawStartTime = json['startTime'];
    if (rawStartTime is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid startTime in random recurrent trigger request body. Use an object.',
      );
    }

    final rawEndTime = json['endTime'];
    if (rawEndTime is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid endTime in random recurrent trigger request body. Use an object.',
      );
    }

    return RandomRecurrentTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      minNumberOfTriggers: minTriggers,
      maxNumberOfTriggers: maxTriggers,
      startTime: TimeOfDayRequest.fromJson(
        rawStartTime,
        context: 'startTime in random recurrent trigger request body',
      ),
      endTime: TimeOfDayRequest.fromJson(
        rawEndTime,
        context: 'endTime in random recurrent trigger request body',
      ),
    );
  }
}

class RecurrentScheduledTriggerRequest {
  const RecurrentScheduledTriggerRequest({
    required this.triggerName,
    required this.type,
    required this.time,
    this.end,
    this.separationCount,
    this.maxNumberOfSampling,
    this.dayOfWeek,
    this.weekOfMonth,
    this.dayOfMonth,
    this.duration,
  });

  final String triggerName;
  final String type;
  final TimeOfDayRequest time;
  final DateTime? end;
  final int? separationCount;
  final int? maxNumberOfSampling;
  final int? dayOfWeek;
  final int? weekOfMonth;
  final int? dayOfMonth;
  final DurationRequest? duration;

  factory RecurrentScheduledTriggerRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'recurrent scheduled trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'triggerName',
        'type',
        'time',
        'end',
        'separationCount',
        'maxNumberOfSampling',
        'dayOfWeek',
        'weekOfMonth',
        'dayOfMonth',
        'duration',
      },
      context,
    );

    final rawTime = json['time'];
    if (rawTime is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid time in recurrent scheduled trigger request body. Use an object.',
      );
    }

    final endText = parseOptionalString(
      json['end'],
      'end',
      context: context,
    );
    DateTime? end;
    if (endText != null) {
      try {
        end = DateTime.parse(endText);
      } on FormatException {
        throw const FormatException(
          'Invalid end in recurrent scheduled trigger request body. Use an ISO-8601 date-time string.',
        );
      }
    }

    final separationCount = parseOptionalInt(
      json['separationCount'],
      'separationCount',
      context: context,
    );
    final maxNumberOfSampling = parseOptionalInt(
      json['maxNumberOfSampling'],
      'maxNumberOfSampling',
      context: context,
    );
    final dayOfWeek = parseOptionalInt(
      json['dayOfWeek'],
      'dayOfWeek',
      context: context,
    );
    final weekOfMonth = parseOptionalInt(
      json['weekOfMonth'],
      'weekOfMonth',
      context: context,
    );
    final dayOfMonth = parseOptionalInt(
      json['dayOfMonth'],
      'dayOfMonth',
      context: context,
    );

    if (separationCount != null && separationCount < 0) {
      throw const FormatException(
        'Invalid separationCount in recurrent scheduled trigger request body. Use a non-negative integer.',
      );
    }
    if (maxNumberOfSampling != null && maxNumberOfSampling < 0) {
      throw const FormatException(
        'Invalid maxNumberOfSampling in recurrent scheduled trigger request body. Use a non-negative integer.',
      );
    }
    if (dayOfWeek != null && (dayOfWeek < 1 || dayOfWeek > 7)) {
      throw const FormatException(
        'Invalid dayOfWeek in recurrent scheduled trigger request body. Use an integer in the range [1-7].',
      );
    }
    if (weekOfMonth != null && (weekOfMonth < 1 || weekOfMonth > 4)) {
      throw const FormatException(
        'Invalid weekOfMonth in recurrent scheduled trigger request body. Use an integer in the range [1-4].',
      );
    }
    if (dayOfMonth != null && (dayOfMonth < 1 || dayOfMonth > 31)) {
      throw const FormatException(
        'Invalid dayOfMonth in recurrent scheduled trigger request body. Use an integer in the range [1-31].',
      );
    }

    return RecurrentScheduledTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      type: requireNonBlankString(
        json,
        'type',
        context: context,
      ),
      time: TimeOfDayRequest.fromJson(
        rawTime,
        context: 'time in recurrent scheduled trigger request body',
      ),
      end: end,
      separationCount: separationCount,
      maxNumberOfSampling: maxNumberOfSampling,
      dayOfWeek: dayOfWeek,
      weekOfMonth: weekOfMonth,
      dayOfMonth: dayOfMonth,
      duration: DurationRequest.fromOptionalJson(
        json['duration'],
        'duration',
        context: context,
      ),
    );
  }
}

class RecurrenceEndRequest {
  const RecurrenceEndRequest({
    required this.type,
    this.elapsedTime,
    this.count,
  });

  final String type;
  final DurationRequest? elapsedTime;
  final int? count;

  factory RecurrenceEndRequest.fromJson(
    Map<String, dynamic> json, {
    required String context,
  }) {
    ensureNoUnknownFields(
      json,
      const <String>{'type', 'elapsedTime', 'count'},
      context,
    );

    final type = requireNonBlankString(
      json,
      'type',
      context: context,
    ).toLowerCase();

    final elapsedTime = DurationRequest.fromOptionalJson(
      json['elapsedTime'],
      'elapsedTime',
      context: context,
    );
    final count = parseOptionalInt(
      json['count'],
      'count',
      context: context,
    );

    switch (type) {
      case 'until':
        if (elapsedTime == null) {
          throw FormatException(
            'Invalid elapsedTime in $context. Required when type is until.',
          );
        }
        if (count != null) {
          throw FormatException(
            'Invalid count in $context. Omit count when type is until.',
          );
        }
        break;
      case 'count':
        if (count == null || count <= 0) {
          throw FormatException(
            'Invalid count in $context. Use a positive integer when type is count.',
          );
        }
        if (elapsedTime != null) {
          throw FormatException(
            'Invalid elapsedTime in $context. Omit elapsedTime when type is count.',
          );
        }
        break;
      case 'never':
        if (elapsedTime != null || count != null) {
          throw FormatException(
            'Invalid end fields in $context. Omit elapsedTime and count when type is never.',
          );
        }
        break;
      default:
        throw FormatException(
          'Invalid type in $context. Use one of: until, count, never.',
        );
    }

    return RecurrenceEndRequest(
      type: type,
      elapsedTime: elapsedTime,
      count: count,
    );
  }
}

class RecurrenceRuleRequest {
  const RecurrenceRuleRequest({
    required this.frequency,
    this.interval,
    this.end,
  });

  final String frequency;
  final int? interval;
  final RecurrenceEndRequest? end;

  factory RecurrenceRuleRequest.fromJson(
    Map<String, dynamic> json, {
    required String context,
  }) {
    ensureNoUnknownFields(
      json,
      const <String>{'frequency', 'interval', 'end'},
      context,
    );

    final interval = parseOptionalInt(
      json['interval'],
      'interval',
      context: context,
    );
    if (interval != null && interval <= 0) {
      throw FormatException(
        'Invalid interval in $context. Use a positive integer.',
      );
    }

    final rawEnd = json['end'];
    RecurrenceEndRequest? end;
    if (rawEnd != null) {
      if (rawEnd is! Map<String, dynamic>) {
        throw FormatException(
          'Invalid end in $context. Use an object.',
        );
      }
      end = RecurrenceEndRequest.fromJson(
        rawEnd,
        context: 'end in $context',
      );
    }

    return RecurrenceRuleRequest(
      frequency: requireNonBlankString(
        json,
        'frequency',
        context: context,
      ),
      interval: interval,
      end: end,
    );
  }
}

class ScheduledTriggerRequest {
  const ScheduledTriggerRequest({
    required this.triggerName,
    required this.time,
    required this.recurrenceRule,
  });

  final String triggerName;
  final TimeOfDayRequest time;
  final RecurrenceRuleRequest recurrenceRule;

  factory ScheduledTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'scheduled trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'time', 'recurrenceRule'},
      context,
    );

    final rawTime = json['time'];
    if (rawTime is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid time in scheduled trigger request body. Use an object.',
      );
    }

    final rawRecurrenceRule = json['recurrenceRule'];
    if (rawRecurrenceRule is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid recurrenceRule in scheduled trigger request body. Use an object.',
      );
    }

    return ScheduledTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      time: TimeOfDayRequest.fromJson(
        rawTime,
        context: 'time in scheduled trigger request body',
      ),
      recurrenceRule: RecurrenceRuleRequest.fromJson(
        rawRecurrenceRule,
        context: 'recurrenceRule in scheduled trigger request body',
      ),
    );
  }
}

class UserTaskTriggerRequest {
  const UserTaskTriggerRequest({
    required this.triggerName,
    required this.taskName,
    required this.triggerCondition,
  });

  final String triggerName;
  final String taskName;
  final String triggerCondition;

  factory UserTaskTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'user-task trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'taskName', 'triggerCondition'},
      context,
    );

    return UserTaskTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      taskName: requireNonBlankString(
        json,
        'taskName',
        context: context,
      ),
      triggerCondition: requireNonBlankString(
        json,
        'triggerCondition',
        context: context,
      ),
    );
  }
}

class SamplingEventTriggerRequest {
  const SamplingEventTriggerRequest({
    required this.triggerName,
    required this.measureType,
    this.triggerCondition,
  });

  final String triggerName;
  final String measureType;
  final Map<String, dynamic>? triggerCondition;

  factory SamplingEventTriggerRequest.fromJson(Map<String, dynamic> json) {
    const context = 'sampling-event trigger request body';

    ensureNoUnknownFields(
      json,
      const <String>{'triggerName', 'measureType', 'triggerCondition'},
      context,
    );

    final rawTriggerCondition = json['triggerCondition'];
    Map<String, dynamic>? triggerCondition;
    if (rawTriggerCondition != null) {
      if (rawTriggerCondition is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid triggerCondition in sampling-event trigger request body. Use an object.',
        );
      }
      triggerCondition = rawTriggerCondition;
    }

    return SamplingEventTriggerRequest(
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      measureType: requireNonBlankString(
        json,
        'measureType',
        context: context,
      ),
      triggerCondition: triggerCondition,
    );
  }
}
