part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin ServicesRoutes on AuthoringRoutesBase {
  @override
  void registerServicesRoutes(Router router) {
    router.get('/protocol/services', _getServices);
    router.post('/protocol/services/weather', _addWeatherService);
    router.post('/protocol/services/air-quality', _addAirQualityService);
  }

  @ApiOperation(
    method: 'get',
    path: '/protocol/services',
    summary: 'Get service role names from the session protocol',
    operationId: 'getServiceRoles',
    description:
        'Returns connected service role names currently configured in the session protocol. Requires sessionId.',
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
        description: 'Service role names returned',
        schemaRef: 'ServiceRolesResponse',
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
  Response _getServices(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getServices(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/services/weather',
    summary: 'Add weather service to the session protocol',
    operationId: 'addWeatherService',
    description:
        'Adds weather service as a connected device. Requires sessionId and a configured primary device.',
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
        description: 'Optional role name for the weather service.',
        example: 'Local Weather',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Weather service added',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing query parameters or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _addWeatherService(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');
      final stateJson = _service.addWeatherService(sessionId, roleName);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/services/air-quality',
    summary: 'Add air quality service to the session protocol',
    operationId: 'addAirQualityService',
    description:
        'Adds air quality service as a connected device. Requires sessionId and a configured primary device.',
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
        description: 'Optional role name for the air quality service.',
        example: 'Local Air Quality',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Air quality service added',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing query parameters or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _addAirQualityService(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');
      final stateJson = _service.addAirQualityService(sessionId, roleName);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
