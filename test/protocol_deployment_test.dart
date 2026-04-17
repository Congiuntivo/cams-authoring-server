import 'dart:convert';
import 'dart:io';

import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart' hide Smartphone;
import 'package:carp_health_package/health_package.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_movesense_package/carp_movesense_package.dart';
import 'package:carp_polar_package/carp_polar_package.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  CarpMobileSensing.ensureInitialized();

  group('Protocol deployment test', () {
    test('builds a demo-like protocol and try to deploy it', () async {
      final protocol = createDemoProtocol();

      final serialized = toJsonString(protocol);
      final json = jsonDecode(serialized) as Map<String, dynamic>;

      final artifactDir = Directory('test_artifacts');
      artifactDir.createSync(recursive: true);
      final artifactFile = File('test_artifacts/protocol_deployment_test.json');
      artifactFile.writeAsStringSync(serialized);

      expect(serialized, isNotEmpty);
      expect(artifactFile.existsSync(), isTrue);
      expect(json['name'], 'Demo Protocol for Deployment');
      expect(serialized, contains('dk.carp.cams.devices.Smartphone'));

      DeploymentService deploymentService = SmartphoneDeploymentService();

      // Create a study deployment using the protocol
      var status = await deploymentService.createStudyDeployment(protocol);

      expect(status.status, StudyDeploymentStatusTypes.Invited);
      expect(status.studyDeploymentId, isNotEmpty);
    });
  });
}

SmartphoneStudyProtocol createDemoProtocol({bool withPrimaryDevice = true}) {
  final protocol = SmartphoneStudyProtocol(
    name: 'Demo Protocol for Deployment',
    ownerId: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
  )..studyDescription = StudyDescription(
      title: 'Demo Protocol for Deployment',
      description:
          'A demo protocol to test deployment of a protocol with multiple components.',
    );

  final phone = Smartphone(roleName: 'Phone');
  if (withPrimaryDevice) protocol.addPrimaryDevice(phone);

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

  if (!withPrimaryDevice) protocol.addConnectedDevice(phone, phone);

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

  return protocol;
}
