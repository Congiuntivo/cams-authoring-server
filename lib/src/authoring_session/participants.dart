part of 'authoring_session.dart';

extension AuthoringSessionParticipants on AuthoringSession {
  void addParticipantRole(String roleName, bool? isOptional) {
    final participantRole = isOptional == null
        ? ParticipantRole(roleName)
        : ParticipantRole(roleName, isOptional);

    protocol!.addParticipantRole(participantRole);

    _authoringRequirements.partecipantRole.isFulfilled = true;
  }

  List<String> getParticipantRoleNames() {
    if (protocol == null) {
      throw StateError(
          'Cannot get participant role names before protocol has started.');
    }
    final roles = protocol!.participantRoles;
    if (roles == null) return <String>[];

    return roles
        .map<String>((dynamic role) => role.role as String)
        .toList(growable: false);
  }

  void addExpectedParticipantData(String? assignedToRoleName, String dataType) {
    // ASK : Ask  how to deal with CustomInput
    if (AuthoringSession.inputDataTypesMap.containsKey(dataType)) {
      throw ArgumentError('Unsupported data type: $dataType');
    }

    if (!_authoringRequirements.partecipantRole.isFulfilled) {
      throw StateError(
          'Cannot add expected participant data before at least one participant role is configured.');
    }

    if (assignedToRoleName != null &&
        !protocol!.participantRoles!
            .any((role) => role.role == assignedToRoleName)) {
      throw ArgumentError(
          'Assigned role name does not exist: $assignedToRoleName');
    }

    protocol!.addExpectedParticipantData(ExpectedParticipantData(
      attribute: ParticipantAttribute(
          inputDataType: AuthoringSession.inputDataTypesMap[dataType]!),
      assignedTo: assignedToRoleName == null
          ? AssignedTo.all()
          : AssignedTo(roleNames: {assignedToRoleName}),
    ));
  }
}
