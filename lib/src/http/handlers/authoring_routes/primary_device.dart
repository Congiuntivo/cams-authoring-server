part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin PrimaryDeviceRoutes on AuthoringRoutesBase {
  @override
  void registerPrimaryDeviceRoutes(Router router) {
    router.get('/sessions/<sessionId>/primary-device', _getPrimarydevice);
    router.post('/sessions/<sessionId>/primary-device', _addPrimaryDevice);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/primary-device',
    summary: 'Get primary device from the session protocol',
    operationId: 'getPrimarydevice',
    tags: <String>['Primary Device'],
    description:
        'Returns the primary device currently configured in the session protocol, including role name and serialized device payload.',
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
        description: 'Primary device returned',
        schemaRef: 'PrimaryDeviceResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing session id or no primary device configured',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _getPrimarydevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getPrimarydevice(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/primary-device',
    summary: 'Add a primary device to the session protocol',
    operationId: 'addPrimaryDevice',
    tags: <String>['Primary Device'],
    description:
        'Adds a primary device to the session protocol using deviceType (smartphone or browser).',
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
      schemaRef: 'PrimaryDeviceRequest',
      description: 'Primary device payload.',
      required: true,
      example: <String, Object?>{
        'deviceType': 'smartphone',
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
        description: 'Missing query parameters or incompatible protocol type',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addPrimaryDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = PrimaryDeviceRequest.fromJson(body);
      final deviceType = _requireStringValue(
        payload.deviceType,
        'deviceType',
        'Missing deviceType. Provide deviceType in request body.',
      );
      final roleName = payload.roleName;

      late final Map<String, dynamic> stateJson;
      switch (deviceType) {
        case 'smartphone':
          stateJson = _service.addSmartphonePrimaryDevice(sessionId, roleName);
          break;
        case 'browser':
          stateJson = _service.addBrowserPrimaryDevice(sessionId, roleName);
          break;
        default:
          throw const _BadRequestException(
            'Unsupported deviceType. Supported values: smartphone, browser.',
          );
      }

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
