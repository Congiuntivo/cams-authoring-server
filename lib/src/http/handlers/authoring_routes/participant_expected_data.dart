part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

const List<String> _participantExpectedDataEnumValues = <String>[
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
];

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'AddExpectedParticipantDataRequest',
      required: <String>['dataType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'dataType',
          type: 'string',
          required: true,
          enumValues: _participantExpectedDataEnumValues,
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
      '/sessions/<sessionId>/participant-roles/<roleName>/expected-data',
      _addExpectedParticipantDataForRole,
    );
    router.post('/sessions/<sessionId>/expected-data',
        _addExpectedParticipantDataForAllRoles);
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/participant-roles/{roleName}/expected-data',
    summary: 'Add expected participant data for a specific role',
    operationId: 'addExpectedParticipantDataForRole',
    tags: <String>['Expected Participant Data'],
    description: 'Adds expected participant data assigned to a specific role.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'roleName',
        location: 'path',
        type: 'string',
        required: true,
        description: 'Existing participant role name.',
        example: 'Patient',
      ),
    ],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'AddExpectedParticipantDataRequest',
      description: 'Expected participant data type payload.',
      required: true,
      example: <String, Object?>{'dataType': 'sex'},
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Expected participant data added for role',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid request body',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addExpectedParticipantDataForRole(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final roleName = _requireStringValue(
        request.params['roleName'],
        'roleName',
        'Missing roleName. Provide /participant-roles/{roleName}/ path parameter.',
      );
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

      final stateJson = _service.addExpectedParticipantDataForRole(
        sessionId,
        roleName,
        dataType,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/expected-data',
    summary: 'Add expected participant data for all roles',
    operationId: 'addExpectedParticipantDataForAllRoles',
    tags: <String>['Expected Participant Data'],
    description: 'Adds expected participant data assigned to all roles.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
    ],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'AddExpectedParticipantDataRequest',
      description: 'Expected participant data type payload.',
      required: true,
      example: <String, Object?>{'dataType': 'informed_consent'},
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Expected participant data added for all roles',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid request body',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
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
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
