part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin ServicesRoutes on AuthoringRoutesBase {
  @override
  void registerServicesRoutes(Router router) {
    router.get('/sessions/<sessionId>/services', _getServices);
    router.post('/sessions/<sessionId>/services/weather', _addWeatherService);
    router.post(
        '/sessions/<sessionId>/services/air-quality', _addAirQualityService);
    router.post('/sessions/<sessionId>/services/health', _addHealthService);
    router.post('/sessions/<sessionId>/services/location', _addLocationService);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/services',
    summary: 'Get connected services from the session protocol',
    operationId: 'getServiceRoles',
    tags: <String>['Services'],
    description:
        'Returns connected services currently configured in the session protocol, including role name and serialized service payload.',
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
        description: 'Connected services returned',
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
  Future<Response> _getServices(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getServices(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/services/weather',
    summary: 'Add weather service to the session protocol',
    operationId: 'addWeatherService',
    tags: <String>['Services'],
    description:
        'Adds weather service as a connected device. Requires a configured primary device.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
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
  Future<Response> _addWeatherService(Request request) async {
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
    path: '/sessions/{sessionId}/services/air-quality',
    summary: 'Add air quality service to the session protocol',
    operationId: 'addAirQualityService',
    tags: <String>['Services'],
    description:
        'Adds air quality service as a connected device. Requires a configured primary device.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
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
  Future<Response> _addAirQualityService(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');
      final stateJson = _service.addAirQualityService(sessionId, roleName);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/services/health',
    summary: 'Add health service to the session protocol',
    operationId: 'addHealthService',
    tags: <String>['Services'],
    description:
        'Adds health service as a connected device. Requires a configured primary device.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'roleName',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional role name for the health service.',
        example: 'Device Health',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Health service added',
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
  Future<Response> _addHealthService(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');
      final stateJson = _service.addHealthService(sessionId, roleName);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/services/location',
    summary: 'Add location service to the session protocol',
    operationId: 'addLocationService',
    tags: <String>['Services'],
    description:
        'Adds location service as a connected device. Requires a configured primary device.',
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
      schemaRef: 'LocationServiceRequest',
      description: 'Location service configuration payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'User Location',
        'accuracy': 'balanced',
        'distance': 10.0,
        'interval': <String, Object?>{'seconds': 60},
        'notificationTitle': 'Tracking active',
        'notificationMessage': 'Location tracking is running.',
        'notificationDescription': 'Tap to return to the app.',
        'notificationIconName': 'ic_notification',
        'notificationOnTapBringToFront': false,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Location service added',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing query parameters, invalid values, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addLocationService(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = LocationServiceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final accuracy = _parseOptionalStringValue(payload.accuracy, 'accuracy');
      final distance = _parseOptionalDistance(payload.distance);
      final interval = payload.interval?.toDuration();
      final notificationTitle = _parseOptionalStringValue(
        payload.notificationTitle,
        'notificationTitle',
      );
      final notificationMessage = _parseOptionalStringValue(
        payload.notificationMessage,
        'notificationMessage',
      );
      final notificationDescription = _parseOptionalStringValue(
        payload.notificationDescription,
        'notificationDescription',
      );
      final notificationIconName = _parseOptionalStringValue(
        payload.notificationIconName,
        'notificationIconName',
      );
      final notificationOnTapBringToFront = _parseOptionalBoolValue(
        payload.notificationOnTapBringToFront,
        'notificationOnTapBringToFront',
      );

      final stateJson = _service.addLocationService(
        sessionId,
        roleName,
        accuracy,
        distance,
        interval,
        notificationTitle,
        notificationMessage,
        notificationDescription,
        notificationIconName,
        notificationOnTapBringToFront,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  double? _parseOptionalDistance(Object? raw) {
    if (raw == null) return null;

    final parsed = _parseOptionalDoubleValue(raw, 'distance');
    if (parsed == null) {
      throw _BadRequestException(
        'Invalid number value for distance. Use a numeric value.',
      );
    }
    return parsed;
  }
}
