import 'package:carp_backend/carp_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_service/authoring_service.dart';

void main() {
  test('add participant role and expected participant data for specific role',
      () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S2',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addDataEndPoint(
      sessionId,
      'CAWS',
      CarpUploadMethod.stream,
      'CARP Web Services',
      true,
    );
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    final roleState = service.addParticipantRole(sessionId, 'Patient', false);
    expect(roleState['sessionId'], sessionId);

    final expectedState =
        service.addExpectedParticipantDataForRole(sessionId, 'Patient', 'sex');
    expect(expectedState['sessionId'], sessionId);

    final serialized = service.serialize(sessionId);
    final protocol = serialized['protocol'] as Map<String, dynamic>;
    expect((protocol['participantRoles'] as List<dynamic>).isNotEmpty, isTrue);
    expect(
      (protocol['expectedParticipantData'] as List<dynamic>).isNotEmpty,
      isTrue,
    );
  });

  test('add expected participant data for all roles', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S3',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addDataEndPoint(
      sessionId,
      'CAWS',
      CarpUploadMethod.stream,
      'CARP Web Services',
      true,
    );
    service.addSmartphonePrimaryDevice(sessionId, null);
    service.addParticipantRole(sessionId, 'Caregiver', null);

    final expectedState = service.addExpectedParticipantDataForAllRoles(
      sessionId,
      'informed_consent',
    );
    expect(expectedState['sessionId'], sessionId);

    final serialized = service.serialize(sessionId);
    final protocol = serialized['protocol'] as Map<String, dynamic>;
    expect((protocol['participantRoles'] as List<dynamic>).isNotEmpty, isTrue);
    expect(
      (protocol['expectedParticipantData'] as List<dynamic>).isNotEmpty,
      isTrue,
    );
  });
}
