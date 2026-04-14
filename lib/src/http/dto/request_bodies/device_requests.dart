import '../request_parsing_utils.dart';

class ESenseDeviceRequest {
  const ESenseDeviceRequest({
    this.roleName,
    this.isOptional,
    this.samplingRate,
  });

  final String? roleName;
  final bool? isOptional;
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
  });

  final String? roleName;
  final bool? isOptional;

  factory MovesenseDeviceRequest.fromJson(Map<String, dynamic> json) {
    const context = 'movesense device request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'roleName',
        'isOptional',
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
    );
  }
}

class MovisensDeviceRequest {
  const MovisensDeviceRequest({
    this.roleName,
    this.sensorLocation,
    this.sex,
    this.height,
    this.weight,
    this.age,
  });

  final String? roleName;
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
    this.namePrefix,
  });

  final String? roleName;
  final bool? isOptional;
  final String? namePrefix;

  factory PolarDeviceRequest.fromJson(Map<String, dynamic> json) {
    const context = 'polar device request body';

    ensureNoUnknownFields(
      json,
      const <String>{'roleName', 'isOptional', 'namePrefix'},
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
      namePrefix: parseOptionalString(
        json['namePrefix'],
        'namePrefix',
        context: context,
      ),
    );
  }
}
