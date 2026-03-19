import 'package:flutter_test/flutter_test.dart';
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

    expect(
        service.getState('A'), <String, dynamic>{'state': 'protocolStarted'});
    expect(
        service.getState('B'), <String, dynamic>{'state': 'protocolStarted'});
  });
}
