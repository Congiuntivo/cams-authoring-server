part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

abstract class AuthoringRoutesBase {
  AuthoringRoutesBase(this._service);

  final ProtocolAuthoringService _service;

  static const String defaultProtocolName = 'Unnamed Protocol';
  static const List<String> supportedEndpointTypes = <String>[
    'CAWS',
    'SQLITE',
    'FILE',
  ];
  static const String defaultPrivacySchemaName = 'default-privacy-schema';
  static const List<String> supportedPrivacySchemaNames = <String>[
    defaultPrivacySchemaName,
  ];
  static const List<String> supportedUploadMethods = <String>[
    'stream',
    'datapoint',
    'file',
  ];
  static final List<String> supportedParticipantDataTypes =
      AuthoringSession.inputDataTypesMap.keys.toList(growable: false);
  void register(Router router);

  void registerParticipantRoleRoutes(Router router);

  void registerParticipantExpectedDataRoutes(Router router);

  void registerDataEndpointRoutes(Router router);

  void registerPrimaryDeviceRoutes(Router router);

  void registerServicesRoutes(Router router);

  void registerDeviceRoutes(Router router);

  void registerTasksRoutes(Router router);

  void registerTaskControlsRoutes(Router router);

  void registerTriggersRoutes(Router router);

  String? _sessionId(Request request) {
    final pathSessionId = request.params['sessionId'];
    if (pathSessionId != null && pathSessionId.trim().isNotEmpty) {
      return pathSessionId.trim();
    }

    return null;
  }

  Response _badRequestMissingSessionId() {
    return _badRequest(
        'Missing session id. Provide /sessions/{sessionId}/... path parameter.');
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

  Future<Map<String, dynamic>> _requireJsonBody(Request request) async {
    final body = await request.readAsString();
    if (body.trim().isEmpty) {
      throw const _BadRequestException(
        'Missing request body. Provide a JSON object payload.',
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const _BadRequestException(
        'Invalid JSON body. Expected a JSON object.',
      );
    }

    return decoded;
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

  Future<Response> _runWithErrorHandling(
      FutureOr<Response> Function() body) async {
    try {
      return await body();
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

  bool? _parseOptionalBoolValue(Object? raw, String paramName) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is String) return _parseOptionalBool(raw, paramName);

    throw _BadRequestException(
      'Invalid boolean value for $paramName. Use true or false.',
    );
  }

  String? _parseOptionalStringValue(Object? raw, String paramName) {
    if (raw == null) return null;
    if (raw is! String) {
      throw _BadRequestException(
        'Invalid string value for $paramName. Use a text value.',
      );
    }

    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _requireStringValue(
    Object? raw,
    String paramName,
    String missingMessage,
  ) {
    final value = _parseOptionalStringValue(raw, paramName);
    if (value == null) {
      throw _BadRequestException(missingMessage);
    }
    return value;
  }

  int? _parseOptionalIntValue(Object? raw, String paramName) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) {
      final parsed = int.tryParse(raw.trim());
      if (parsed != null) return parsed;
    }

    throw _BadRequestException(
      'Invalid integer value for $paramName. Use an integer.',
    );
  }

  double? _parseOptionalDoubleValue(Object? raw, String paramName) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final parsed = double.tryParse(raw.trim());
      if (parsed != null) return parsed;
    }

    throw _BadRequestException(
      'Invalid number value for $paramName. Use a numeric value.',
    );
  }
}

@ApiController(
  title: 'Study Protocol Authoring API',
  version: '0.4.0',
  description:
      'Stateful API exposing session-scoped protocol state and serialization endpoints.',
  sharedParameters: <ApiSharedParameterDoc>[
    ApiSharedParameterDoc(
      name: 'sessionId',
      location: 'path',
      type: 'string',
      required: true,
      description: 'Session identifier returned by POST /protocol/new.',
      example: 'session_1234567890_1',
    ),
  ],
  sharedResponses: <ApiSharedResponseDoc>[
    ApiSharedResponseDoc(
      name: 'SessionNotFound',
      statusCode: '404',
      description: 'Session id not found.',
      schemaRef: 'ErrorResponse',
    ),
    ApiSharedResponseDoc(
      name: 'ServerError',
      statusCode: 'default',
      description: 'Unexpected server error.',
      schemaRef: 'ErrorResponse',
    ),
  ],
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'CreateSessionResponse',
      required: <String>['sessionId'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'sessionId',
          type: 'string',
          required: true,
          pattern: r'^session_\d+_\d+$',
          example: 'session_1234567890_1',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'CreateProtocolRequest',
      required: <String>['name'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: true,
          example: 'My Study Protocol',
        ),
        ApiPropertyDoc(
          name: 'ownerId',
          type: 'string',
          format: 'uuid',
          required: false,
          example: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
        ),
        ApiPropertyDoc(
          name: 'protocolVersionTag',
          type: 'string',
          required: false,
          example: 'v1.0.0',
        ),
        ApiPropertyDoc(
          name: 'protocolApiLevel',
          type: 'string',
          required: false,
          example: '2.0',
        ),
        ApiPropertyDoc(
          name: 'applicationName',
          type: 'string',
          required: false,
          example: 'carp_study_app',
        ),
        ApiPropertyDoc(
          name: 'privacySchemaName',
          type: 'string',
          required: false,
          enumValues: AuthoringRoutesBase.supportedPrivacySchemaNames,
          example: AuthoringRoutesBase.defaultPrivacySchemaName,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'SessionMutationResponse',
      required: <String>['sessionId', 'unfulfilledRequirements'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'sessionId', type: 'string', required: true),
        ApiPropertyDoc(
          name: 'unfulfilledRequirements',
          type: 'object',
          required: true,
          additionalProperties: true,
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
          additionalProperties: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'NamedDevice',
      required: <String>['name', 'device'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'name', type: 'string', required: true),
        ApiPropertyDoc(
          name: 'device',
          type: 'object',
          required: true,
          additionalProperties: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DurationRequest',
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'days', type: 'integer', minimum: 0),
        ApiPropertyDoc(name: 'hours', type: 'integer', minimum: 0),
        ApiPropertyDoc(name: 'minutes', type: 'integer', minimum: 0),
        ApiPropertyDoc(name: 'seconds', type: 'integer', minimum: 0),
        ApiPropertyDoc(name: 'milliseconds', type: 'integer', minimum: 0),
        ApiPropertyDoc(name: 'microseconds', type: 'integer', minimum: 0),
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
        ApiPropertyDoc(
          name: 'createdOn',
          type: 'string',
          format: 'date-time',
          required: false,
        ),
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
        ApiPropertyDoc(name: 'error', type: 'string', required: true),
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
        ServicesRoutes,
        DevicesRoutes,
        TasksRoutes,
        TaskControlsRoutes,
        TriggersRoutes {
  AuthoringRoutes(super.service);

  @override
  void register(Router router) {
    router.get('/sessions/<sessionId>/requirements', _getRequirements);
    router.post('/protocol/new', _startNewProtocol);
    router.get('/sessions/<sessionId>/serialize', _serializeProtocol);

    registerDataEndpointRoutes(router);
    registerPrimaryDeviceRoutes(router);
    registerParticipantRoleRoutes(router);
    registerParticipantExpectedDataRoutes(router);
    registerServicesRoutes(router);
    registerDeviceRoutes(router);
    registerTasksRoutes(router);
    registerTaskControlsRoutes(router);
    registerTriggersRoutes(router);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/requirements',
    summary: 'Get current unfulfilled requirements for the session',
    operationId: 'getRequirements',
    tags: <String>['Requirements and Serialization'],
    description:
        'Returns the current unfulfilled requirements for the session.',
    sharedParameterRefs: <String>['sessionId'],
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
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _getRequirements(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      return jsonResponse(
        HttpStatus.ok,
        body: _service.getRequirements(sessionId),
      );
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/new',
    summary: 'Create a new protocol authoring session',
    operationId: 'createProtocolSession',
    tags: <String>['Sessions'],
    description:
        'Creates an in-memory authoring session and returns a sessionId for subsequent requests.',
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'CreateProtocolRequest',
      description: 'Protocol creation payload.',
      required: true,
      example: <String, Object?>{
        'name': 'My Study Protocol',
        'ownerId': '979b408d-784e-4b1b-bb1e-ff9204e072f3',
        'protocolVersionTag': 'v1.0.0',
        'protocolApiLevel': '2.0',
        'applicationName': 'carp_study_app',
        'privacySchemaName': AuthoringRoutesBase.defaultPrivacySchemaName,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'New authoring session created',
        schemaRef: 'CreateSessionResponse',
      ),
    ],
  )
  Future<Response> _startNewProtocol(Request request) async {
    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = CreateProtocolRequest.fromJson(body);

      final privacySchemaName = _parseOptionalStringValue(
          payload.privacySchemaName, 'privacySchemaName');
      if (privacySchemaName != null) {
        _validateEnumValue(
          'privacySchemaName',
          privacySchemaName,
          AuthoringRoutesBase.supportedPrivacySchemaNames,
        );
      }

      final stateJson = _service.createNewProtocol(
        payload.name,
        _parseOptionalStringValue(payload.ownerId, 'ownerId'),
        protocolVersionTag: _parseOptionalStringValue(
            payload.protocolVersionTag, 'protocolVersionTag'),
        protocolApiLevel: _parseOptionalStringValue(
            payload.protocolApiLevel, 'protocolApiLevel'),
        applicationName: _parseOptionalStringValue(
            payload.applicationName, 'applicationName'),
        privacySchemaName: privacySchemaName,
      );

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/serialize',
    summary: 'Return the serialized protocol for the session',
    operationId: 'serializeProtocol',
    tags: <String>['Requirements and Serialization'],
    description: 'Returns the serialized protocol for the session.',
    sharedParameterRefs: <String>['sessionId'],
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
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _serializeProtocol(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      return jsonResponse(HttpStatus.ok, body: _service.serialize(sessionId));
    });
  }
}

class _BadRequestException implements Exception {
  const _BadRequestException(this.message);

  final String message;
}
