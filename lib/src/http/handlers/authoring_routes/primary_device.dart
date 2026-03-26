part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin PrimaryDeviceRoutes on AuthoringRoutesBase {
  @override
  void registerPrimaryDeviceRoutes(Router router) {
    router.post('/protocol/primary-device', _addPrimaryDevice);
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/primary-device',
    summary: 'Add a primary device to the protocol in the session',
    operationId: 'addPrimaryDevice',
    description:
        'Adds a primary device to the session protocol. Requires sessionId. Protocol must already be started with POST /protocol/new.',
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
        name: 'deviceType',
        location: 'query',
        type: 'string',
        enumValues: AuthoringRoutesBase.supportedDeviceTypes,
        required: true,
        description: 'Device type. Supported values: smartphone, browser.',
        example: 'smartphone',
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
  Response _addPrimaryDevice(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final deviceType = _requireEnumQueryParam(
        request,
        'deviceType',
        AuthoringRoutesBase.supportedDeviceTypes,
        missingMessage:
            'Missing deviceType. Provide ?deviceType=... query parameter. Supported values: ${AuthoringRoutesBase.supportedDeviceTypes.join(', ')}.',
      );
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');

      final stateJson = _service.addPrimaryDevice(
        sessionId,
        deviceType,
        roleName,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
