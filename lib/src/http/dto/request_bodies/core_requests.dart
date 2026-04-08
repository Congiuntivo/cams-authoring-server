class PrimaryDeviceRequest {
  const PrimaryDeviceRequest({
    required this.deviceType,
    this.roleName,
  });

  final String deviceType;
  final String? roleName;

  factory PrimaryDeviceRequest.fromJson(Map<String, dynamic> json) {
    return PrimaryDeviceRequest(
      deviceType: (json['deviceType'] as String?)?.trim() ?? '',
      roleName: (json['roleName'] as String?)?.trim(),
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
    return DataEndpointRequest(
      endpointType: (json['endpointType'] as String?)?.trim() ?? '',
      uploadMethod: (json['uploadMethod'] as String?)?.trim(),
      name: (json['name'] as String?)?.trim(),
      deleteWhenUploaded: json['deleteWhenUploaded'] as bool?,
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
    return LocationServiceRequest(
      roleName: (json['roleName'] as String?)?.trim(),
      accuracy: (json['accuracy'] as String?)?.trim(),
      distance: (json['distance'] as num?)?.toDouble(),
      intervalSeconds: json['intervalSeconds'] as int?,
      notificationTitle: (json['notificationTitle'] as String?)?.trim(),
      notificationMessage: (json['notificationMessage'] as String?)?.trim(),
      notificationDescription:
          (json['notificationDescription'] as String?)?.trim(),
      notificationIconName: (json['notificationIconName'] as String?)?.trim(),
      notificationOnTapBringToFront:
          json['notificationOnTapBringToFront'] as bool?,
    );
  }
}
