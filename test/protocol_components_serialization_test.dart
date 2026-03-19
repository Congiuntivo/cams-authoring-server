import 'dart:convert';
import 'dart:io';

import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_health_package/health_package.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_movesense_package/carp_movesense_package.dart';
import 'package:carp_polar_package/carp_polar_package.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  CarpMobileSensing.ensureInitialized();

  test('builds a demo-like protocol and serializes all core components', () {
    final protocol = SmartphoneStudyProtocol(
      name: 'Plugin Coverage Protocol',
      ownerId: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
    )..studyDescription = StudyDescription(
        title: 'Plugin Coverage Protocol',
        description: 'Ensures domain/plugin-backed components can be used.',
        purpose: 'Serialization coverage',
      );

    final phone = Smartphone(roleName: 'Phone');
    protocol.addPrimaryDevice(phone);

    final locationService = LocationService(roleName: 'Location Service');
    final weatherService =
        WeatherService(roleName: 'Weather Service', apiKey: 'test-api-key');
    final airQualityService = AirQualityService(
      roleName: 'Air Quality Service',
      apiKey: 'test-air-quality-key',
    );
    final healthService = HealthService(roleName: 'Health Service');

    protocol
      ..addConnectedDevice(locationService, phone)
      ..addConnectedDevice(weatherService, phone)
      ..addConnectedDevice(airQualityService, phone)
      ..addConnectedDevice(healthService, phone);

    final polar = PolarDevice(roleName: 'Polar HR Sensor');
    final movesense = MovesenseDevice(roleName: 'Movesense Sensor');

    protocol
      ..addConnectedDevice(polar, phone)
      ..addConnectedDevice(movesense, phone);

    protocol.addTaskControl(
      ImmediateTrigger(),
      BackgroundTask(measures: [
        Measure(type: DeviceSamplingPackage.TIMEZONE),
        Measure(type: SensorSamplingPackage.AMBIENT_LIGHT),
        Measure(type: ContextSamplingPackage.ACTIVITY),
      ]),
      phone,
    );

    protocol.addTaskControl(
      ImmediateTrigger(),
      BackgroundTask(measures: [
        Measure(type: ContextSamplingPackage.LOCATION),
        Measure(type: ContextSamplingPackage.MOBILITY),
      ]),
      locationService,
    );

    protocol.addTaskControl(
      PeriodicTrigger(period: const Duration(minutes: 30)),
      BackgroundTask(measures: [
        Measure(type: ContextSamplingPackage.WEATHER),
      ]),
      weatherService,
    );

    protocol.addTaskControl(
      PeriodicTrigger(period: const Duration(minutes: 30)),
      BackgroundTask(measures: [
        Measure(type: ContextSamplingPackage.AIR_QUALITY),
      ]),
      airQualityService,
    );

    protocol.addTaskControl(
      ImmediateTrigger(),
      BackgroundTask(measures: [
        Measure(type: PolarSamplingPackage.HR),
      ]),
      polar,
    );

    protocol.addTaskControl(
      ImmediateTrigger(),
      BackgroundTask(measures: [
        Measure(type: MovesenseSamplingPackage.STATE),
        Measure(type: MovesenseSamplingPackage.HR),
      ]),
      movesense,
    );

    final environmentTask = AppTask(
      type: 'BackgroundSensingUserTask',
      title: 'Environment task',
      description: 'Collect context in foreground.',
      measures: [
        Measure(type: ContextSamplingPackage.LOCATION),
        Measure(type: ContextSamplingPackage.WEATHER),
      ],
    );

    final followUpTask = AppTask(
      type: 'SurveyTask',
      title: 'Follow-up task',
      description: 'Triggered after environment task.',
      measures: [
        Measure(type: ContextSamplingPackage.LOCATION),
      ],
    );

    protocol
      ..addTaskControl(
        NoUserTaskTrigger(taskName: environmentTask.name),
        environmentTask,
        phone,
      )
      ..addTaskControl(
        UserTaskTrigger(
          taskName: environmentTask.name,
          triggerCondition: UserTaskState.done,
        ),
        followUpTask,
        phone,
      );

    final serialized = toJsonString(protocol);
    final json = jsonDecode(serialized) as Map<String, dynamic>;

    final artifactDir = Directory('test_artifacts');
    artifactDir.createSync(recursive: true);
    final artifactFile =
        File('test_artifacts/protocol_components_serialized.json');
    artifactFile.writeAsStringSync(serialized);

    expect(serialized, isNotEmpty);
    expect(artifactFile.existsSync(), isTrue);
    expect(json['name'], 'Plugin Coverage Protocol');

    // Validate representative component types are present in serialized payload.
    expect(serialized,
        contains('dk.cachet.carp.common.application.devices.Smartphone'));
    expect(serialized, contains('LocationService'));
    expect(serialized, contains('WeatherService'));
    expect(serialized, contains('AirQualityService'));
    expect(serialized, contains('HealthService'));
    expect(serialized, contains('PolarDevice'));
    expect(serialized, contains('MovesenseDevice'));
    expect(serialized, contains('ImmediateTrigger'));
    expect(serialized, contains('PeriodicTrigger'));
    expect(serialized, contains('NoUserTaskTrigger'));
    expect(serialized, contains('UserTaskTrigger'));
    expect(serialized, contains('BackgroundTask'));
    expect(serialized, contains('AppTask'));

    // Structural sanity checks on serialized output.
    final primaryDevices = json['primaryDevices'] as List<dynamic>;
    final connectedDevices = json['connectedDevices'] as List<dynamic>;
    final tasks = json['tasks'] as List<dynamic>;

    expect(primaryDevices.length, 1);
    expect(connectedDevices.length, greaterThanOrEqualTo(6));
    expect(tasks.length, greaterThanOrEqualTo(8));
    expect(json['triggers'], isNotNull);
    expect(json['taskControls'], isNotNull);
  });
}
