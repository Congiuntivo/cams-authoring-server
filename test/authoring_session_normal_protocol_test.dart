import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_session/authoring_session.dart';

void main() {
  test('can start a default protocol', () {
    final session = AuthoringSession('Default Protocol', null, false);

    expect(session.isSmartphoneProtocol, isFalse);
    expect(session.defaultProtocol, isNotNull);
    expect(session.defaultProtocol!.name, 'Default Protocol');
    expect(
      session.defaultProtocol!.description,
      'study.description.description',
    );
  });

  test('can start default protocol twice in one session', () {
    final session = AuthoringSession('First Protocol', null, false);
    session.newDefaultProtocol('Second Protocol', null);

    expect(session.defaultProtocol, isNotNull);
    expect(session.defaultProtocol!.name, 'Second Protocol');
  });
}
