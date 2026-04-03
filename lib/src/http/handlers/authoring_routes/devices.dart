part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin DevicesRoutes on AuthoringRoutesBase {
  @override
  void registerDeviceRoutes(Router router) {
    router.get('/protocol/devices', _getDevices);
  }

  @ApiOperation(
    method: 'get',
    path: '/protocol/devices',
    summary: 'Get connected device role names from the session protocol',
    operationId: 'getDeviceRoles',
    description:
        'Returns connected device role names currently configured in the session protocol. Requires sessionId.',
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
        description: 'Device role names returned',
        schemaRef: 'DeviceRolesResponse',
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
  Response _getDevices(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getDevices(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
