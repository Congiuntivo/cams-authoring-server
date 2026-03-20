import 'package:flutter_test/flutter_test.dart';
import 'package:carp_backend/carp_backend.dart';
import 'package:study_protocol_authoring_server/src/protocol_authoring_service.dart';

void main() {
  test('createSession returns a generated session id', () {
    final service = ProtocolAuthoringService();

    final sessionId = service.createSession();

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
  });

  test('sessions are isolated', () {
    final ids = <String>['A', 'B'];
    var index = 0;
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => ids[index++],
    );

    final first = service.createSession();
    final second = service.createSession();

    expect(first, 'A');
    expect(second, 'B');

    expect(service.getRequirements('A'), <String, dynamic>{
      'unfulfilledRequirements': {
        'warnings': <String>['A data end point must be configured.'],
        'critical': <String>['A primary device must be configured.'],
      }
    });
    expect(service.getRequirements('B'), <String, dynamic>{
      'unfulfilledRequirements': {
        'warnings': <String>['A data end point must be configured.'],
        'critical': <String>['A primary device must be configured.'],
      }
    });
  });

  test('createNewProtocol then addDataEndPoint enables serialize', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S1',
    );

    final sessionId = service.createSession();
    final state = service.createNewProtocol(
      sessionId,
      'My Study Protocol',
      '979b408d-784e-4b1b-bb1e-ff9204e072f3',
    );

    expect(state['sessionId'], 'S1');
    expect(state.length, 1);

    final endpointState = service.addDataEndPoint(
      sessionId,
      'CAWS',
      CarpUploadMethod.stream,
      'CARP Web Services',
      true,
    );
    expect(endpointState['unfulfilledRequirements']['warnings'], <String>[]);
    expect(endpointState['unfulfilledRequirements']['critical'],
        <String>['A primary device must be configured.']);

    final primaryDeviceState = service.addPrimaryDevice(
      sessionId,
      'smartphone',
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
