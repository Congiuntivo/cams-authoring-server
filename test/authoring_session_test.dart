import 'dart:convert';

import 'package:carp_serializable/carp_serializable.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_requirements.dart';
import 'package:study_protocol_authoring_server/src/authoring_session/authoring_session.dart';

void main() {
  test('cannot serialize before protocol has started', () {
    final session = AuthoringSession('My Study Protocol', null, true);

    expect(
      session.serialize,
      throwsA(isA<AuthoringRequirementsException>()),
    );
  });

  test('starting protocol creates a protocol with localized description', () {
    final session = AuthoringSession('My Study Protocol', null, true);

    expect(jsonDecode(toJsonString(session.smartphoneProtocol)), isNotNull);
    expect(session.smartphoneProtocol!.name, 'My Study Protocol');
    expect(session.smartphoneProtocol!.studyDescription, isNotNull);
  });

  test('can start protocol twice in one session', () {
    final session = AuthoringSession('Initial Protocol', null, true);

    session.newSmartphoneProtocol('First Protocol', null);

    session.newSmartphoneProtocol('Second Protocol', null);
    expect(session.smartphoneProtocol!.name, 'Second Protocol');
  });
}
