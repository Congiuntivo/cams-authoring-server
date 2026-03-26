part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin DataEndpointRoutes on AuthoringRoutesBase {
  @override
  void registerDataEndpointRoutes(Router router) {
    router.post('/protocol/data-endpoint', _addDataEndPoint);
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
        enumValues: AuthoringRoutesBase.supportedEndpointTypes,
        required: true,
        description: 'Endpoint type. Supported values: CAWS, SQLITE.',
        example: 'CAWS',
      ),
      ApiParameterDoc(
        name: 'uploadMethod',
        location: 'query',
        type: 'string',
        enumValues: AuthoringRoutesBase.supportedUploadMethods,
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
        AuthoringRoutesBase.supportedEndpointTypes,
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
}
