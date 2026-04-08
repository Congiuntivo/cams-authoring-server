part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

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
        'Adds a data endpoint to the session protocol. Protocol must already be started with POST /protocol/new/smartphone or POST /protocol/new/default.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'sessionId',
        location: 'path',
        type: 'string',
        required: true,
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
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
}
