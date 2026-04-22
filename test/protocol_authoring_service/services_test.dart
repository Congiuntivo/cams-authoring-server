import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_service/authoring_service.dart';

void main() {
  test('addWeatherService and getServices return configured services', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S7',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state =
        service.addWeatherService(sessionId, 'Local Weather', 'User Phone');
    expect(state['sessionId'], sessionId);

    final services = service.getServices(sessionId);
    final serviceSummaries = services['services'] as List<dynamic>;
    expect(serviceSummaries.length, 1);
    expect(serviceSummaries.first['name'], 'Local Weather');
    expect(
      (serviceSummaries.first['device'] as Map<String, dynamic>)['roleName'],
      'Local Weather',
    );
  });

  test('addAirQualityService and getServices return configured services', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S8',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addAirQualityService(
      sessionId,
      'Local Air Quality',
      'User Phone',
    );
    expect(state['sessionId'], sessionId);

    final services = service.getServices(sessionId);
    final serviceSummaries = services['services'] as List<dynamic>;
    expect(serviceSummaries.length, 1);
    expect(serviceSummaries.first['name'], 'Local Air Quality');
    expect(
      (serviceSummaries.first['device'] as Map<String, dynamic>)['roleName'],
      'Local Air Quality',
    );
  });

  test('addLocationService and getServices return configured services', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S8L',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addLocationService(
      sessionId,
      'User Location',
      'User Phone',
      'high',
      25.0,
      const Duration(seconds: 30),
      'Tracking active',
      'Location tracking is running.',
      'Tap to return to the app.',
      'ic_notification',
      true,
    );
    expect(state['sessionId'], sessionId);

    final services = service.getServices(sessionId);
    final serviceSummaries = services['services'] as List<dynamic>;
    expect(serviceSummaries.length, 1);
    expect(serviceSummaries.first['name'], 'User Location');
    expect(
      (serviceSummaries.first['device'] as Map<String, dynamic>)['roleName'],
      'User Location',
    );
  });

  test('addHealthService and getServices return configured services', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S8H',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state =
        service.addHealthService(sessionId, 'Device Health', 'User Phone');
    expect(state['sessionId'], sessionId);

    final services = service.getServices(sessionId);
    final serviceSummaries = services['services'] as List<dynamic>;
    expect(serviceSummaries.length, 1);
    expect(serviceSummaries.first['name'], 'Device Health');
    expect(
      (serviceSummaries.first['device'] as Map<String, dynamic>)['roleName'],
      'Device Health',
    );
  });
}
