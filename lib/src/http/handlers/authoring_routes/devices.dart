part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'DeviceRolesResponse',
      required: <String>['devices'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'devices',
          type: 'array',
          itemsRef: 'NamedDevice',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'BaseConnectedDeviceRequest',
      required: <String>['primaryDeviceRoleName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'roleName', type: 'string'),
        ApiPropertyDoc(
          name: 'primaryDeviceRoleName',
          type: 'string',
          required: true,
          example: 'User Phone',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ESenseDeviceRequest',
      allOfRefs: <String>['BaseConnectedDeviceRequest'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'isOptional', type: 'boolean'),
        ApiPropertyDoc(name: 'samplingRate', type: 'integer'),
      ],
    ),
    ApiSchemaDoc(
      name: 'MovesenseDeviceRequest',
      allOfRefs: <String>['BaseConnectedDeviceRequest'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'isOptional', type: 'boolean'),
      ],
    ),
    ApiSchemaDoc(
      name: 'MovisensDeviceRequest',
      allOfRefs: <String>['BaseConnectedDeviceRequest'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'sensorLocation',
          type: 'string',
          enumValues: <String>[
            'RightSideHip',
            'Chest',
            'RightWrist',
            'LeftWrist',
            'LeftAnkle',
            'RightAnkle',
            'RightThigh',
            'LeftThigh',
            'RightUpperArm',
            'LeftUpperArm',
            'LeftSideHip',
          ],
        ),
        ApiPropertyDoc(
          name: 'sex',
          type: 'string',
          enumValues: <String>['Male', 'Female', 'Intersex'],
        ),
        ApiPropertyDoc(name: 'height', type: 'integer'),
        ApiPropertyDoc(name: 'weight', type: 'integer'),
        ApiPropertyDoc(name: 'age', type: 'integer'),
      ],
    ),
    ApiSchemaDoc(
      name: 'PolarDeviceRequest',
      allOfRefs: <String>['BaseConnectedDeviceRequest'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'isOptional', type: 'boolean'),
        ApiPropertyDoc(name: 'namePrefix', type: 'string'),
      ],
    ),
  ],
)
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
    sharedParameterRefs: <String>['sessionId'],
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
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'ESenseDeviceRequest',
      description: 'eSense device payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Left Earbud',
        'primaryDeviceRoleName': 'User Phone',
        'isOptional': false,
        'samplingRate': 10,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'eSense device added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing or invalid request body values, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addESenseDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = ESenseDeviceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final primaryDeviceRoleName = _requireStringValue(
        payload.primaryDeviceRoleName,
        'primaryDeviceRoleName',
        'Missing primaryDeviceRoleName. Provide primaryDeviceRoleName in request body.',
      );
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
        primaryDeviceRoleName,
        isOptional,
        samplingRate,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
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
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'MovesenseDeviceRequest',
      description: 'Movesense device payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Chest Sensor',
        'primaryDeviceRoleName': 'User Phone',
        'isOptional': false,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Movesense device added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing or invalid request body values, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addMovesenseDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = MovesenseDeviceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final primaryDeviceRoleName = _requireStringValue(
        payload.primaryDeviceRoleName,
        'primaryDeviceRoleName',
        'Missing primaryDeviceRoleName. Provide primaryDeviceRoleName in request body.',
      );
      final isOptional = _parseOptionalBoolValue(
        payload.isOptional,
        'isOptional',
      );

      final stateJson = _service.addMovesenseDevice(
        sessionId,
        roleName,
        primaryDeviceRoleName,
        isOptional,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
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
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'MovisensDeviceRequest',
      description: 'Movisens device payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Torso Sensor',
        'primaryDeviceRoleName': 'User Phone',
        'sensorLocation': 'Chest',
        'sex': 'Male',
        'height': 178,
        'weight': 78,
        'age': 25,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Movisens device added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing or invalid request body values, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addMovisensDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = MovisensDeviceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final primaryDeviceRoleName = _requireStringValue(
        payload.primaryDeviceRoleName,
        'primaryDeviceRoleName',
        'Missing primaryDeviceRoleName. Provide primaryDeviceRoleName in request body.',
      );
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
        primaryDeviceRoleName,
        sensorLocation,
        sex,
        height,
        weight,
        age,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
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
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'PolarDeviceRequest',
      description: 'Polar device payload.',
      required: true,
      example: <String, Object?>{
        'roleName': 'Polar Chest Sensor',
        'primaryDeviceRoleName': 'User Phone',
        'isOptional': false,
        'namePrefix': 'Polar',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Polar device added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Missing or invalid request body values, or primary device not configured',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addPolarDevice(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = PolarDeviceRequest.fromJson(body);

      final roleName = _parseOptionalStringValue(payload.roleName, 'roleName');
      final primaryDeviceRoleName = _requireStringValue(
        payload.primaryDeviceRoleName,
        'primaryDeviceRoleName',
        'Missing primaryDeviceRoleName. Provide primaryDeviceRoleName in request body.',
      );
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
        primaryDeviceRoleName,
        isOptional,
        namePrefix,
      );
      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  int? _parseOptionalSamplingRate(Object? raw) {
    return _parseOptionalIntValue(raw, 'samplingRate');
  }

  int? _parseOptionalIntegerParam(Object? raw, String paramName) {
    return _parseOptionalIntValue(raw, paramName);
  }
}
