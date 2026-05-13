part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'DataEndpointResponse',
      required: <String>['sessionId', 'unfulfilledRequirements'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'sessionId', type: 'string', required: true),
        ApiPropertyDoc(
          name: 'unfulfilledRequirements',
          type: 'object',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DataEndpointRequest',
      required: <String>['endpointType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'endpointType',
          type: 'string',
          required: true,
          enumValues: AuthoringRoutesBase.supportedEndpointTypes,
          example: 'CAWS',
        ),
        ApiPropertyDoc(
          name: 'uploadMethod',
          type: 'string',
          required: false,
          enumValues: AuthoringRoutesBase.supportedUploadMethods,
          example: 'stream',
        ),
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: false,
          example: 'CARP Web Services',
        ),
        ApiPropertyDoc(
          name: 'deleteWhenUploaded',
          type: 'boolean',
          required: false,
          example: true,
        ),
        ApiPropertyDoc(
          name: 'bufferSize',
          type: 'integer',
          required: false,
          example: 500000,
        ),
        ApiPropertyDoc(
            name: 'zip', type: 'boolean', required: false, example: true),
        ApiPropertyDoc(
          name: 'encrypt',
          type: 'boolean',
          required: false,
          example: false,
        ),
        ApiPropertyDoc(
          name: 'publicKey',
          type: 'string',
          required: false,
          example: '-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----',
        ),
      ],
    ),
  ],
)
mixin DataEndpointRoutes on AuthoringRoutesBase {
  @override
  void registerDataEndpointRoutes(Router router) {
    router.post('/sessions/<sessionId>/data-endpoint', _addDataEndPoint);
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/data-endpoint',
    summary: 'Add a data endpoint to a protocol in the session',
    operationId: 'addDataEndpoint',
    tags: <String>['Data Endpoint'],
    description:
        'Adds a data endpoint to the session protocol. Protocol must already be started with POST /protocol/new.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description: 'Session id returned by POST /protocol/new.',
        example: 'session_1234567890_1',
      ),
    ],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'DataEndpointRequest',
      description: 'Data endpoint configuration payload.',
      required: true,
      example: <String, Object?>{
        'endpointType': 'CAWS',
        'uploadMethod': 'stream',
        'name': 'CARP Web Services',
        'deleteWhenUploaded': true,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Data endpoint added',
        schemaRef: 'DataEndpointResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid or missing fields in the request body.',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addDataEndPoint(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = DataEndpointRequest.fromJson(body);

      final endpointType = _requireStringValue(
        payload.endpointType,
        'endpointType',
        'Missing endpointType. Provide endpointType in request body.',
      );
      _validateEnumValue(
        'endpointType',
        endpointType,
        AuthoringRoutesBase.supportedEndpointTypes,
      );
      final uploadMethod = _parseUploadMethod(payload.uploadMethod);
      final name = payload.name;
      final deleteWhenUploaded = _parseOptionalBoolValue(
        payload.deleteWhenUploaded,
        'deleteWhenUploaded',
      );
      final bufferSize =
          _parseOptionalIntValue(payload.bufferSize, 'bufferSize');
      final zip = _parseOptionalBoolValue(payload.zip, 'zip');
      final encrypt = _parseOptionalBoolValue(payload.encrypt, 'encrypt');
      final publicKey =
          _parseOptionalStringValue(payload.publicKey, 'publicKey');

      if (bufferSize != null && bufferSize <= 0) {
        throw const FormatException(
          'Invalid bufferSize in data endpoint request body. Use an integer greater than 0.',
        );
      }

      if (endpointType == 'FILE' && encrypt == true && publicKey == null) {
        throw const FormatException(
          'publicKey is required when encrypt is true for FILE endpoint.',
        );
      }

      final stateJson = _service.addDataEndPoint(
        sessionId,
        endpointType,
        uploadMethod,
        name,
        deleteWhenUploaded,
        bufferSize: bufferSize,
        zip: zip,
        encrypt: encrypt,
        publicKey: publicKey,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
