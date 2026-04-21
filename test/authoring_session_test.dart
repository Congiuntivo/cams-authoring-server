import 'dart:convert';

import 'package:carp_serializable/carp_serializable.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_session/authoring_session.dart';
import 'package:study_protocol_authoring_server/src/authoring_session/utils/authoring_requirements.dart';

void main() {
  test('cannot serialize before protocol has started', () {
    final session = AuthoringSession('My Study Protocol', null);

    expect(
      session.serialize,
      throwsA(isA<AuthoringRequirementsException>()),
    );
  });

  test('starting protocol creates a protocol with localized description', () {
    final session = AuthoringSession('My Study Protocol', null);

    expect(jsonDecode(toJsonString(session.protocol)), isNotNull);
    expect(session.protocol.name, 'My Study Protocol');
    expect(session.protocol.studyDescription, isNotNull);
  });

  test('stores optional protocol metadata in applicationData', () {
    final session = AuthoringSession(
      'Initial Protocol',
      null,
      protocolVersionTag: 'v1.2.3',
      protocolApiLevel: '2.0',
      applicationName: 'carp_study_app',
    );

    final applicationData = session.protocol.applicationData;
    expect(applicationData, isNotNull);
    expect(applicationData!['protocolVersionTag'], 'v1.2.3');
    expect(applicationData['protocolApiLevel'], '2.0');
    expect(applicationData['applicationName'], 'carp_study_app');
  });
}
