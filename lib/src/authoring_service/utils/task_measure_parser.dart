import 'package:carp_apps_package/apps.dart';
import 'package:carp_audio_package/media.dart';
import 'package:carp_communication_package/communication.dart';
import 'package:carp_connectivity_package/connectivity.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_esense_package/esense.dart';
import 'package:carp_health_package/health_package.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_movesense_package/carp_movesense_package.dart';
import 'package:carp_movisens_package/carp_movisens_package.dart';
import 'package:carp_polar_package/carp_polar_package.dart';
import 'package:health/health.dart';

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
    this.interval,
    this.duration,
    this.once,
    this.usePriorContexts,
    this.stopRadius,
    this.placeRadius,
    this.stopDuration,
    this.healthDataTypes,
    this.days,
  });

  final String samplingType;
  final Duration? interval;
  final Duration? duration;
  final bool? once;
  final bool? usePriorContexts;
  final double? stopRadius;
  final double? placeRadius;
  final Duration? stopDuration;
  final List<String>? healthDataTypes;
  final int? days;
}

const List<String> kSupportedMeasureTypes = <String>[
  SensorSamplingPackage.ACCELERATION,
  SensorSamplingPackage.ACCELERATION_FEATURES,
  ContextSamplingPackage.ACTIVITY,
  ContextSamplingPackage.AIR_QUALITY,
  SensorSamplingPackage.AMBIENT_LIGHT,
  AppsSamplingPackage.APPS,
  AppsSamplingPackage.APP_USAGE,
  MediaSamplingPackage.AUDIO,
  DeviceSamplingPackage.BATTERY_STATE,
  ConnectivitySamplingPackage.BEACON,
  ConnectivitySamplingPackage.BLUETOOTH,
  CommunicationSamplingPackage.CALENDAR,
  ConnectivitySamplingPackage.CONNECTIVITY,
  DeviceSamplingPackage.DEVICE_INFORMATION,
  ESenseSamplingPackage.ESENSE_BUTTON,
  ESenseSamplingPackage.ESENSE_SENSOR,
  DeviceSamplingPackage.FREE_MEMORY,
  ContextSamplingPackage.GEOFENCE,
  HealthSamplingPackage.HEALTH,
  MediaSamplingPackage.IMAGE,
  ContextSamplingPackage.LOCATION,
  SensorSamplingPackage.MAGNETIC_FIELD,
  ContextSamplingPackage.MOBILITY,
  MovesenseSamplingPackage.DEVICE_INFO,
  MovesenseSamplingPackage.ECG,
  MovesenseSamplingPackage.HR,
  MovesenseSamplingPackage.IMU,
  MovesenseSamplingPackage.STATE,
  MovesenseSamplingPackage.TEMPERATURE,
  MovisensSamplingPackage.ACTIVITY,
  MovisensSamplingPackage.EDA,
  MovisensSamplingPackage.HR,
  MovisensSamplingPackage.RESPIRATION,
  MovisensSamplingPackage.SKIN_TEMPERATURE,
  MovisensSamplingPackage.TAP_MARKER,
  MediaSamplingPackage.NOISE,
  SensorSamplingPackage.NON_GRAVITATIONAL_ACCELERATION,
  CommunicationSamplingPackage.PHONE_LOG,
  PolarSamplingPackage.ACCELEROMETER,
  PolarSamplingPackage.ECG,
  PolarSamplingPackage.GYROSCOPE,
  PolarSamplingPackage.HR,
  PolarSamplingPackage.MAGNETOMETER,
  PolarSamplingPackage.PPG,
  PolarSamplingPackage.PPI,
  SensorSamplingPackage.ROTATION,
  DeviceSamplingPackage.SCREEN_EVENT,
  SensorSamplingPackage.STEP_EVENT,
  CommunicationSamplingPackage.TEXT_MESSAGE,
  CommunicationSamplingPackage.TEXT_MESSAGE_LOG,
  DeviceSamplingPackage.TIMEZONE,
  MediaSamplingPackage.VIDEO,
  ContextSamplingPackage.WEATHER,
  ConnectivitySamplingPackage.WIFI,
];

class TaskMeasurePolicy {
  const TaskMeasurePolicy({
    required this.supportedMeasureTypes,
    this.supportedSamplingTypes =
        TaskMeasureParser.defaultSupportedSamplingTypes,
    this.intervalSamplingMeasureTypes = const <String>{},
    this.periodicSamplingMeasureTypes = const <String>{},
    this.locationSamplingMeasureTypes = const <String>{},
    this.mobilitySamplingMeasureTypes = const <String>{},
    this.healthSamplingMeasureTypes = const <String>{},
  });

  final List<String> supportedMeasureTypes;
  final Set<String> supportedSamplingTypes;
  final Set<String> intervalSamplingMeasureTypes;
  final Set<String> periodicSamplingMeasureTypes;
  final Set<String> locationSamplingMeasureTypes;
  final Set<String> mobilitySamplingMeasureTypes;
  final Set<String> healthSamplingMeasureTypes;
}

const TaskMeasurePolicy backgroundTaskMeasurePolicy = TaskMeasurePolicy(
  supportedMeasureTypes: kSupportedMeasureTypes,
  intervalSamplingMeasureTypes: <String>{
    DeviceSamplingPackage.BATTERY_STATE,
    DeviceSamplingPackage.FREE_MEMORY,
    ConnectivitySamplingPackage.WIFI,
    SensorSamplingPackage.ACCELERATION,
    SensorSamplingPackage.NON_GRAVITATIONAL_ACCELERATION,
    SensorSamplingPackage.ROTATION,
    SensorSamplingPackage.MAGNETIC_FIELD,
  },
  periodicSamplingMeasureTypes: <String>{
    ConnectivitySamplingPackage.BLUETOOTH,
    SensorSamplingPackage.ACCELERATION_FEATURES,
    SensorSamplingPackage.AMBIENT_LIGHT,
    MediaSamplingPackage.NOISE,
  },
  locationSamplingMeasureTypes: <String>{
    ContextSamplingPackage.LOCATION,
  },
  mobilitySamplingMeasureTypes: <String>{
    ContextSamplingPackage.MOBILITY,
  },
  healthSamplingMeasureTypes: <String>{
    HealthSamplingPackage.HEALTH,
  },
);

class TaskMeasureParser {
  static const Set<String> defaultSupportedSamplingTypes = <String>{
    'none',
    'interval',
    'periodic',
    'location',
    'mobility',
    'health',
  };

  List<Measure> parseMeasures(
    List<TaskMeasureInput> measures, {
    required TaskMeasurePolicy policy,
  }) {
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

    // Health measures use the package factory method and require a dedicated
    // samplingType: "health" configuration.
    if (measureType == HealthSamplingPackage.HEALTH) {
      return _parseHealthMeasure(
          measureType, input.samplingConfiguration, policy);
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

  Measure _parseHealthMeasure(
    String measureType,
    TaskSamplingInput? samplingInput,
    TaskMeasurePolicy policy,
  ) {
    if (samplingInput == null) {
      throw ArgumentError(
        'samplingConfiguration is required for health measure. '
        'Use samplingType: "health" with healthDataTypes.',
      );
    }

    if (!policy.healthSamplingMeasureTypes.contains(measureType)) {
      throw ArgumentError(
        'samplingType health is not supported for measureType: $measureType.',
      );
    }

    final samplingType = samplingInput.samplingType.trim().toLowerCase();
    if (samplingType != 'health') {
      throw ArgumentError(
        'Invalid samplingType for health measure: ${samplingInput.samplingType}. '
        'Use samplingType: "health".',
      );
    }

    final rawTypes = samplingInput.healthDataTypes;
    if (rawTypes == null || rawTypes.isEmpty) {
      throw ArgumentError(
        'healthDataTypes is required for health sampling. '
        'Provide at least one HealthDataType value.',
      );
    }

    final parsedTypes = <HealthDataType>[];
    for (final rawType in rawTypes) {
      final match =
          HealthDataType.values.where((v) => v.name == rawType).firstOrNull;
      if (match == null) {
        throw ArgumentError(
          'Unsupported healthDataType: $rawType. '
          'Supported values: ${HealthDataType.values.map((v) => v.name).join(', ')}.',
        );
      }
      parsedTypes.add(match);
    }

    final days = samplingInput.days;
    if (days != null && days < 1) {
      throw ArgumentError(
        'Invalid days for health sampling: $days. Use a positive integer.',
      );
    }

    return HealthSamplingPackage.getHealthMeasure(parsedTypes, days ?? 30);
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

    final interval = samplingInput.interval;
    if (interval == null || interval.inMicroseconds <= 0) {
      throw ArgumentError(
        'Invalid interval for interval sampling. Use a positive duration.',
      );
    }

    return IntervalSamplingConfiguration(
      interval: interval,
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

    final interval = samplingInput.interval;
    final duration = samplingInput.duration;

    if (interval == null || interval.inMicroseconds <= 0) {
      throw ArgumentError(
        'Invalid interval for periodic sampling. Use a positive duration.',
      );
    }
    if (duration == null || duration.inMicroseconds <= 0) {
      throw ArgumentError(
        'Invalid duration for periodic sampling. Use a positive duration.',
      );
    }

    return PeriodicSamplingConfiguration(
      interval: interval,
      duration: duration,
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

    final stopDuration = samplingInput.stopDuration;
    if (stopDuration != null && stopDuration.inMicroseconds <= 0) {
      throw ArgumentError(
        'Invalid stopDuration for mobility sampling. Use a positive duration.',
      );
    }

    return MobilitySamplingConfiguration(
      usePriorContexts: samplingInput.usePriorContexts ?? true,
      stopRadius: stopRadius ?? 25,
      placeRadius: placeRadius ?? 50,
      stopDuration: stopDuration ?? const Duration(seconds: 30),
    );
  }
}
