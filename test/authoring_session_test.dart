import 'package:flutter_test/flutter_test.dart';
import 'package:study_protocol_authoring_server/src/authoring_session.dart';

void main() {
  test('session starts in ready state', () {
    final session = AuthoringSession();

    expect(session.state, ProtocolAuthoringState.ready);
    expect(session.toStateJson(), <String, dynamic>{'state': 'ready'});
  });

  test('starting a new protocol changes state', () {
    final session = AuthoringSession();

    session.startNewProtocol();

    expect(session.state, ProtocolAuthoringState.protocolStarted);
    expect(
      session.toStateJson(),
      <String, dynamic>{'state': 'protocolStarted'},
    );
  });

  test('dummy serialization has stable structure', () {
    final session = AuthoringSession();

    expect(session.toDummySerialization(), <String, dynamic>{
      'dummy': true,
      'protocol': <String, dynamic>{
        'name': 'dummy_protocol',
        'version': 1,
      },
    });
  });
}
