part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

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
    description: 'Adds expected participant data assigned to a specific role.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
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
      ApiParameterDoc(
        name: 'dataType',
        location: 'query',
        type: 'string',
        enumValues: AuthoringRoutesBase.supportedParticipantDataTypes,
        required: true,
        description:
            'Participant input data type. Supported values: sex, phone_number, ssn, full_name, informed_consent, address, diagnosis, custom.',
        example: 'sex',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Expected participant data added for role',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid query parameters',
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

    return _runWithErrorHandling(() {
      final roleName = _requireStringValue(
        request.params['roleName'],
        'roleName',
        'Missing roleName. Provide /participant-roles/{roleName}/ path parameter.',
      );
      final dataType = _requireEnumQueryParam(
        request,
        'dataType',
        AuthoringRoutesBase.supportedParticipantDataTypes,
        missingMessage:
            'Missing dataType. Provide ?dataType=... query parameter.',
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
    description: 'Adds expected participant data assigned to all roles.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'dataType',
        location: 'query',
        type: 'string',
        enumValues: AuthoringRoutesBase.supportedParticipantDataTypes,
        required: true,
        description:
            'Participant input data type. Supported values: sex, phone_number, ssn, full_name, informed_consent, address, diagnosis, custom.',
        example: 'informed_consent',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Expected participant data added for all roles',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid query parameters',
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

    return _runWithErrorHandling(() {
      final dataType = _requireEnumQueryParam(
        request,
        'dataType',
        AuthoringRoutesBase.supportedParticipantDataTypes,
        missingMessage:
            'Missing dataType. Provide ?dataType=... query parameter.',
      );

      final stateJson = _service.addExpectedParticipantDataForAllRoles(
        sessionId,
        dataType,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
