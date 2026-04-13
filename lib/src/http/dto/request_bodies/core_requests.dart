import '../request_parsing_utils.dart';
import 'duration_request.dart';

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
  });

  final String endpointType;
  final String? uploadMethod;
  final String? name;
  final bool? deleteWhenUploaded;

  factory DataEndpointRequest.fromJson(Map<String, dynamic> json) {
    const context = 'data endpoint request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'endpointType',
        'uploadMethod',
        'name',
        'deleteWhenUploaded',
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
