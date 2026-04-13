part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin TriggersRoutes on AuthoringRoutesBase {
  @override
  void registerTriggersRoutes(Router router) {
    router.get('/sessions/<sessionId>/triggers', _getTriggers);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/triggers',
    summary: 'Get configured triggers from the session protocol',
    operationId: 'getTriggers',
    tags: <String>['Triggers'],
    description:
        'Returns configured trigger ids and serialized trigger configurations currently in the session protocol.',
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
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Trigger summaries returned',
        schemaRef: 'TriggersResponse',
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
  Future<Response> _getTriggers(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getTriggers(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
