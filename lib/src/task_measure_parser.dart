import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_movesense_package/carp_movesense_package.dart';
import 'package:carp_polar_package/carp_polar_package.dart';

class TaskMeasureInput {
  const TaskMeasureInput({
    required this.measureType,
    this.samplingConfiguration,
  });

  final String measureType;
  final TaskSamplingInput? samplingConfiguration;
}

class TaskSamplingInput {
  const TaskSamplingInput({
    required this.samplingType,
    this.intervalSeconds,
    this.durationSeconds,
    this.once,
    this.usePriorContexts,
    this.stopRadius,
    this.placeRadius,
    this.stopDurationSeconds,
  });

  final String samplingType;
  final int? intervalSeconds;
  final int? durationSeconds;
  final bool? once;
  final bool? usePriorContexts;
  final double? stopRadius;
  final double? placeRadius;
  final int? stopDurationSeconds;
}

class TaskMeasurePolicy {
  const TaskMeasurePolicy({
    required this.supportedMeasureTypes,
    this.supportedSamplingTypes =
        TaskMeasureParser.defaultSupportedSamplingTypes,
    this.intervalSamplingMeasureTypes = const <String>{},
    this.periodicSamplingMeasureTypes = const <String>{},
    this.locationSamplingMeasureTypes = const <String>{},
    this.mobilitySamplingMeasureTypes = const <String>{},
  });

  final Set<String> supportedMeasureTypes;
  final Set<String> supportedSamplingTypes;
  final Set<String> intervalSamplingMeasureTypes;
  final Set<String> periodicSamplingMeasureTypes;
  final Set<String> locationSamplingMeasureTypes;
  final Set<String> mobilitySamplingMeasureTypes;
}

const TaskMeasurePolicy backgroundTaskMeasurePolicy = TaskMeasurePolicy(
  supportedMeasureTypes: <String>{
    DeviceSamplingPackage.DEVICE_INFORMATION,
    DeviceSamplingPackage.FREE_MEMORY,
    DeviceSamplingPackage.BATTERY_STATE,
    DeviceSamplingPackage.SCREEN_EVENT,
    DeviceSamplingPackage.TIMEZONE,
    SensorSamplingPackage.ACCELERATION,
    SensorSamplingPackage.NON_GRAVITATIONAL_ACCELERATION,
    SensorSamplingPackage.ACCELERATION_FEATURES,
    SensorSamplingPackage.ROTATION,
    SensorSamplingPackage.MAGNETIC_FIELD,
    SensorSamplingPackage.AMBIENT_LIGHT,
    SensorSamplingPackage.STEP_COUNT,
    ContextSamplingPackage.ACTIVITY,
    ContextSamplingPackage.LOCATION,
    ContextSamplingPackage.GEOFENCE,
    ContextSamplingPackage.MOBILITY,
    ContextSamplingPackage.AIR_QUALITY,
    ContextSamplingPackage.WEATHER,
    PolarSamplingPackage.ACCELEROMETER,
    PolarSamplingPackage.GYROSCOPE,
    PolarSamplingPackage.MAGNETOMETER,
    PolarSamplingPackage.PPG,
    PolarSamplingPackage.PPI,
    PolarSamplingPackage.ECG,
    PolarSamplingPackage.HR,
    MovesenseSamplingPackage.DEVICE_INFO,
    MovesenseSamplingPackage.STATE,
    MovesenseSamplingPackage.HR,
    MovesenseSamplingPackage.ECG,
    MovesenseSamplingPackage.TEMPERATURE,
    MovesenseSamplingPackage.IMU,
  },
  intervalSamplingMeasureTypes: <String>{
    DeviceSamplingPackage.FREE_MEMORY,
    SensorSamplingPackage.ACCELERATION,
    SensorSamplingPackage.NON_GRAVITATIONAL_ACCELERATION,
    SensorSamplingPackage.ROTATION,
    SensorSamplingPackage.MAGNETIC_FIELD,
  },
  periodicSamplingMeasureTypes: <String>{
    SensorSamplingPackage.ACCELERATION_FEATURES,
    SensorSamplingPackage.AMBIENT_LIGHT,
  },
  locationSamplingMeasureTypes: <String>{
    ContextSamplingPackage.LOCATION,
  },
  mobilitySamplingMeasureTypes: <String>{
    ContextSamplingPackage.MOBILITY,
  },
);

class TaskMeasureParser {
  static const Set<String> defaultSupportedSamplingTypes = <String>{
    'none',
    'interval',
    'periodic',
    'location',
    'mobility',
  };

  List<Measure> parseMeasures(
    List<TaskMeasureInput> measures, {
    required TaskMeasurePolicy policy,
  }) {
    if (measures.isEmpty) {
      throw ArgumentError(
        'Missing measures. Provide a non-empty measures array in request body.',
      );
    }

    return measures
        .map((measure) => _parseMeasure(measure, policy))
        .toList(growable: false);
  }

  Measure _parseMeasure(
    TaskMeasureInput input,
    TaskMeasurePolicy policy,
  ) {
    final measureType = input.measureType.trim();
    if (measureType.isEmpty) {
      throw ArgumentError(
        'Invalid measureType. Use a non-empty string value.',
      );
    }

    if (!policy.supportedMeasureTypes.contains(measureType)) {
      final supported = policy.supportedMeasureTypes.toList()..sort();
      throw ArgumentError(
        'Unsupported measureType: $measureType. Supported values: ${supported.join(', ')}.',
      );
    }

    final samplingConfiguration = _parseSamplingConfiguration(
      measureType,
      input.samplingConfiguration,
      policy,
    );

    return Measure(
      type: measureType,
      samplingConfiguration: samplingConfiguration,
    );
  }

  SamplingConfiguration? _parseSamplingConfiguration(
    String measureType,
    TaskSamplingInput? samplingInput,
    TaskMeasurePolicy policy,
  ) {
    if (samplingInput == null) return null;

    final samplingType = samplingInput.samplingType.trim().toLowerCase();
    if (!policy.supportedSamplingTypes.contains(samplingType)) {
      final supportedSamplingTypes = policy.supportedSamplingTypes.toList()
        ..sort();
      throw ArgumentError(
        'Unsupported samplingType: ${samplingInput.samplingType}. Supported values: ${supportedSamplingTypes.join(', ')}.',
      );
    }

    return switch (samplingType) {
      'none' => NoOptionsSamplingConfiguration(),
      'interval' => _parseIntervalSampling(measureType, samplingInput, policy),
      'periodic' => _parsePeriodicSampling(measureType, samplingInput, policy),
      'location' => _parseLocationSampling(measureType, samplingInput, policy),
      'mobility' => _parseMobilitySampling(measureType, samplingInput, policy),
      _ => throw StateError('Unsupported samplingType: $samplingType.'),
    };
  }

  SamplingConfiguration _parseIntervalSampling(
    String measureType,
    TaskSamplingInput samplingInput,
    TaskMeasurePolicy policy,
  ) {
    if (!policy.intervalSamplingMeasureTypes.contains(measureType)) {
      throw ArgumentError(
        'samplingType interval is not supported for measureType: $measureType.',
      );
    }

    final intervalSeconds = samplingInput.intervalSeconds;
    if (intervalSeconds == null || intervalSeconds <= 0) {
      throw ArgumentError(
        'Invalid intervalSeconds for interval sampling. Use a positive integer.',
      );
    }

    return IntervalSamplingConfiguration(
      interval: Duration(seconds: intervalSeconds),
    );
  }

  SamplingConfiguration _parsePeriodicSampling(
    String measureType,
    TaskSamplingInput samplingInput,
    TaskMeasurePolicy policy,
  ) {
    if (!policy.periodicSamplingMeasureTypes.contains(measureType)) {
      throw ArgumentError(
        'samplingType periodic is not supported for measureType: $measureType.',
      );
    }

    final intervalSeconds = samplingInput.intervalSeconds;
    final durationSeconds = samplingInput.durationSeconds;

    if (intervalSeconds == null || intervalSeconds <= 0) {
      throw ArgumentError(
        'Invalid intervalSeconds for periodic sampling. Use a positive integer.',
      );
    }
    if (durationSeconds == null || durationSeconds <= 0) {
      throw ArgumentError(
        'Invalid durationSeconds for periodic sampling. Use a positive integer.',
      );
    }

    return PeriodicSamplingConfiguration(
      interval: Duration(seconds: intervalSeconds),
      duration: Duration(seconds: durationSeconds),
    );
  }

  SamplingConfiguration _parseLocationSampling(
    String measureType,
    TaskSamplingInput samplingInput,
    TaskMeasurePolicy policy,
  ) {
    if (!policy.locationSamplingMeasureTypes.contains(measureType)) {
      throw ArgumentError(
        'samplingType location is not supported for measureType: $measureType.',
      );
    }

    return LocationSamplingConfiguration(
      once: samplingInput.once ?? false,
    );
  }

  SamplingConfiguration _parseMobilitySampling(
    String measureType,
    TaskSamplingInput samplingInput,
    TaskMeasurePolicy policy,
  ) {
    if (!policy.mobilitySamplingMeasureTypes.contains(measureType)) {
      throw ArgumentError(
        'samplingType mobility is not supported for measureType: $measureType.',
      );
    }

    final stopRadius = samplingInput.stopRadius;
    if (stopRadius != null && stopRadius <= 0) {
      throw ArgumentError(
        'Invalid stopRadius for mobility sampling. Use a positive number.',
      );
    }

    final placeRadius = samplingInput.placeRadius;
    if (placeRadius != null && placeRadius <= 0) {
      throw ArgumentError(
        'Invalid placeRadius for mobility sampling. Use a positive number.',
      );
    }

    final stopDurationSeconds = samplingInput.stopDurationSeconds;
    if (stopDurationSeconds != null && stopDurationSeconds <= 0) {
      throw ArgumentError(
        'Invalid stopDurationSeconds for mobility sampling. Use a positive integer.',
      );
    }

    return MobilitySamplingConfiguration(
      usePriorContexts: samplingInput.usePriorContexts ?? true,
      stopRadius: stopRadius ?? 25,
      placeRadius: placeRadius ?? 50,
      stopDuration: stopDurationSeconds == null
          ? const Duration(seconds: 30)
          : Duration(seconds: stopDurationSeconds),
    );
  }
}
