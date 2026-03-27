part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin ParticipantRoleRoutes on AuthoringRoutesBase {
  @override
  void registerParticipantRoleRoutes(Router router) {
    router.get('/protocol/participant-role', _getParticipantRoles);
    router.post('/protocol/participant-role', _addParticipantRole);
  }

  @ApiOperation(
    method: 'get',
    path: '/protocol/participant-role',
    summary: 'Get participant role names from the session protocol',
    operationId: 'getParticipantRoles',
    description:
        'Returns participant role names currently configured in the session protocol. Requires sessionId.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Participant role names returned',
        schemaRef: 'ParticipantRolesResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing session id or protocol not started',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _getParticipantRoles(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getParticipantRoles(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/participant-role',
    summary: 'Add a participant role to the protocol in the session',
    operationId: 'addParticipantRole',
    description:
        'Adds a participant role. Requires sessionId. Protocol must already be started with POST /protocol/new.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'roleName',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Participant role name.',
        example: 'Patient',
      ),
      ApiParameterDoc(
        name: 'isOptional',
        location: 'query',
        type: 'boolean',
        required: false,
        description: 'Whether the role is optional.',
        example: 'false',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Participant role added',
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
  Response _addParticipantRole(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _requireQueryParam(
        request,
        'roleName',
        'Missing roleName. Provide ?roleName=... query parameter.',
      );
      final isOptional = _parseOptionalBool(
        _optionalTrimmedQueryParam(request, 'isOptional'),
        'isOptional',
      );

      final stateJson = _service.addParticipantRole(
        sessionId,
        roleName,
        isOptional,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
