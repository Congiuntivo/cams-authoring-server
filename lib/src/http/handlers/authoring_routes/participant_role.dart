part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'AddParticipantRoleRequest',
      required: <String>['roleName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleName',
          type: 'string',
          required: true,
          example: 'Patient',
        ),
        ApiPropertyDoc(
          name: 'isOptional',
          type: 'boolean',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ParticipantRolesResponse',
      required: <String>['roleNames'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleNames',
          type: 'array',
          itemsType: 'string',
          required: true,
        ),
      ],
    ),
  ],
)
mixin ParticipantRoleRoutes on AuthoringRoutesBase {
  @override
  void registerParticipantRoleRoutes(Router router) {
    router.get('/sessions/<sessionId>/participant-roles', _getParticipantRoles);
    router.post('/sessions/<sessionId>/participant-roles', _addParticipantRole);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/participant-roles',
    summary: 'Get participant role names from the session protocol',
    operationId: 'getParticipantRoles',
    tags: <String>['Participant Roles'],
    description:
        'Returns participant role names currently configured in the session protocol.',
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
  Future<Response> _getParticipantRoles(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getParticipantRoles(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/participant-roles',
    summary: 'Add a participant role to the protocol in the session',
    operationId: 'addParticipantRole',
    tags: <String>['Participant Roles'],
    description:
        'Adds a participant role. Protocol must already be started with POST /protocol/new.',
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
      schemaRef: 'AddParticipantRoleRequest',
      description: 'Participant role configuration payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Patient',
        'isOptional': false,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Participant role added',
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
  Future<Response> _addParticipantRole(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = AddParticipantRoleRequest.fromJson(body);

      final roleName = _requireStringValue(
        payload.roleName,
        'roleName',
        'Missing roleName. Provide roleName in request body.',
      );
      final isOptional =
          _parseOptionalBoolValue(payload.isOptional, 'isOptional');

      final stateJson = _service.addParticipantRole(
        sessionId,
        roleName,
        isOptional,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
