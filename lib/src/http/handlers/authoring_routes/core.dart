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
  description: 'A local HTTP server for interactively authoring CARP '
      'SmartphoneStudyProtocol objects. State is in-memory and lost on '
      'restart. The server binds to http://localhost:8080 and is intended '
      'for local use only.\n\n'
      '## Session lifecycle\n\n'
      'Every session starts with POST /sessions, which returns a '
      'sessionId used in all subsequent calls:\n\n'
      '  POST /sessions                                          create session, get sessionId\n'
      '  POST /sessions/{id}/primary-devices/...               required before tasks and triggers\n'
      '  POST /sessions/{id}/devices/...                       optional connected devices\n'
      '  POST /sessions/{id}/participant-roles                 define participant roles\n'
      '  POST /sessions/{id}/participant-roles/expected-data   expected data for a specific role\n'
      '  POST /sessions/{id}/expected-data                     expected data for all roles\n'
      '  POST /sessions/{id}/services/...                      optional background services\n'
      '  POST /sessions/{id}/tasks/...                         define tasks\n'
      '  POST /sessions/{id}/triggers/...                      define triggers\n'
      '  POST /sessions/{id}/task-controls                     bind triggers to tasks and devices\n'
      '  POST /sessions/{id}/data-endpoint                     configure upload endpoint\n'
      '  GET  /sessions/{id}/requirements                      inspect open requirements\n'
      '  GET  /sessions/{id}/serialize                         finalize protocol\n\n'
      '## Requirements system\n\n'
      'Every mutation response includes an unfulfilledRequirements map with '
      'warning and critical items. GET /sessions/{id}/serialize returns 409 '
      'if any critical requirements remain unmet. Use '
      'GET /sessions/{id}/requirements to inspect the current state at any '
      'time without mutating the session.\n\n'
      '## Polymorphic payloads\n\n'
      'Task, trigger, and device payloads are polymorphic CARP types. The '
      '__type field in each serialized object selects the concrete class. '
      'Responses that include these objects (e.g. getTasks, getTriggers, '
      'getDeviceRoles) always include __type in the returned payload.',
  tags: <ApiTagDoc>[
    ApiTagDoc(
      name: 'Sessions',
      description: 'Create and inspect authoring sessions.',
    ),
    ApiTagDoc(
      name: 'Primary Devices',
      description: 'Configure the primary device for the protocol.',
    ),
    ApiTagDoc(
      name: 'Devices',
      description: 'Add connected peripheral devices to the protocol.',
    ),
    ApiTagDoc(
      name: 'Services',
      description: 'Add background data-collection services.',
    ),
    ApiTagDoc(
      name: 'Participant Roles',
      description: 'Define participant roles in the study.',
    ),
    ApiTagDoc(
      name: 'Expected Participant Data',
      description: 'Declare what data is expected from each participant role.',
    ),
    ApiTagDoc(
      name: 'Tasks',
      description: 'Add tasks that participants will perform.',
    ),
    ApiTagDoc(
      name: 'Triggers',
      description: 'Define triggers that schedule or activate tasks.',
    ),
    ApiTagDoc(
      name: 'Task Controls',
      description: 'Bind triggers to tasks and target device roles.',
    ),
    ApiTagDoc(
      name: 'Data Endpoint',
      description: 'Configure the data upload endpoint for the protocol.',
    ),
    ApiTagDoc(
      name: 'Requirements and Serialization',
      description:
          'Inspect unfulfilled requirements and finalize the protocol.',
    ),
  ],
  sharedParameters: <ApiSharedParameterDoc>[
    ApiSharedParameterDoc(
      name: 'sessionId',
      location: 'path',
      type: 'string',
      required: true,
      description: 'Session identifier returned by POST /sessions.',
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
      name: 'SetApplicationDataRequest',
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'applicationData',
          type: 'object',
          required: false,
          additionalProperties: true,
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
    router.post('/sessions', _startNewProtocol);
    router.put('/sessions/<sessionId>/application-data', _setApplicationData);
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
    description: 'Returns the current unfulfilled requirements for the '
        'session. Each requirement has a name and a severity — critical '
        'requirements block serialization; warnings do not. Call this '
        'endpoint at any point to check what still needs to be configured '
        'before GET /sessions/{id}/serialize will succeed.',
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
    path: '/sessions',
    summary: 'Create a new protocol authoring session',
    operationId: 'createProtocolSession',
    tags: <String>['Sessions'],
    description: 'Creates an in-memory authoring session and returns a '
        'sessionId for all subsequent requests. Sessions are not persisted — '
        'restarting the server destroys all sessions. name is required; all '
        'other fields are optional and customize the resulting protocol '
        'metadata. The sessionId returned here must be included in the path '
        'of every subsequent call.',
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'CreateProtocolRequest',
      description: 'Protocol creation payload.',
      required: true,
      example: <String, Object?>{
        'name': 'My Study Protocol',
        'ownerId': '979b408d-784e-4b1b-bb1e-ff9204e072f3',
        'protocolVersionTag': 'v1.0.0',
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
        applicationName: _parseOptionalStringValue(
            payload.applicationName, 'applicationName'),
        privacySchemaName: privacySchemaName,
      );

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'put',
    path: '/sessions/{sessionId}/application-data',
    summary: 'Set custom application data on the protocol',
    operationId: 'setApplicationData',
    tags: <String>['Sessions'],
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'SetApplicationDataRequest',
      description:
          'Free-form key/value map to store as custom application data.',
      required: true,
      example: <String, Object?>{
        'myKey': 'myValue',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Application data updated',
        schemaRef: 'SessionMutationResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _setApplicationData(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final stateJson = _service.setApplicationData(sessionId, body);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/serialize',
    summary: 'Return the serialized protocol for the session',
    operationId: 'serializeProtocol',
    tags: <String>['Requirements and Serialization'],
    description: 'Finalizes the session and returns the full serialized CARP '
        'SmartphoneStudyProtocol as JSON. Returns 409 if any critical '
        'requirements remain unmet — use GET /sessions/{id}/requirements to '
        'check first. The response contains the full protocol graph including '
        'all devices, tasks, triggers, and task controls. Calling serialize '
        'does not destroy the session; further mutations are still possible '
        'afterward.',
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
