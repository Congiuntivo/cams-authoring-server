part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin TasksRoutes on AuthoringRoutesBase {
  @override
  void registerTasksRoutes(Router router) {
    router.get('/sessions/<sessionId>/tasks', _getTasks);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/tasks',
    summary: 'Get task summaries from the session protocol',
    operationId: 'getTasks',
    tags: <String>['Tasks'],
    description:
        'Returns configured task names and descriptions currently in the session protocol.',
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
        description: 'Task summaries returned',
        schemaRef: 'TasksResponse',
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
  Future<Response> _getTasks(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getTasks(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
