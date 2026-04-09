import '../request_parsing_utils.dart';

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
    const context = 'e-sense device request body';

    ensureNoUnknownFields(
      json,
      const <String>{'roleName', 'isOptional', 'deviceName', 'samplingRate'},
      context,
    );

    return ESenseDeviceRequest(
      roleName: parseOptionalString(
        json['roleName'],
        'roleName',
        context: context,
      ),
      isOptional: parseOptionalBool(
        json['isOptional'],
        'isOptional',
        context: context,
      ),
      deviceName: parseOptionalString(
        json['deviceName'],
        'deviceName',
        context: context,
      ),
      samplingRate: parseOptionalInt(
        json['samplingRate'],
        'samplingRate',
        context: context,
      ),
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
    const context = 'movesense device request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'roleName',
        'isOptional',
        'name',
        'address',
        'serial',
        'deviceType',
      },
      context,
    );

    return MovesenseDeviceRequest(
      roleName: parseOptionalString(
        json['roleName'],
        'roleName',
        context: context,
      ),
      isOptional: parseOptionalBool(
        json['isOptional'],
        'isOptional',
        context: context,
      ),
      name: parseOptionalString(
        json['name'],
        'name',
        context: context,
      ),
      address: parseOptionalString(
        json['address'],
        'address',
        context: context,
      ),
      serial: parseOptionalString(
        json['serial'],
        'serial',
        context: context,
      ),
      deviceType: parseOptionalString(
        json['deviceType'],
        'deviceType',
        context: context,
      ),
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
    const context = 'movisens device request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'roleName',
        'deviceName',
        'sensorLocation',
        'sex',
        'height',
        'weight',
        'age',
      },
      context,
    );

    return MovisensDeviceRequest(
      roleName: parseOptionalString(
        json['roleName'],
        'roleName',
        context: context,
      ),
      deviceName: parseOptionalString(
            json['deviceName'],
            'deviceName',
            context: context,
          ) ??
          '',
      sensorLocation: parseOptionalString(
        json['sensorLocation'],
        'sensorLocation',
        context: context,
      ),
      sex: parseOptionalString(
        json['sex'],
        'sex',
        context: context,
      ),
      height: parseOptionalInt(
        json['height'],
        'height',
        context: context,
      ),
      weight: parseOptionalInt(
        json['weight'],
        'weight',
        context: context,
      ),
      age: parseOptionalInt(
        json['age'],
        'age',
        context: context,
      ),
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
    const context = 'polar device request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'roleName',
        'isOptional',
        'deviceType',
        'identifier',
        'name'
      },
      context,
    );

    return PolarDeviceRequest(
      roleName: parseOptionalString(
        json['roleName'],
        'roleName',
        context: context,
      ),
      isOptional: parseOptionalBool(
        json['isOptional'],
        'isOptional',
        context: context,
      ),
      deviceType: parseOptionalString(
        json['deviceType'],
        'deviceType',
        context: context,
      ),
      identifier: parseOptionalString(
        json['identifier'],
        'identifier',
        context: context,
      ),
      name: parseOptionalString(
        json['name'],
        'name',
        context: context,
      ),
    );
  }
}
