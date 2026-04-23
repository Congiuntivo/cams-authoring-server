import '../request_parsing_utils.dart';

class AddParticipantRoleRequest {
  const AddParticipantRoleRequest({
    required this.roleName,
    this.isOptional,
  });

  final String roleName;
  final bool? isOptional;

  factory AddParticipantRoleRequest.fromJson(Map<String, dynamic> json) {
    const context = 'add participant role request body';

    ensureNoUnknownFields(
      json,
      const <String>{'roleName', 'isOptional'},
      context,
    );

    return AddParticipantRoleRequest(
      roleName: requireNonBlankString(json, 'roleName', context: context),
      isOptional: parseOptionalBool(
        json['isOptional'],
        'isOptional',
        context: context,
      ),
    );
  }
}

class AddExpectedParticipantDataRequest {
  const AddExpectedParticipantDataRequest({
    required this.dataType,
  });

  final String dataType;

  factory AddExpectedParticipantDataRequest.fromJson(
      Map<String, dynamic> json) {
    const context = 'add expected participant data request body';

    ensureNoUnknownFields(
      json,
      const <String>{'dataType'},
      context,
    );

    return AddExpectedParticipantDataRequest(
      dataType: requireNonBlankString(json, 'dataType', context: context),
    );
  }
}

class AddExpectedParticipantDataForRoleRequest {
  const AddExpectedParticipantDataForRoleRequest({
    required this.roleName,
    required this.dataType,
  });

  final String roleName;
  final String dataType;

  factory AddExpectedParticipantDataForRoleRequest.fromJson(
      Map<String, dynamic> json) {
    const context = 'add expected participant data for role request body';

    ensureNoUnknownFields(
      json,
      const <String>{'roleName', 'dataType'},
      context,
    );

    return AddExpectedParticipantDataForRoleRequest(
      roleName: requireNonBlankString(json, 'roleName', context: context),
      dataType: requireNonBlankString(json, 'dataType', context: context),
    );
  }
}
