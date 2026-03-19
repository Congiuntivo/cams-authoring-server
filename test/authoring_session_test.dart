import 'package:flutter_test/flutter_test.dart';
import 'package:study_protocol_authoring_server/src/authoring_session.dart';
import 'package:study_protocol_authoring_server/src/authoring_session_fsm.dart';

void main() {
  test('new session starts in sessionCreated state', () {
    final session = AuthoringSession();

    expect(session.toStateJson(), <String, dynamic>{'state': 'sessionCreated'});
  });

  test('cannot serialize before protocol has started', () {
    final session = AuthoringSession();

    expect(
      session.serialize,
      throwsA(isA<InvalidAuthoringTransitionException>()),
    );
  });

  test('starting protocol transitions state to protocolStarted', () {
    final session = AuthoringSession();

    session.newProtocol('My Study Protocol', null);

    expect(
        session.toStateJson(), <String, dynamic>{'state': 'protocolStarted'});
  });

  test('cannot start protocol twice in one session', () {
    final session = AuthoringSession();

    session.newProtocol('First Protocol', null);

    expect(
      () => session.newProtocol('Second Protocol', null),
      throwsA(isA<InvalidAuthoringTransitionException>()),
    );
  });
}
