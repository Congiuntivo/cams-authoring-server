class ESenseDeviceRequest {
  const ESenseDeviceRequest({
    this.roleName,
    this.isOptional,
    this.deviceName,
    this.samplingRate,
  });

  final String? roleName;
  final bool? isOptional;
  final String? deviceName;
  final int? samplingRate;

  factory ESenseDeviceRequest.fromJson(Map<String, dynamic> json) {
    return ESenseDeviceRequest(
      roleName: (json['roleName'] as String?)?.trim(),
      isOptional: json['isOptional'] as bool?,
      deviceName: (json['deviceName'] as String?)?.trim(),
      samplingRate: json['samplingRate'] as int?,
    );
  }
}

class MovesenseDeviceRequest {
  const MovesenseDeviceRequest({
    this.roleName,
    this.isOptional,
    this.name,
    this.address,
    this.serial,
    this.deviceType,
  });

  final String? roleName;
  final bool? isOptional;
  final String? name;
  final String? address;
  final String? serial;
  final String? deviceType;

  factory MovesenseDeviceRequest.fromJson(Map<String, dynamic> json) {
    return MovesenseDeviceRequest(
      roleName: (json['roleName'] as String?)?.trim(),
      isOptional: json['isOptional'] as bool?,
      name: (json['name'] as String?)?.trim(),
      address: (json['address'] as String?)?.trim(),
      serial: (json['serial'] as String?)?.trim(),
      deviceType: (json['deviceType'] as String?)?.trim(),
    );
  }
}

class MovisensDeviceRequest {
  const MovisensDeviceRequest({
    this.roleName,
    required this.deviceName,
    this.sensorLocation,
    this.sex,
    this.height,
    this.weight,
    this.age,
  });

  final String? roleName;
  final String deviceName;
  final String? sensorLocation;
  final String? sex;
  final int? height;
  final int? weight;
  final int? age;

  factory MovisensDeviceRequest.fromJson(Map<String, dynamic> json) {
    return MovisensDeviceRequest(
      roleName: (json['roleName'] as String?)?.trim(),
      deviceName: (json['deviceName'] as String?)?.trim() ?? '',
      sensorLocation: (json['sensorLocation'] as String?)?.trim(),
      sex: (json['sex'] as String?)?.trim(),
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      age: json['age'] as int?,
    );
  }
}

class PolarDeviceRequest {
  const PolarDeviceRequest({
    this.roleName,
    this.isOptional,
    this.deviceType,
    this.identifier,
    this.name,
  });

  final String? roleName;
  final bool? isOptional;
  final String? deviceType;
  final String? identifier;
  final String? name;

  factory PolarDeviceRequest.fromJson(Map<String, dynamic> json) {
    return PolarDeviceRequest(
      roleName: (json['roleName'] as String?)?.trim(),
      isOptional: json['isOptional'] as bool?,
      deviceType: (json['deviceType'] as String?)?.trim(),
      identifier: (json['identifier'] as String?)?.trim(),
      name: (json['name'] as String?)?.trim(),
    );
  }
}
