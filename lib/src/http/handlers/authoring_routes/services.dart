part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin ServicesRoutes on AuthoringRoutesBase {
  @override
  void registerServicesRoutes(Router router) {
    router.get('/protocol/services', _getServices);
    router.post('/protocol/services/weather', _addWeatherService);
    router.post('/protocol/services/air-quality', _addAirQualityService);
    router.post('/protocol/services/health', _addHealthService);
    router.post('/protocol/services/location', _addLocationService);
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

  @ApiOperation(
    method: 'post',
    path: '/protocol/services/health',
    summary: 'Add health service to the session protocol',
    operationId: 'addHealthService',
    description:
        'Adds health service as a connected device. Requires sessionId and a configured primary device.',
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
  Response _addHealthService(Request request) {
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
    path: '/protocol/services/location',
    summary: 'Add location service to the session protocol',
    operationId: 'addLocationService',
    description:
        'Adds location service as a connected device. Requires sessionId and a configured primary device.',
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
        description: 'Optional role name for the location service.',
        example: 'User Location',
      ),
      ApiParameterDoc(
        name: 'accuracy',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'Optional geolocation accuracy value from GeolocationAccuracy enum.',
        example: 'balanced',
        enumValues: <String>[
          'powerSave',
          'low',
          'balanced',
          'high',
          'navigation',
          'reduced',
        ],
      ),
      ApiParameterDoc(
        name: 'distance',
        location: 'query',
        type: 'number',
        required: false,
        description:
            'Optional distance in meters that triggers location updates.',
        example: '10.0',
      ),
      ApiParameterDoc(
        name: 'intervalSeconds',
        location: 'query',
        type: 'integer',
        required: false,
        description:
            'Optional polling interval in seconds used for location updates.',
        example: '60',
      ),
      ApiParameterDoc(
        name: 'notificationTitle',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional foreground notification title.',
        example: 'Tracking active',
      ),
      ApiParameterDoc(
        name: 'notificationMessage',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional foreground notification message.',
        example: 'Location tracking is running.',
      ),
      ApiParameterDoc(
        name: 'notificationDescription',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional foreground notification description.',
        example: 'Tap to return to the app.',
      ),
      ApiParameterDoc(
        name: 'notificationIconName',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional Android notification icon name.',
        example: 'ic_notification',
      ),
      ApiParameterDoc(
        name: 'notificationOnTapBringToFront',
        location: 'query',
        type: 'boolean',
        required: false,
        description:
            'Optional boolean to decide if notification tap should bring app to front.',
        example: 'false',
      ),
    ],
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
  Response _addLocationService(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');
      final accuracy = _optionalTrimmedQueryParam(request, 'accuracy');
      final distance = _parseOptionalDistance(
        _optionalTrimmedQueryParam(request, 'distance'),
      );
      final interval = _parseOptionalInterval(
        _optionalTrimmedQueryParam(request, 'intervalSeconds'),
      );
      final notificationTitle =
          _optionalTrimmedQueryParam(request, 'notificationTitle');
      final notificationMessage =
          _optionalTrimmedQueryParam(request, 'notificationMessage');
      final notificationDescription =
          _optionalTrimmedQueryParam(request, 'notificationDescription');
      final notificationIconName =
          _optionalTrimmedQueryParam(request, 'notificationIconName');
      final notificationOnTapBringToFront = _parseOptionalBool(
        _optionalTrimmedQueryParam(request, 'notificationOnTapBringToFront'),
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

  double? _parseOptionalDistance(String? raw) {
    if (raw == null) return null;

    final parsed = double.tryParse(raw);
    if (parsed == null) {
      throw _BadRequestException(
        'Invalid number value for distance. Use a numeric value.',
      );
    }
    return parsed;
  }

  Duration? _parseOptionalInterval(String? raw) {
    if (raw == null) return null;

    final seconds = int.tryParse(raw);
    if (seconds == null || seconds < 0) {
      throw _BadRequestException(
        'Invalid integer value for intervalSeconds. Use a non-negative integer.',
      );
    }

    return Duration(seconds: seconds);
  }
}
