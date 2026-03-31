part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin PrimaryDeviceRoutes on AuthoringRoutesBase {
  @override
  void registerPrimaryDeviceRoutes(Router router) {
    router.get('/protocol/primary-device', _getPrimarydevice);
    router.post(
      '/protocol/primary-device/smartphone',
      _addSmartphonePrimaryDevice,
    );
    router.post('/protocol/primary-device/browser', _addBrowserPrimaryDevice);
  }

  @ApiOperation(
    method: 'get',
    path: '/protocol/primary-device',
    summary: 'Get primary device role name from the session protocol',
    operationId: 'getPrimarydevice',
    description:
        'Returns the role name of the primary device in the session protocol. Requires sessionId and a configured primary device.',
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
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Primary device role name returned',
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
  Response _getPrimarydevice(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getPrimarydevice(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/primary-device/smartphone',
    summary: 'Add a smartphone primary device to the session protocol',
    operationId: 'addSmartphonePrimaryDevice',
    description:
        'Adds a smartphone primary device to the session protocol. Requires sessionId and an existing smartphone protocol started with POST /protocol/new/smartphone.',
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
        required: false,
        description: 'Display name of the device.',
        example: 'User Phone',
      ),
    ],
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
  Response _addSmartphonePrimaryDevice(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');

      final stateJson = _service.addSmartphonePrimaryDevice(
        sessionId,
        roleName,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/primary-device/browser',
    summary: 'Add a browser primary device to the session protocol',
    operationId: 'addBrowserPrimaryDevice',
    description:
        'Adds a browser primary device to the session protocol. Requires sessionId and an existing default protocol started with POST /protocol/new/default.',
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
        required: false,
        description: 'Display name of the device.',
        example: 'Participant Browser',
      ),
    ],
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
  Response _addBrowserPrimaryDevice(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');

      final stateJson = _service.addBrowserPrimaryDevice(
        sessionId,
        roleName,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
