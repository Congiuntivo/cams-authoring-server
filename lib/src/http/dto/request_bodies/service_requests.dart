import '../request_parsing_utils.dart';
import 'duration_request.dart';

class WeatherServiceRequest {
  const WeatherServiceRequest({
    this.roleName,
    this.primaryDeviceRoleName,
  });

  final String? roleName;
  final String? primaryDeviceRoleName;

  factory WeatherServiceRequest.fromJson(Map<String, dynamic> json) {
    const context = 'weather service request body';

    ensureNoUnknownFields(
      json,
      const <String>{'roleName', 'primaryDeviceRoleName'},
      context,
    );

    return WeatherServiceRequest(
      roleName:
          parseOptionalString(json['roleName'], 'roleName', context: context),
      primaryDeviceRoleName: parseOptionalString(
          json['primaryDeviceRoleName'], 'primaryDeviceRoleName',
          context: context),
    );
  }
}

class AirQualityServiceRequest {
  const AirQualityServiceRequest({
    this.roleName,
    this.primaryDeviceRoleName,
  });

  final String? roleName;
  final String? primaryDeviceRoleName;

  factory AirQualityServiceRequest.fromJson(Map<String, dynamic> json) {
    const context = 'air quality service request body';

    ensureNoUnknownFields(
      json,
      const <String>{'roleName', 'primaryDeviceRoleName'},
      context,
    );

    return AirQualityServiceRequest(
      roleName:
          parseOptionalString(json['roleName'], 'roleName', context: context),
      primaryDeviceRoleName: parseOptionalString(
          json['primaryDeviceRoleName'], 'primaryDeviceRoleName',
          context: context),
    );
  }
}

class HealthServiceRequest {
  const HealthServiceRequest({
    this.roleName,
    this.primaryDeviceRoleName,
  });

  final String? roleName;
  final String? primaryDeviceRoleName;

  factory HealthServiceRequest.fromJson(Map<String, dynamic> json) {
    const context = 'health service request body';

    ensureNoUnknownFields(
      json,
      const <String>{'roleName', 'primaryDeviceRoleName'},
      context,
    );

    return HealthServiceRequest(
      roleName:
          parseOptionalString(json['roleName'], 'roleName', context: context),
      primaryDeviceRoleName: parseOptionalString(
          json['primaryDeviceRoleName'], 'primaryDeviceRoleName',
          context: context),
    );
  }
}

class LocationServiceRequest {
  const LocationServiceRequest({
    this.roleName,
    this.primaryDeviceRoleName,
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
  final String? primaryDeviceRoleName;
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
        'primaryDeviceRoleName',
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
      primaryDeviceRoleName: parseOptionalString(
        json['primaryDeviceRoleName'],
        'primaryDeviceRoleName',
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
