import 'dart:io' show HttpStatus;

import 'package:carp_backend/carp_backend.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../openapi_annotations.dart';
import '../../protocol_authoring_service.dart';
import '../response/json_response.dart';

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
        ApiPropertyDoc(
          name: 'id',
          type: 'string',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'createdOn',
          type: 'string',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'description',
          type: 'string',
          required: false,
        ),
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
class AuthoringRoutes {
  AuthoringRoutes(this._service);

  final ProtocolAuthoringService _service;

  static const String _defaultProtocolType = 'smartphoneProtocol';
  static const String _defaultProtocolName = 'Unnamed Protocol';
  static const List<String> _supportedProtocolTypes = <String>[
    'smartphoneProtocol',
    'studyProtocol',
  ];
  static const List<String> _supportedEndpointTypes = <String>[
    'CAWS',
    'SQLITE'
  ];
  static const List<String> _supportedUploadMethods = <String>[
    'stream',
    'datapoint',
    'file'
  ];
  static const List<String> _supportedDeviceTypes = <String>[
    'smartphone',
    'browser'
  ];
  static const List<String> _supportedParticipantDataTypes = <String>[
    'sex',
    'phone_number',
    'ssn',
    'full_name',
    'informed_consent',
    'address',
    'diagnosis',
    'custom',
  ];

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

  void register(Router router) {
    router.get('/requirements', _getRequirements);
    router.post('/protocol/new', _startNewProtocol);
    router.post('/protocol/data-endpoint', _addDataEndPoint);
    router.post('/protocol/primary-device', _addPrimaryDevice);
    router.post('/protocol/participant-role', _addParticipantRole);
    router.post(
      '/protocol/participant-expected-data/role',
      _addExpectedParticipantDataForRole,
    );
    router.post(
      '/protocol/participant-expected-data/all',
      _addExpectedParticipantDataForAllRoles,
    );
    router.get('/serialize', _serializeProtocol);
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
          '${_supportedUploadMethods.join(', ')}.'),
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
        description: 'Session id returned by POST /protocol/new.',
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
    path: '/protocol/new',
    summary: 'Create a new protocol authoring session',
    operationId: 'createProtocolSession',
    description:
        'Creates an in-memory authoring session and returns a sessionId for subsequent requests.',
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
      ApiParameterDoc(
        name: 'protocolType',
        location: 'query',
        type: 'string',
        required: false,
        enumValues: _supportedProtocolTypes,
        description:
            'Protocol type to initialize. Supported values: smartphoneProtocol, studyProtocol. Defaults to smartphoneProtocol.',
        example: 'studyProtocol',
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
  Response _startNewProtocol(Request request) {
    return _runWithErrorHandling(() {
      final protocolType =
          _optionalTrimmedQueryParam(request, 'protocolType') ??
              _defaultProtocolType;
      _validateEnumValue('protocolType', protocolType, _supportedProtocolTypes);

      final sessionId = _service.createSession();
      final stateJson = _service.createNewProtocol(
        protocolType,
        sessionId,
        _optionalTrimmedQueryParam(request, 'name') ?? _defaultProtocolName,
        _optionalTrimmedQueryParam(request, 'ownerId'),
      );

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/data-endpoint',
    summary: 'Add a data endpoint to a protocol in the session',
    operationId: 'addDataEndpoint',
    description:
        'Adds a data endpoint to the session protocol. Requires sessionId. Protocol must already be started with POST /protocol/new.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'endpointType',
        location: 'query',
        type: 'string',
        enumValues: _supportedEndpointTypes,
        required: true,
        description: 'Endpoint type. Supported values: CAWS, SQLITE.',
        example: 'CAWS',
      ),
      ApiParameterDoc(
        name: 'uploadMethod',
        location: 'query',
        type: 'string',
        enumValues: _supportedUploadMethods,
        required: false,
        description: 'CAWS upload method: stream, datapoint, or file.',
        example: 'stream',
      ),
      ApiParameterDoc(
        name: 'name',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Display name of the endpoint.',
        example: 'CARP Web Services',
      ),
      ApiParameterDoc(
        name: 'deleteWhenUploaded',
        location: 'query',
        type: 'boolean',
        required: false,
        description: 'Whether local buffered data is deleted after upload.',
        example: 'true',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Data endpoint added',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid query parameters',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _addDataEndPoint(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final endpointType = _requireEnumQueryParam(
        request,
        'endpointType',
        _supportedEndpointTypes,
        missingMessage:
            'Missing endpointType. Provide ?endpointType=... query parameter.',
      );
      final uploadMethod = _parseUploadMethod(
          _optionalTrimmedQueryParam(request, 'uploadMethod'));
      final name = _optionalTrimmedQueryParam(request, 'name');
      final deleteWhenUploaded = _parseOptionalBool(
        _optionalTrimmedQueryParam(request, 'deleteWhenUploaded'),
        'deleteWhenUploaded',
      );

      final stateJson = _service.addDataEndPoint(
        sessionId,
        endpointType,
        uploadMethod,
        name,
        deleteWhenUploaded,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/primary-device',
    summary: 'Add a primary device to the protocol in the session',
    operationId: 'addPrimaryDevice',
    description:
        'Adds a primary device to the session protocol. Requires sessionId. Protocol must already be started with POST /protocol/new.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'deviceType',
        location: 'query',
        type: 'string',
        enumValues: _supportedDeviceTypes,
        required: true,
        description: 'Device type. Supported values: smartphone, browser.',
        example: 'smartphone',
      ),
      ApiParameterDoc(
        name: 'roleName',
        location: 'query',
        type: 'string',
        required: false,
        description: 'Display name of the device.',
        example: 'User Phone',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Primary device added',
        schemaRef: 'RequirementsResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid query parameters',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _addPrimaryDevice(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final deviceType = _requireEnumQueryParam(
        request,
        'deviceType',
        _supportedDeviceTypes,
        missingMessage:
            'Missing deviceType. Provide ?deviceType=... query parameter. Supported values: ${_supportedDeviceTypes.join(', ')}.',
      );
      final roleName = _optionalTrimmedQueryParam(request, 'roleName');

      final stateJson = _service.addPrimaryDevice(
        sessionId,
        deviceType,
        roleName,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/participant-role',
    summary: 'Add a participant role to the protocol in the session',
    operationId: 'addParticipantRole',
    description:
        'Adds a participant role. Requires sessionId. Protocol must already be started with POST /protocol/new.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'roleName',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Participant role name.',
        example: 'Patient',
      ),
      ApiParameterDoc(
        name: 'isOptional',
        location: 'query',
        type: 'boolean',
        required: false,
        description: 'Whether the role is optional.',
        example: 'false',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Participant role added',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid query parameters',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _addParticipantRole(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _requireQueryParam(
        request,
        'roleName',
        'Missing roleName. Provide ?roleName=... query parameter.',
      );
      final isOptional = _parseOptionalBool(
        _optionalTrimmedQueryParam(request, 'isOptional'),
        'isOptional',
      );

      final stateJson = _service.addParticipantRole(
        sessionId,
        roleName,
        isOptional,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/participant-expected-data/role',
    summary: 'Add expected participant data for a specific role',
    operationId: 'addExpectedParticipantDataForRole',
    description:
        'Adds expected participant data assigned to a specific role. Requires sessionId and roleName.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'roleName',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Existing participant role name.',
        example: 'Patient',
      ),
      ApiParameterDoc(
        name: 'dataType',
        location: 'query',
        type: 'string',
        enumValues: _supportedParticipantDataTypes,
        required: true,
        description:
            'Participant input data type. Supported values: sex, phone_number, ssn, full_name, informed_consent, address, diagnosis, custom.',
        example: 'sex',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Expected participant data added for role',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid query parameters',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _addExpectedParticipantDataForRole(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final roleName = _requireQueryParam(
        request,
        'roleName',
        'Missing roleName. Provide ?roleName=... query parameter.',
      );
      final dataType = _requireEnumQueryParam(
        request,
        'dataType',
        _supportedParticipantDataTypes,
        missingMessage:
            'Missing dataType. Provide ?dataType=... query parameter.',
      );

      final stateJson = _service.addExpectedParticipantDataForRole(
        sessionId,
        roleName,
        dataType,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/participant-expected-data/all',
    summary: 'Add expected participant data for all roles',
    operationId: 'addExpectedParticipantDataForAllRoles',
    description:
        'Adds expected participant data assigned to all roles. Requires sessionId and dataType.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'query',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
      ApiParameterDoc(
        name: 'dataType',
        location: 'query',
        type: 'string',
        enumValues: _supportedParticipantDataTypes,
        required: true,
        description:
            'Participant input data type. Supported values: sex, phone_number, ssn, full_name, informed_consent, address, diagnosis, custom.',
        example: 'informed_consent',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Expected participant data added for all roles',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing or invalid query parameters',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Response _addExpectedParticipantDataForAllRoles(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final dataType = _requireEnumQueryParam(
        request,
        'dataType',
        _supportedParticipantDataTypes,
        missingMessage:
            'Missing dataType. Provide ?dataType=... query parameter.',
      );

      final stateJson = _service.addExpectedParticipantDataForAllRoles(
        sessionId,
        dataType,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
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
        description: 'Session id returned by POST /protocol/new.',
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
