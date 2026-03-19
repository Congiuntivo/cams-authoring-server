import 'dart:io' show HttpStatus;

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
          name: 'name',
          type: 'string',
          example: 'My Study Protocol',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'ownerId',
          type: 'string',
          example: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'sessionId',
          type: 'string',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'StateResponse',
      required: <String>['state'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'state',
          type: 'string',
          enumValues: <String>['protocolStarted'],
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
          required: false,
        ),
        ApiPropertyDoc(
          name: 'primaryDevices',
          type: 'array',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'connectedDevices',
          type: 'array',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'tasks',
          type: 'array',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'triggers',
          type: 'array',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'taskControls',
          type: 'array',
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
    router.get('/state', _getState);
    router.post('/protocol/new', _startNewProtocol);
    router.get('/serialize', _serializeProtocol);
  }

  @ApiOperation(
    method: 'get',
    path: '/state',
    summary: 'Get current authoring state for a session',
    operationId: 'getState',
    description:
        'Returns the current state of the session. Requires sessionId (will return 400 if missing or 404 if not found).',
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
        description: 'Current state',
        schemaRef: 'StateResponse',
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
  Response _getState(Request request) {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    try {
      return jsonResponse(HttpStatus.ok, body: _service.getState(sessionId));
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
    // var response = jsonResponse(HttpStatus.created, body: _service.createSession());
    var session = _service.createSession();

    var stateJson = _service.createNewProtocol(
        session,
        request.url.queryParameters['name'] ?? 'Unnamed Protocol',
        request.url.queryParameters['ownerId']);

    return jsonResponse(HttpStatus.created, body: stateJson);
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
