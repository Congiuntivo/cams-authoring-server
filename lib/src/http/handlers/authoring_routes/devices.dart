part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin DevicesRoutes on AuthoringRoutesBase {
  @override
  void registerDeviceRoutes(Router router) {
    router.get('/protocol/devices', _getDevices);
    router.post('/protocol/devices/e-sense', _addESenseDevice);
    router.post('/protocol/devices/movesense', _addMovesenseDevice);
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

  @ApiOperation(
    method: 'post',
    path: '/protocol/devices/e-sense',
    summary: 'Add an eSense device to the session protocol',
    operationId: 'addESenseDevice',
    description:
        'Adds an eSense device as a connected device. Requires sessionId and a configured primary device.',
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
        description: 'Optional role name for the eSense device.',
        example: 'Left Earbud',
      ),
      ApiParameterDoc(
        name: 'isOptional',
        location: 'query',
        type: 'boolean',
        required: false,
        description: 'Optional flag indicating whether the device is optional.',
        example: 'false',
      ),
      ApiParameterDoc(
        name: 'deviceName',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional bluetooth name of the eSense device.',
        example: 'eSense-1234',
      ),
      ApiParameterDoc(
        name: 'samplingRate',
        location: 'query',
        type: 'integer',
        required: false,
        description:
            'Optional sampling rate in Hz. Defaults to 10 when not provided.',
        example: '10',
      ),
    ],
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
  Response _addESenseDevice(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');
      final isOptional = _parseOptionalBool(
        _optionalTrimmedQueryParam(request, 'isOptional'),
        'isOptional',
      );
      final deviceName = _optionalTrimmedQueryParam(request, 'deviceName');
      final samplingRate = _parseOptionalSamplingRate(
        _optionalTrimmedQueryParam(request, 'samplingRate'),
      );

      final stateJson = _service.addESenseDevice(
        sessionId,
        roleName,
        isOptional,
        deviceName,
        samplingRate,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/devices/movesense',
    summary: 'Add a Movesense device to the session protocol',
    operationId: 'addMovesenseDevice',
    description:
        'Adds a Movesense device as a connected device. Requires sessionId and a configured primary device.',
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
        description: 'Optional role name for the Movesense device.',
        example: 'Chest Sensor',
      ),
      ApiParameterDoc(
        name: 'isOptional',
        location: 'query',
        type: 'boolean',
        required: false,
        description: 'Optional flag indicating whether the device is optional.',
        example: 'false',
      ),
      ApiParameterDoc(
        name: 'name',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional bluetooth display name of the Movesense device.',
        example: 'Movesense 1234',
      ),
      ApiParameterDoc(
        name: 'address',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'Optional bluetooth address (MAC on Android, UUID on iOS).',
        example: 'AA:BB:CC:DD:EE:FF',
      ),
      ApiParameterDoc(
        name: 'serial',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional Movesense serial number.',
        example: '220330000122',
      ),
      ApiParameterDoc(
        name: 'deviceType',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Optional Movesense device type.',
        example: 'UNKNOWN',
        enumValues: <String>['UNKNOWN', 'MD', 'HR_PLUS', 'HR2', 'FLASH'],
      ),
    ],
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
  Response _addMovesenseDevice(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');
      final isOptional = _parseOptionalBool(
        _optionalTrimmedQueryParam(request, 'isOptional'),
        'isOptional',
      );
      final name = _optionalTrimmedQueryParam(request, 'name');
      final address = _optionalTrimmedQueryParam(request, 'address');
      final serial = _optionalTrimmedQueryParam(request, 'serial');
      final deviceType = _optionalTrimmedQueryParam(request, 'deviceType');

      final stateJson = _service.addMovesenseDevice(
        sessionId,
        roleName,
        isOptional,
        name,
        address,
        serial,
        deviceType,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  int? _parseOptionalSamplingRate(String? raw) {
    if (raw == null) return null;

    final parsed = int.tryParse(raw);
    if (parsed == null) {
      throw _BadRequestException(
        'Invalid integer value for samplingRate. Use an integer.',
      );
    }
    return parsed;
  }
}
