import 'package:carp_backend/carp_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_service/authoring_service.dart';

void main() {
  test('createNewProtocol returns a generated session id', () {
    final service = ProtocolAuthoringService();

    final state = service.createNewProtocol('Protocol', null);
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
      () => service.getPrimaryDevices('missing'),
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

  test('getPrimaryDevices returns configured primary devices payload', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S0',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');
    service.addESenseDevice(sessionId, 'Left Earbud', 'User Phone', false, 20);

    final response = service.getPrimaryDevices(sessionId);
    final primaryDevices = response['primaryDevices'] as List<dynamic>;
    final primaryDevice = primaryDevices.first as Map<String, dynamic>;
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

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
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

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;

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

    final first = service.createNewProtocol('Protocol A', 'owner')['sessionId'];
    final second =
        service.createNewProtocol('Protocol B', 'owner')['sessionId'];

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
}
