part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'ParticipantDataType',
      type: 'string',
      enumValues: <String>[
        'sex',
        'phone_number',
        'ssn',
        'full_name',
        'informed_consent',
        'address',
        'diagnosis',
        'note',
        'educational_degree',
        'onboarding_researcher',
        'language',
        'occupation',
      ],
    ),
    ApiSchemaDoc(
      name: 'AddExpectedParticipantDataForRoleRequest',
      required: <String>['roleName', 'dataType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleName',
          type: 'string',
          required: true,
          example: 'Patient',
        ),
        ApiPropertyDoc(
          name: 'dataType',
          ref: 'ParticipantDataType',
          required: true,
          example: 'sex',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'AddExpectedParticipantDataRequest',
      required: <String>['dataType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'dataType',
          ref: 'ParticipantDataType',
          required: true,
          example: 'sex',
        ),
      ],
    ),
  ],
)
mixin ParticipantExpectedDataRoutes on AuthoringRoutesBase {
  @override
  void registerParticipantExpectedDataRoutes(Router router) {
    router.post(
      '/sessions/<sessionId>/participant-roles/expected-data',
      _addExpectedParticipantDataForRole,
    );
    router.post('/sessions/<sessionId>/expected-data',
        _addExpectedParticipantDataForAllRoles);
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/participant-roles/expected-data',
    summary: 'Add expected participant data for a specific role',
    operationId: 'addExpectedParticipantDataForRole',
    tags: <String>['Expected Participant Data'],
    description: 'Declares that a specific participant role is expected to '
        'provide the given dataType. roleName must match an existing '
        'participant role; if it does not, the session carries an unfulfilled '
        'requirement. dataType must be one of the enum values listed in '
        'ParticipantDataType.',
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'AddExpectedParticipantDataForRoleRequest',
      description: 'Expected participant data payload for a specific role.',
      required: true,
      example: <String, Object?>{'roleName': 'Patient', 'dataType': 'sex'},
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Expected participant data added for role',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid request body',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addExpectedParticipantDataForRole(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = AddExpectedParticipantDataForRoleRequest.fromJson(body);

      final roleName = _requireStringValue(
        payload.roleName,
        'roleName',
        'Missing roleName. Provide roleName in request body.',
      );

      final dataType = _requireStringValue(
        payload.dataType,
        'dataType',
        'Missing dataType. Provide dataType in request body.',
      );
      _validateEnumValue(
        'dataType',
        dataType,
        AuthoringRoutesBase.supportedParticipantDataTypes,
      );

      final stateJson = _service.addExpectedParticipantDataForRole(
        sessionId,
        roleName,
        dataType,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/expected-data',
    summary: 'Add expected participant data for all roles',
    operationId: 'addExpectedParticipantDataForAllRoles',
    tags: <String>['Expected Participant Data'],
    description: 'Declares that all participant roles are expected to provide '
        'the given dataType. dataType must be one of the enum values listed '
        'in ParticipantDataType.',
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'AddExpectedParticipantDataRequest',
      description: 'Expected participant data type payload.',
      required: true,
      example: <String, Object?>{'dataType': 'informed_consent'},
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Expected participant data added for all roles',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid request body',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addExpectedParticipantDataForAllRoles(
      Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = AddExpectedParticipantDataRequest.fromJson(body);

      final dataType = _requireStringValue(
        payload.dataType,
        'dataType',
        'Missing dataType. Provide dataType in request body.',
      );
      _validateEnumValue(
        'dataType',
        dataType,
        AuthoringRoutesBase.supportedParticipantDataTypes,
      );

      final stateJson = _service.addExpectedParticipantDataForAllRoles(
        sessionId,
        dataType,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }
}
