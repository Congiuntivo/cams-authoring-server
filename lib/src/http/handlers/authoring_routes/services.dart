part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'ServiceRolesResponse',
      required: <String>['services'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'services',
          type: 'array',
          itemsRef: 'NamedDevice',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'WeatherServiceRequest',
      allOfRefs: <String>['BaseConnectedDeviceRequest'],
    ),
    ApiSchemaDoc(
      name: 'AirQualityServiceRequest',
      allOfRefs: <String>['BaseConnectedDeviceRequest'],
    ),
    ApiSchemaDoc(
      name: 'HealthServiceRequest',
      allOfRefs: <String>['BaseConnectedDeviceRequest'],
    ),
    ApiSchemaDoc(
      name: 'LocationServiceRequest',
      allOfRefs: <String>['BaseConnectedDeviceRequest'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'accuracy',
          type: 'string',
          enumValues: <String>[
            'powerSave',
            'low',
            'balanced',
            'high',
            'navigation',
            'reduced',
          ],
        ),
        ApiPropertyDoc(name: 'distance', type: 'number'),
        ApiPropertyDoc(name: 'interval', ref: 'DurationRequest'),
        ApiPropertyDoc(name: 'notificationTitle', type: 'string'),
        ApiPropertyDoc(name: 'notificationMessage', type: 'string'),
        ApiPropertyDoc(name: 'notificationDescription', type: 'string'),
        ApiPropertyDoc(name: 'notificationIconName', type: 'string'),
        ApiPropertyDoc(name: 'notificationOnTapBringToFront', type: 'boolean'),
      ],
    ),
  ],
)
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
    description: 'Returns connected services currently configured in the '
        'session protocol, including role name and serialized service '
        'payload. Each service object contains a __type discriminator '
        'identifying the concrete CARP service type.',
    sharedParameterRefs: <String>['sessionId'],
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
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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
    description: 'Adds a background weather data service to the session '
        'protocol. primaryDeviceRoleName must match an existing primary '
        'device role. roleName defaults to "Weather" if omitted. The '
        'service collects ambient weather data from an online API.',
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'WeatherServiceRequest',
      description: 'Weather service configuration payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Local Weather',
        'primaryDeviceRoleName': 'User Phone',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Weather service added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing or invalid request body, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addWeatherService(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = WeatherServiceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final primaryDeviceRoleName = _requireStringValue(
        payload.primaryDeviceRoleName,
        'primaryDeviceRoleName',
        'Missing primaryDeviceRoleName. Provide primaryDeviceRoleName in request body.',
      );
      final stateJson = _service.addWeatherService(
        sessionId,
        roleName,
        primaryDeviceRoleName,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/services/air-quality',
    summary: 'Add air quality service to the session protocol',
    operationId: 'addAirQualityService',
    tags: <String>['Services'],
    description: 'Adds a background air quality data service to the session '
        'protocol. primaryDeviceRoleName must match an existing primary '
        'device role. roleName defaults to "Air Quality" if omitted. The '
        'service collects ambient air quality readings from an online API.',
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'AirQualityServiceRequest',
      description: 'Air quality service configuration payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Local Air Quality',
        'primaryDeviceRoleName': 'User Phone',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Air quality service added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing or invalid request body, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addAirQualityService(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = AirQualityServiceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final primaryDeviceRoleName = _requireStringValue(
        payload.primaryDeviceRoleName,
        'primaryDeviceRoleName',
        'Missing primaryDeviceRoleName. Provide primaryDeviceRoleName in request body.',
      );
      final stateJson = _service.addAirQualityService(
        sessionId,
        roleName,
        primaryDeviceRoleName,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/services/health',
    summary: 'Add health service to the session protocol',
    operationId: 'addHealthService',
    tags: <String>['Services'],
    description: 'Adds a background health data service to the session '
        'protocol. primaryDeviceRoleName must match an existing primary '
        'device role. roleName defaults to "Health" if omitted. The service '
        'reads health data from the platform health framework (Apple Health '
        'or Google Fit).',
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'HealthServiceRequest',
      description: 'Health service configuration payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Device Health',
        'primaryDeviceRoleName': 'User Phone',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Health service added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing or invalid request body, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addHealthService(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = HealthServiceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final primaryDeviceRoleName = _requireStringValue(
        payload.primaryDeviceRoleName,
        'primaryDeviceRoleName',
        'Missing primaryDeviceRoleName. Provide primaryDeviceRoleName in request body.',
      );
      final stateJson = _service.addHealthService(
        sessionId,
        roleName,
        primaryDeviceRoleName,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/services/location',
    summary: 'Add location service to the session protocol',
    operationId: 'addLocationService',
    tags: <String>['Services'],
    description: 'Adds a background location service to the session protocol. '
        'primaryDeviceRoleName must match an existing primary device role. '
        'roleName defaults to "Location" if omitted. accuracy controls the '
        'GPS accuracy level; distance sets the minimum movement threshold in '
        'meters; notificationTitle and notificationMessage configure the '
        'background location notification on Android.',
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'LocationServiceRequest',
      description: 'Location service configuration payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'User Location',
        'primaryDeviceRoleName': 'User Phone',
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
        statusCode: HttpStatus.created,
        description: 'Location service added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing or invalid request body, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addLocationService(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = LocationServiceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final primaryDeviceRoleName = _requireStringValue(
        payload.primaryDeviceRoleName,
        'primaryDeviceRoleName',
        'Missing primaryDeviceRoleName. Provide primaryDeviceRoleName in request body.',
      );
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
        primaryDeviceRoleName,
        accuracy,
        distance,
        interval,
        notificationTitle,
        notificationMessage,
        notificationDescription,
        notificationIconName,
        notificationOnTapBringToFront,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
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
