import 'package:flutter_test/flutter_test.dart';
import 'package:carp_backend/carp_backend.dart';
import 'package:study_protocol_authoring_server/src/protocol_authoring_service.dart';

void main() {
  test('createSession returns a generated session id', () {
    final service = ProtocolAuthoringService();

    final sessionId = service.createSession();

    expect((sessionId).isNotEmpty, isTrue);
  });

  test('getState and serialize require existing session', () {
    final service = ProtocolAuthoringService();

    expect(
      () => service.getState('missing'),
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

    expect(service.getState('A'), <String, dynamic>{'state': 'sessionCreated'});
    expect(service.getState('B'), <String, dynamic>{'state': 'sessionCreated'});
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
    expect(state['state'], 'protocolStarted');

    final endpointState = service.addDataEndPoint(
      sessionId,
      'CAWS',
      CarpUploadMethod.stream,
      'CARP Web Services',
      true,
    );
    expect(endpointState['state'], 'addedDataEndPoint');

    final serialized = service.serialize(sessionId);
    expect(serialized['name'], 'My Study Protocol');
    expect(serialized['ownerId'], '979b408d-784e-4b1b-bb1e-ff9204e072f3');
  });
}
