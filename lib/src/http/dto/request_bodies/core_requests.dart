import '../request_parsing_utils.dart';

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
    this.intervalSeconds,
    this.notificationTitle,
    this.notificationMessage,
    this.notificationDescription,
    this.notificationIconName,
    this.notificationOnTapBringToFront,
  });

  final String? roleName;
  final String? accuracy;
  final double? distance;
  final int? intervalSeconds;
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
        'intervalSeconds',
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
      intervalSeconds: parseOptionalInt(
        json['intervalSeconds'],
        'intervalSeconds',
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
