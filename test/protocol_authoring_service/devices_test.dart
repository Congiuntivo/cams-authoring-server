import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_service/authoring_service.dart';

void main() {
  test('addESenseDevice and getDevices return configured devices', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S8D',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addESenseDevice(
      sessionId,
      'Left Earbud',
      'User Phone',
      false,
      20,
    );
    expect(state['sessionId'], sessionId);

    final devices = service.getDevices(sessionId);
    final deviceSummaries = devices['devices'] as List<dynamic>;
    expect(deviceSummaries.length, 1);
    expect(deviceSummaries.first['name'], 'Left Earbud');
    expect(
      (deviceSummaries.first['device'] as Map<String, dynamic>)['roleName'],
      'Left Earbud',
    );
  });

  test('addMovesenseDevice and getDevices return configured devices', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S8M',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addMovesenseDevice(
      sessionId,
      'Chest Sensor',
      'User Phone',
      false,
    );
    expect(state['sessionId'], sessionId);

    final devices = service.getDevices(sessionId);
    final deviceSummaries = devices['devices'] as List<dynamic>;
    expect(deviceSummaries.length, 1);
    expect(deviceSummaries.first['name'], 'Movesense ECG Device');
    expect(
      (deviceSummaries.first['device'] as Map<String, dynamic>)['roleName'],
      'Movesense ECG Device',
    );
  });

  test('addMovisensDevice and getDevices return configured devices', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S8MV',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addMovisensDevice(
      sessionId,
      'Torso Sensor',
      'User Phone',
      'Chest',
      'Male',
      178,
      78,
      25,
    );
    expect(state['sessionId'], sessionId);

    final devices = service.getDevices(sessionId);
    final deviceSummaries = devices['devices'] as List<dynamic>;
    expect(deviceSummaries.length, 1);
    expect(deviceSummaries.first['name'], 'Torso Sensor');
    expect(
      (deviceSummaries.first['device'] as Map<String, dynamic>)['roleName'],
      'Torso Sensor',
    );
  });

  test('addPolarDevice and getDevices return configured devices', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S8P',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addPolarDevice(
      sessionId,
      'Polar Chest Sensor',
      'User Phone',
      false,
      'Polar',
    );
    expect(state['sessionId'], sessionId);

    final devices = service.getDevices(sessionId);
    final deviceSummaries = devices['devices'] as List<dynamic>;
    expect(deviceSummaries.length, 1);
    expect(deviceSummaries.first['name'], 'Polar Chest Sensor');
    expect(
      (deviceSummaries.first['device'] as Map<String, dynamic>)['roleName'],
      'Polar Chest Sensor',
    );
  });

  test('addWeatherService throws when device role name is already taken', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S9',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');
    service.addWeatherService(sessionId, 'Local Weather', 'User Phone');

    expect(
      () => service.addWeatherService(sessionId, 'Local Weather', 'User Phone'),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('Device role name already taken'),
        ),
      ),
    );
  });

  test('addESenseDevice throws when role name is already used by service', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S10',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');
    service.addWeatherService(sessionId, 'Shared Sensor', 'User Phone');

    expect(
      () => service.addESenseDevice(
          sessionId, 'Shared Sensor', 'User Phone', false, 20),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('Device role name already taken'),
        ),
      ),
    );
  });

  test('addWeatherService throws when role name matches primary device', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S11',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    expect(
      () => service.addWeatherService(sessionId, 'User Phone', 'User Phone'),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('Device role name already taken'),
        ),
      ),
    );
  });
}
