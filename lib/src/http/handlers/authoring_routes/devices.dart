part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin DevicesRoutes on AuthoringRoutesBase {
  @override
  void registerDeviceRoutes(Router router) {
    router.get('/sessions/<sessionId>/devices', _getDevices);
    router.post('/sessions/<sessionId>/devices/e-sense', _addESenseDevice);
    router.post('/sessions/<sessionId>/devices/movesense', _addMovesenseDevice);
    router.post('/sessions/<sessionId>/devices/movisens', _addMovisensDevice);
    router.post('/sessions/<sessionId>/devices/polar', _addPolarDevice);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/devices',
    summary: 'Get connected devices from the session protocol',
    operationId: 'getDeviceRoles',
    tags: <String>['Devices'],
    description:
        'Returns connected devices currently configured in the session protocol, including role name and serialized device payload.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
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
        description: 'Connected devices returned',
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
  Future<Response> _getDevices(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getDevices(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/devices/e-sense',
    summary: 'Add an eSense device to the session protocol',
    operationId: 'addESenseDevice',
    tags: <String>['Devices'],
    description:
        'Adds an eSense device as a connected device. Requires a configured primary device.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
        example: 'session_1234567890_1',
      ),
    ],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'ESenseDeviceRequest',
      description: 'eSense device payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Left Earbud',
        'isOptional': false,
        'samplingRate': 10,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'eSense device added',
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
  Future<Response> _addESenseDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = ESenseDeviceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final isOptional = _parseOptionalBoolValue(
        payload.isOptional,
        'isOptional',
      );
      final samplingRate = _parseOptionalSamplingRate(
        payload.samplingRate,
      );

      final stateJson = _service.addESenseDevice(
        sessionId,
        roleName,
        isOptional,
        samplingRate,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/devices/movesense',
    summary: 'Add a Movesense device to the session protocol',
    operationId: 'addMovesenseDevice',
    tags: <String>['Devices'],
    description:
        'Adds a Movesense device as a connected device. Requires a configured primary device.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
        example: 'session_1234567890_1',
      ),
    ],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'MovesenseDeviceRequest',
      description: 'Movesense device payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Chest Sensor',
        'isOptional': false,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Movesense device added',
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
  Future<Response> _addMovesenseDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = MovesenseDeviceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final isOptional = _parseOptionalBoolValue(
        payload.isOptional,
        'isOptional',
      );

      final stateJson = _service.addMovesenseDevice(
        sessionId,
        roleName,
        isOptional,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/devices/movisens',
    summary: 'Add a Movisens device to the session protocol',
    operationId: 'addMovisensDevice',
    tags: <String>['Devices'],
    description:
        'Adds a Movisens device as a connected device. Requires a configured primary device.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
        example: 'session_1234567890_1',
      ),
    ],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'MovisensDeviceRequest',
      description: 'Movisens device payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Torso Sensor',
        'sensorLocation': 'Chest',
        'sex': 'Male',
        'height': 178,
        'weight': 78,
        'age': 25,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Movisens device added',
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
  Future<Response> _addMovisensDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = MovisensDeviceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final sensorLocation = _parseOptionalStringValue(
        payload.sensorLocation,
        'sensorLocation',
      );
      final sex = _parseOptionalStringValue(payload.sex, 'sex');
      final height = _parseOptionalIntegerParam(
        payload.height,
        'height',
      );
      final weight = _parseOptionalIntegerParam(
        payload.weight,
        'weight',
      );
      final age = _parseOptionalIntegerParam(
        payload.age,
        'age',
      );

      final stateJson = _service.addMovisensDevice(
        sessionId,
        roleName,
        sensorLocation,
        sex,
        height,
        weight,
        age,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/devices/polar',
    summary: 'Add a Polar device to the session protocol',
    operationId: 'addPolarDevice',
    tags: <String>['Devices'],
    description:
        'Adds a Polar device as a connected device. Requires a configured primary device.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
        example: 'session_1234567890_1',
      ),
    ],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'PolarDeviceRequest',
      description: 'Polar device payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Polar Chest Sensor',
        'isOptional': false,
        'namePrefix': 'Polar',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Polar device added',
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
  Future<Response> _addPolarDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = PolarDeviceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final isOptional = _parseOptionalBoolValue(
        payload.isOptional,
        'isOptional',
      );
      final namePrefix = _parseOptionalStringValue(
        payload.namePrefix,
        'namePrefix',
      );

      final stateJson = _service.addPolarDevice(
        sessionId,
        roleName,
        isOptional,
        namePrefix,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  int? _parseOptionalSamplingRate(Object? raw) {
    return _parseOptionalIntValue(raw, 'samplingRate');
  }

  int? _parseOptionalIntegerParam(Object? raw, String paramName) {
    return _parseOptionalIntValue(raw, paramName);
  }
}
