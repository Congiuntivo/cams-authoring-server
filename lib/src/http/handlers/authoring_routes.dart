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
      'Dummy stateful API exposing state, new protocol, and serialize endpoints.',
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'StateResponse',
      required: <String>['state'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'state',
          type: 'string',
          enumValues: <String>['ready', 'protocolStarted'],
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DummyProtocolBody',
      required: <String>['name', 'version'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          example: 'dummy_protocol',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'version',
          type: 'integer',
          example: 1,
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DummyProtocolEnvelope',
      required: <String>['dummy', 'protocol'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'dummy',
          type: 'boolean',
          example: true,
          required: true,
        ),
        ApiPropertyDoc(
          name: 'protocol',
          ref: 'DummyProtocolBody',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'SerializeResponse',
      required: <String>['state', 'protocol'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'state',
          type: 'string',
          enumValues: <String>['ready', 'protocolStarted'],
          required: true,
        ),
        ApiPropertyDoc(
          name: 'protocol',
          ref: 'DummyProtocolEnvelope',
          required: true,
        ),
      ],
    ),
  ],
)
class AuthoringRoutes {
  AuthoringRoutes(this._service);

  final ProtocolAuthoringService _service;

  void register(Router router) {
    router.get('/state', _getState);
    router.post('/protocol/new', _startNewProtocol);
    router.get('/serialize', _serializeProtocol);
  }

  @ApiOperation(
    method: 'get',
    path: '/state',
    summary: 'Get current authoring state',
    operationId: 'getState',
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Current state',
        schemaRef: 'StateResponse',
      ),
    ],
  )
  Response _getState(Request request) {
    return jsonResponse(HttpStatus.ok, body: _service.getState());
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/new',
    summary: 'Start a new protocol (dummy state change only)',
    operationId: 'startNewProtocol',
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'Protocol state updated',
        schemaRef: 'StateResponse',
      ),
    ],
  )
  Response _startNewProtocol(Request request) {
    return jsonResponse(HttpStatus.created, body: _service.startNewProtocol());
  }

  @ApiOperation(
    method: 'get',
    path: '/serialize',
    summary: 'Return a dummy serialized protocol payload',
    operationId: 'serializeProtocol',
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Dummy protocol JSON',
        schemaRef: 'SerializeResponse',
      ),
    ],
  )
  Response _serializeProtocol(Request request) {
    return jsonResponse(HttpStatus.ok, body: _service.serialize());
  }
}
