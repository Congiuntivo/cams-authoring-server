import 'package:carp_backend/carp_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/protocol_authoring_service.dart';

void main() {
  test('createNewProtocol returns a generated session id', () {
    final service = ProtocolAuthoringService();

    final state = service.createNewProtocol('Protocol', null, true);
    final sessionId = state['sessionId'] as String;

    expect((sessionId).isNotEmpty, isTrue);
  });

  test('getRequirements and serialize require existing session', () {
    final service = ProtocolAuthoringService();

    expect(
      () => service.getRequirements('missing'),
      throwsA(isA<SessionNotFoundException>()),
    );
    expect(
      () => service.serialize('missing'),
      throwsA(isA<SessionNotFoundException>()),
    );
    expect(
      () => service.getPrimarydevice('missing'),
      throwsA(isA<SessionNotFoundException>()),
    );
    expect(
      () => service.getParticipantRoles('missing'),
      throwsA(isA<SessionNotFoundException>()),
    );
    expect(
      () => service.getTriggers('missing'),
      throwsA(isA<SessionNotFoundException>()),
    );
  });

  test('getPrimarydevice returns configured primary device payload', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S0',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final response = service.getPrimarydevice(sessionId);
    final primaryDevice = response['primaryDevice'] as Map<String, dynamic>;
    expect(primaryDevice['name'], 'User Phone');
    expect(
      (primaryDevice['device'] as Map<String, dynamic>)['roleName'],
      'User Phone',
    );
  });

  test('getParticipantRoles returns configured role names', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S4',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addParticipantRole(sessionId, 'Patient', false);
    service.addParticipantRole(sessionId, 'Caregiver', true);

    final response = service.getParticipantRoles(sessionId);
    expect(response, <String, dynamic>{
      'roleNames': <String>['Patient', 'Caregiver'],
    });
  });

  test('getDevices returns empty devices when none exist', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S4D',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;

    final response = service.getDevices(sessionId);
    expect(response, <String, dynamic>{
      'devices': <Map<String, Object?>>[],
    });
  });

  test('sessions are isolated', () {
    final ids = <String>['A', 'B'];
    var index = 0;
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => ids[index++],
    );

    final first =
        service.createNewProtocol('Protocol A', 'owner', true)['sessionId'];
    final second =
        service.createNewProtocol('Protocol B', 'owner', true)['sessionId'];

    expect(first, 'A');
    expect(second, 'B');

    expect(service.getRequirements('A'), <String, dynamic>{
      'unfulfilledRequirements': {
        'warnings': <String>[
          'A data end point must be configured.',
          'At least one participant role must be configured.'
        ],
        'critical': <String>[
          'A primary device must be configured.',
        ],
      }
    });
    expect(service.getRequirements('B'), <String, dynamic>{
      'unfulfilledRequirements': {
        'warnings': <String>[
          'A data end point must be configured.',
          'At least one participant role must be configured.'
        ],
        'critical': <String>['A primary device must be configured.'],
      }
    });
  });

  test('createNewSmartphoneProtocol then addDataEndPoint enables serialize',
      () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S1',
    );

    final state = service.createNewProtocol(
      'My Study Protocol',
      '979b408d-784e-4b1b-bb1e-ff9204e072f3',
      true,
    );
    final sessionId = state['sessionId'] as String;

    expect(state['sessionId'], 'S1');
    expect(state.length, 1);

    final endpointState = service.addDataEndPoint(
      sessionId,
      'CAWS',
      CarpUploadMethod.stream,
      'CARP Web Services',
      true,
    );
    expect(endpointState['unfulfilledRequirements']['warnings'],
        <String>['At least one participant role must be configured.']);
    expect(endpointState['unfulfilledRequirements']['critical'],
        <String>['A primary device must be configured.']);

    final primaryDeviceState = service.addSmartphonePrimaryDevice(
      sessionId,
      'User Phone',
    );
    expect(
        primaryDeviceState['unfulfilledRequirements']['critical'], <String>[]);

    final serialized = service.serialize(sessionId);
    final protocol = serialized['protocol'] as Map<String, dynamic>;
    expect(protocol['name'], 'My Study Protocol');
    expect(protocol['ownerId'], '979b408d-784e-4b1b-bb1e-ff9204e072f3');
  });

  test('add participant role and expected participant data for specific role',
      () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S2',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addDataEndPoint(
      sessionId,
      'CAWS',
      CarpUploadMethod.stream,
      'CARP Web Services',
      true,
    );
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final roleState = service.addParticipantRole(sessionId, 'Patient', false);
    expect(roleState['sessionId'], sessionId);

    final expectedState =
        service.addExpectedParticipantDataForRole(sessionId, 'Patient', 'sex');
    expect(expectedState['sessionId'], sessionId);

    final serialized = service.serialize(sessionId);
    final protocol = serialized['protocol'] as Map<String, dynamic>;
    expect((protocol['participantRoles'] as List<dynamic>).isNotEmpty, isTrue);
    expect(
      (protocol['expectedParticipantData'] as List<dynamic>).isNotEmpty,
      isTrue,
    );
  });

  test('add expected participant data for all roles', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S3',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addDataEndPoint(
      sessionId,
      'CAWS',
      CarpUploadMethod.stream,
      'CARP Web Services',
      true,
    );
    service.addSmartphonePrimaryDevice(sessionId, null);
    service.addParticipantRole(sessionId, 'Caregiver', null);

    final expectedState = service.addExpectedParticipantDataForAllRoles(
      sessionId,
      'informed_consent',
    );
    expect(expectedState['sessionId'], sessionId);

    final serialized = service.serialize(sessionId);
    final protocol = serialized['protocol'] as Map<String, dynamic>;
    expect((protocol['participantRoles'] as List<dynamic>).isNotEmpty, isTrue);
    expect(
      (protocol['expectedParticipantData'] as List<dynamic>).isNotEmpty,
      isTrue,
    );
  });

  test('adding smartphone primary device to default protocol throws', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S5',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', false)['sessionId'] as String;

    expect(
      () => service.addSmartphonePrimaryDevice(sessionId, 'User Phone'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Smartphone primary device can only be added'),
        ),
      ),
    );
  });

  test('adding browser primary device to smartphone protocol throws', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S6',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;

    expect(
      () => service.addBrowserPrimaryDevice(sessionId, 'Participant Browser'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Browser primary device can only be added'),
        ),
      ),
    );
  });

  test('addWeatherService and getServices return configured services', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S7',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addWeatherService(sessionId, 'Local Weather');
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

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addAirQualityService(sessionId, 'Local Air Quality');
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

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addLocationService(
      sessionId,
      'User Location',
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

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addHealthService(sessionId, 'Device Health');
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

  test('addESenseDevice and getDevices return configured devices', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S8D',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addESenseDevice(
      sessionId,
      'Left Earbud',
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

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addMovesenseDevice(
      sessionId,
      'Chest Sensor',
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

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addMovisensDevice(
      sessionId,
      'Torso Sensor',
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

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final state = service.addPolarDevice(
      sessionId,
      'Polar Chest Sensor',
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

  test('addWeatherService throws when service role name is already taken', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S9',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');
    service.addWeatherService(sessionId, 'Local Weather');

    expect(
      () => service.addWeatherService(sessionId, 'Local Weather'),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('Service role name already taken'),
        ),
      ),
    );
  });

  test('addESenseDevice throws when role name is already used by service', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S10',
    );

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');
    service.addWeatherService(sessionId, 'Shared Sensor');

    expect(
      () => service.addESenseDevice(sessionId, 'Shared Sensor', false, 20),
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

    final sessionId = service.createNewProtocol(
        'Protocol', 'owner', true)['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    expect(
      () => service.addWeatherService(sessionId, 'User Phone'),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('Service role name already taken'),
        ),
      ),
    );
  });
}
