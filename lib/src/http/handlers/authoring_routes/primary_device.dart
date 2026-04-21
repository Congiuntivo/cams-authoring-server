part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'PrimaryDevicesResponse',
      required: <String>['primaryDevices'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'primaryDevices',
          type: 'array',
          itemsRef: 'NamedDevice',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'PrimaryDeviceRoleRequest',
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleName',
          type: 'string',
          required: false,
          example: 'User Phone',
        ),
      ],
    ),
  ],
)
mixin PrimaryDeviceRoutes on AuthoringRoutesBase {
  @override
  void registerPrimaryDeviceRoutes(Router router) {
    router.get('/sessions/<sessionId>/primary-devices', _getPrimaryDevices);
    router.post(
      '/sessions/<sessionId>/primary-devices/smartphone',
      _addSmartphonePrimaryDevice,
    );
    router.post(
      '/sessions/<sessionId>/primary-devices/web-browser',
      _addWebBrowserPrimaryDevice,
    );
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/primary-devices',
    summary: 'Get primary devices from the session protocol',
    operationId: 'getPrimaryDevices',
    tags: <String>['Primary Devices'],
    description:
        'Returns primary devices currently configured in the session protocol, including role name and serialized device payload.',
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
        description: 'Primary devices returned',
        schemaRef: 'PrimaryDevicesResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing session id',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _getPrimaryDevices(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getPrimaryDevices(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/primary-devices/smartphone',
    summary: 'Add a smartphone primary device to the session protocol',
    operationId: 'addSmartphonePrimaryDevice',
    tags: <String>['Primary Devices'],
    description:
        'Adds a smartphone as a primary device in the session protocol.',
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
      schemaRef: 'PrimaryDeviceRoleRequest',
      description: 'Optional role name for the primary smartphone.',
      required: true,
      example: <String, Object?>{
        'roleName': 'User Phone',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Primary device added',
        schemaRef: 'RequirementsResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing session id, invalid payload, or incompatible protocol type',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addSmartphonePrimaryDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = PrimaryDeviceRoleRequest.fromJson(body);
      final roleName = payload.roleName;

      final stateJson =
          _service.addSmartphonePrimaryDevice(sessionId, roleName);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/primary-devices/web-browser',
    summary: 'Add a web browser primary device to the session protocol',
    operationId: 'addWebBrowserPrimaryDevice',
    tags: <String>['Primary Devices'],
    description:
        'Adds a web browser as a primary device in the session protocol.',
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
      schemaRef: 'PrimaryDeviceRoleRequest',
      description: 'Optional role name for the primary web browser.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Participant Browser',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Primary device added',
        schemaRef: 'RequirementsResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing session id, invalid payload, or incompatible protocol type',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addWebBrowserPrimaryDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = PrimaryDeviceRoleRequest.fromJson(body);
      final roleName = payload.roleName;

      final stateJson = _service.addBrowserPrimaryDevice(sessionId, roleName);

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
