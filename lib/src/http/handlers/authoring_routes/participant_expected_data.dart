part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin ParticipantExpectedDataRoutes on AuthoringRoutesBase {
  @override
  void registerParticipantExpectedDataRoutes(Router router) {
    router.post(
      '/protocol/participant-expected-data/role',
      _addExpectedParticipantDataForRole,
    );
    router.post(
      '/protocol/participant-expected-data/all',
      _addExpectedParticipantDataForAllRoles,
    );
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/participant-expected-data/role',
    summary: 'Add expected participant data for a specific role',
    operationId: 'addExpectedParticipantDataForRole',
    description:
        'Adds expected participant data assigned to a specific role. Requires sessionId and roleName.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
        type: 'string',
        required: true,
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'roleName',
        location: 'query',
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
  Response _addExpectedParticipantDataForRole(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _requireQueryParam(
        request,
        'roleName',
        'Missing roleName. Provide ?roleName=... query parameter.',
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
    path: '/protocol/participant-expected-data/all',
    summary: 'Add expected participant data for all roles',
    operationId: 'addExpectedParticipantDataForAllRoles',
    description:
        'Adds expected participant data assigned to all roles. Requires sessionId and dataType.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
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
  Response _addExpectedParticipantDataForAllRoles(Request request) {
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
