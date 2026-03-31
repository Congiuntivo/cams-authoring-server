part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

abstract class AuthoringRoutesBase {
  AuthoringRoutesBase(this._service);

  final ProtocolAuthoringService _service;

  static const String defaultProtocolName = 'Unnamed Protocol';
  static const List<String> supportedEndpointTypes = <String>['CAWS', 'SQLITE'];
  static const List<String> supportedUploadMethods = <String>[
    'stream',
    'datapoint',
    'file',
  ];
  static const List<String> supportedDeviceTypes = <String>[
    'smartphone',
    'browser',
  ];
  static const List<String> supportedParticipantDataTypes = <String>[
    'sex',
    'phone_number',
    'ssn',
    'full_name',
    'informed_consent',
    'address',
    'diagnosis',
    'custom',
  ];

  void register(Router router);

  void registerParticipantRoleRoutes(Router router);

  void registerParticipantExpectedDataRoutes(Router router);

  void registerDataEndpointRoutes(Router router);

  void registerPrimaryDeviceRoutes(Router router);

  void registerServicesRoutes(Router router);

  String? _sessionId(Request request) {
    final querySessionId = request.url.queryParameters['sessionId'];
    if (querySessionId != null && querySessionId.trim().isNotEmpty) {
      return querySessionId.trim();
    }

    return null;
  }

  Response _badRequestMissingSessionId() {
    return _badRequest(
      'Missing session id. Provide ?sessionId=... query parameter.',
    );
  }

  Response _sessionNotFoundResponse(String sessionId) {
    return jsonResponse(HttpStatus.notFound, body: <String, dynamic>{
      'error': 'Session not found: $sessionId',
    });
  }

  Response _badRequest(String message) {
    return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
      'error': message,
    });
  }

  String? _optionalTrimmedQueryParam(Request request, String name) {
    final value = request.url.queryParameters[name];
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _requireQueryParam(
    Request request,
    String name,
    String missingMessage,
  ) {
    final value = _optionalTrimmedQueryParam(request, name);
    if (value == null) {
      throw _BadRequestException(missingMessage);
    }
    return value;
  }

  String _requireEnumQueryParam(
    Request request,
    String name,
    List<String> supportedValues, {
    String? missingMessage,
  }) {
    final value = _requireQueryParam(
      request,
      name,
      missingMessage ?? 'Missing $name. Provide ?$name=... query parameter.',
    );
    _validateEnumValue(name, value, supportedValues);
    return value;
  }

  void _validateEnumValue(
    String paramName,
    String value,
    List<String> supportedValues,
  ) {
    if (!supportedValues.contains(value)) {
      throw _BadRequestException(
        'Unsupported $paramName. Supported values: '
        '${supportedValues.join(', ')}.',
      );
    }
  }

  Response _runWithErrorHandling(Response Function() body) {
    try {
      return body();
    } on SessionNotFoundException catch (error) {
      return _sessionNotFoundResponse(error.sessionId);
    } on _BadRequestException catch (error) {
      return _badRequest(error.message);
    } on FormatException catch (error) {
      return _badRequest(error.message);
    } on ArgumentError catch (error) {
      final message = error.message;
      return _badRequest(
        message == null ? error.toString() : message.toString(),
      );
    } on StateError catch (error) {
      return _badRequest(error.message);
    }
  }

  CarpUploadMethod _parseUploadMethod(String? raw) {
    if (raw == null || raw.trim().isEmpty) return CarpUploadMethod.stream;

    final normalized = raw.trim().toLowerCase();
    return switch (normalized) {
      'stream' => CarpUploadMethod.stream,
      'datapoint' => CarpUploadMethod.datapoint,
      'file' => CarpUploadMethod.file,
      _ => throw _BadRequestException(
          'Unsupported uploadMethod. Supported values: '
          '${supportedUploadMethods.join(', ')}.'),
    };
  }

  bool? _parseOptionalBool(String? raw, String paramName) {
    if (raw == null) return null;

    final normalized = raw.trim().toLowerCase();
    return switch (normalized) {
      'true' => true,
      'false' => false,
      _ => throw _BadRequestException(
          'Invalid boolean value for $paramName. Use true or false.'),
    };
  }
}

@ApiController(
  title: 'Study Protocol Authoring API',
  version: '0.4.0',
  description:
      'Stateful API exposing session-scoped protocol state and serialization endpoints.',
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'CreateSessionResponse',
      required: <String>['sessionId'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'sessionId',
          type: 'string',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DataEndpointResponse',
      required: <String>['sessionId', 'unfulfilledRequirements'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'sessionId',
          type: 'string',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'unfulfilledRequirements',
          type: 'object',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'RequirementsResponse',
      required: <String>['unfulfilledRequirements'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'unfulfilledRequirements',
          type: 'object',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'PrimaryDeviceResponse',
      required: <String>['roleName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleName',
          type: 'string',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ParticipantRolesResponse',
      required: <String>['roleNames'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleNames',
          type: 'array',
          itemsType: 'string',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'SerializeResponse',
      required: <String>['name', 'ownerId', 'version'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          example: 'My Study Protocol',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'ownerId',
          type: 'string',
          example: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'version',
          type: 'integer',
          example: 0,
          required: true,
        ),
        ApiPropertyDoc(name: 'id', type: 'string', required: false),
        ApiPropertyDoc(name: 'createdOn', type: 'string', required: false),
        ApiPropertyDoc(name: 'description', type: 'string', required: false),
        ApiPropertyDoc(
          name: 'participantRoles',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'primaryDevices',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'connectedDevices',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'tasks',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'triggers',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'taskControls',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ErrorResponse',
      required: <String>['error'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'error',
          type: 'string',
          required: true,
        ),
      ],
    ),
  ],
)
class AuthoringRoutes extends AuthoringRoutesBase
    with
        DataEndpointRoutes,
        PrimaryDeviceRoutes,
        ParticipantRoleRoutes,
        ParticipantExpectedDataRoutes,
        ServicesRoutes {
  AuthoringRoutes(super.service);

  @override
  void register(Router router) {
    router.get('/requirements', _getRequirements);
    router.post('/protocol/new/smartphone', _startNewSmartphoneProtocol);
    router.post('/protocol/new/default', _startNewDefaultProtocol);
    router.get('/serialize', _serializeProtocol);

    registerDataEndpointRoutes(router);
    registerPrimaryDeviceRoutes(router);
    registerParticipantRoleRoutes(router);
    registerParticipantExpectedDataRoutes(router);
    registerServicesRoutes(router);
  }

  @ApiOperation(
    method: 'get',
    path: '/requirements',
    summary: 'Get current unfulfilled requirements for the session',
    operationId: 'getRequirements',
    description:
        'Returns the current unfulfilled requirements for the session. Requires sessionId (will return 400 if missing or 404 if not found).',
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
        description: 'Current unfulfilled requirements for the session',
        schemaRef: 'RequirementsResponse',
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
  Response _getRequirements(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      return jsonResponse(
        HttpStatus.ok,
        body: _service.getRequirements(sessionId),
      );
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/new/smartphone',
    summary: 'Create a new smartphone protocol authoring session',
    operationId: 'createSmartphoneProtocolSession',
    description:
        'Creates an in-memory authoring session for a smartphone protocol and returns a sessionId for subsequent requests.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'name',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'Name of the protocol (optional, default: "Unnamed Protocol")',
        example: 'My Study Protocol',
      ),
      ApiParameterDoc(
        name: 'ownerId',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'UUID of the protocol owner (optional, will be generated if not provided)',
        example: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'New authoring session created',
        schemaRef: 'CreateSessionResponse',
      ),
    ],
  )
  Response _startNewSmartphoneProtocol(Request request) {
    return _runWithErrorHandling(() {
      final stateJson = _service.createNewProtocol(
        _optionalTrimmedQueryParam(request, 'name') ??
            AuthoringRoutesBase.defaultProtocolName,
        _optionalTrimmedQueryParam(request, 'ownerId'),
        true,
      );

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/new/default',
    summary: 'Create a new default protocol authoring session',
    operationId: 'createDefaultProtocolSession',
    description:
        'Creates an in-memory authoring session for a default protocol and returns a sessionId for subsequent requests.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'name',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'Name of the protocol (optional, default: "Unnamed Protocol")',
        example: 'My Study Protocol',
      ),
      ApiParameterDoc(
        name: 'ownerId',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'UUID of the protocol owner (optional, will be generated if not provided)',
        example: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'New authoring session created',
        schemaRef: 'CreateSessionResponse',
      ),
    ],
  )
  Response _startNewDefaultProtocol(Request request) {
    return _runWithErrorHandling(() {
      final stateJson = _service.createNewProtocol(
        _optionalTrimmedQueryParam(request, 'name') ??
            AuthoringRoutesBase.defaultProtocolName,
        _optionalTrimmedQueryParam(request, 'ownerId'),
        false,
      );

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'get',
    path: '/serialize',
    summary: 'Return the serialized protocol for the session',
    operationId: 'serializeProtocol',
    description:
        'Returns the serialized protocol for the session. Requires sessionId (will return 400 if missing or 404 if not found).',
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
        description: 'Serialized protocol for the session',
        schemaRef: 'SerializeResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing session id',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.conflict,
        description:
            'Protocol cannot be serialized until critical requirements are fulfilled',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _serializeProtocol(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      return jsonResponse(HttpStatus.ok, body: _service.serialize(sessionId));
    });
  }
}

class _BadRequestException implements Exception {
  const _BadRequestException(this.message);

  final String message;
}
