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

  String? _sessionId(Request request) {
    final querySessionId = request.url.queryParameters['sessionId'];
    if (querySessionId != null && querySessionId.trim().isNotEmpty) {
      return querySessionId.trim();
    }

    return null;
  }

  Response _badRequestMissingSessionId() {
    return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
      'error': 'Missing session id. Provide ?sessionId=... query parameter.',
    });
  }

  Response _sessionNotFoundResponse(String sessionId) {
    return jsonResponse(HttpStatus.notFound, body: <String, dynamic>{
      'error': 'Session not found: $sessionId',
    });
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

    return switch (raw.trim().toLowerCase()) {
      'stream' => CarpUploadMethod.stream,
      'datapoint' => CarpUploadMethod.datapoint,
      'file' => CarpUploadMethod.file,
      _ => throw FormatException('Unsupported uploadMethod: $raw'),
    };
  }

  bool? _parseOptionalBool(String? raw, String paramName) {
    if (raw == null) return null;

    return switch (raw.trim().toLowerCase()) {
      'true' => true,
      'false' => false,
      _ => throw FormatException('Invalid boolean value for $paramName: $raw'),
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

    try {
      return jsonResponse(HttpStatus.ok,
          body: _service.getRequirements(sessionId));
    } on SessionNotFoundException {
      return _sessionNotFoundResponse(sessionId);
    }
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
    var session = _service.createSession();

    var stateJson = _service.createNewProtocol(
        session,
        request.url.queryParameters['name'] ?? 'Unnamed Protocol',
        request.url.queryParameters['ownerId']);

    return jsonResponse(HttpStatus.created, body: stateJson);
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
        required: false,
        description: 'Endpoint type. Supported values: CAWS, SQLITE.',
        example: 'CAWS',
      ),
      ApiParameterDoc(
        name: 'uploadMethod',
        location: 'query',
        type: 'string',
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

    final endpointType = request.url.queryParameters['endpointType'];
    if (endpointType == null) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error':
            'Missing endpointType. Provide ?endpointType=... query parameter.',
      });
    }

    final uploadMethod =
        _parseUploadMethod(request.url.queryParameters['uploadMethod']);
    final name = request.url.queryParameters['name'];
    final deleteWhenUploaded = _parseOptionalBool(
      request.url.queryParameters['deleteWhenUploaded'],
      'deleteWhenUploaded',
    );

    try {
      final stateJson = _service.addDataEndPoint(
        sessionId,
        endpointType,
        uploadMethod,
        name,
        deleteWhenUploaded,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    } on SessionNotFoundException {
      return _sessionNotFoundResponse(sessionId);
    }
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

    final deviceType = request.url.queryParameters['deviceType'];
    if (deviceType == null) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error':
            'Missing deviceType. Provide ?deviceType=... query parameter. Supported values: smartphone, browser.',
      });
    }

    final roleName = request.url.queryParameters['roleName'];

    try {
      final stateJson = _service.addPrimaryDevice(
        sessionId,
        deviceType,
        roleName,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    } on SessionNotFoundException {
      return _sessionNotFoundResponse(sessionId);
    } on ArgumentError catch (error) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': error.message,
      });
    } on StateError catch (error) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': error.message,
      });
    }
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

    final roleName = request.url.queryParameters['roleName'];
    if (roleName == null || roleName.trim().isEmpty) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': 'Missing roleName. Provide ?roleName=... query parameter.',
      });
    }

    final isOptional = _parseOptionalBool(
      request.url.queryParameters['isOptional'],
      'isOptional',
    );

    try {
      final stateJson = _service.addParticipantRole(
        sessionId,
        roleName.trim(),
        isOptional,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    } on SessionNotFoundException {
      return _sessionNotFoundResponse(sessionId);
    } on ArgumentError catch (error) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': error.message,
      });
    } on StateError catch (error) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': error.message,
      });
    }
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

    final roleName = request.url.queryParameters['roleName'];
    if (roleName == null || roleName.trim().isEmpty) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': 'Missing roleName. Provide ?roleName=... query parameter.',
      });
    }

    final dataType = request.url.queryParameters['dataType'];
    if (dataType == null || dataType.trim().isEmpty) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': 'Missing dataType. Provide ?dataType=... query parameter.',
      });
    }

    try {
      final stateJson = _service.addExpectedParticipantDataForRole(
        sessionId,
        roleName.trim(),
        dataType.trim(),
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    } on SessionNotFoundException {
      return _sessionNotFoundResponse(sessionId);
    } on ArgumentError catch (error) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': error.message,
      });
    } on StateError catch (error) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': error.message,
      });
    }
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

    final dataType = request.url.queryParameters['dataType'];
    if (dataType == null || dataType.trim().isEmpty) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': 'Missing dataType. Provide ?dataType=... query parameter.',
      });
    }

    try {
      final stateJson = _service.addExpectedParticipantDataForAllRoles(
        sessionId,
        dataType.trim(),
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    } on SessionNotFoundException {
      return _sessionNotFoundResponse(sessionId);
    } on ArgumentError catch (error) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': error.message,
      });
    } on StateError catch (error) {
      return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
        'error': error.message,
      });
    }
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

    try {
      return jsonResponse(HttpStatus.ok, body: _service.serialize(sessionId));
    } on SessionNotFoundException {
      return _sessionNotFoundResponse(sessionId);
    }
  }
}
