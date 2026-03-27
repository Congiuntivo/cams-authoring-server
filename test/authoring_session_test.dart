import 'dart:convert';

import 'package:carp_serializable/carp_serializable.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_requirements.dart';
import 'package:study_protocol_authoring_server/src/authoring_session/authoring_session.dart';

void main() {
  test('cannot serialize before protocol has started', () {
    final session = AuthoringSession();

    expect(
      session.serialize,
      throwsA(isA<AuthoringRequirementsException>()),
    );
  });

  test('starting protocol creates a protocol with localized description', () {
    final session = AuthoringSession();

    session.newSmartphoneProtocol('My Study Protocol', null);

    expect(jsonDecode(toJsonString(session.protocol)), isNotNull);
    expect(session.protocol!.name, 'My Study Protocol');
    expect(session.protocol!.studyDescription, isNotNull);
  });

  test('can start protocol twice in one session', () {
    final session = AuthoringSession();

    session.newSmartphoneProtocol('First Protocol', null);

    session.newSmartphoneProtocol('Second Protocol', null);
    expect(session.protocol!.name, 'Second Protocol');
  });
}
