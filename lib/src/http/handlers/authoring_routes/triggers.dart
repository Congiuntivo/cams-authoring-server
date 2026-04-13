part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin TriggersRoutes on AuthoringRoutesBase {
  @override
  void registerTriggersRoutes(Router router) {
    router.get('/sessions/<sessionId>/triggers', _getTriggers);
    router.post('/sessions/<sessionId>/triggers/cron', _addCronTrigger);
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

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/cron',
    summary: 'Add a cron scheduled trigger to the session protocol',
    operationId: 'addCronScheduledTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a cron scheduled trigger using optional cron fields. Null fields match all values.',
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
      schemaRef: 'CronScheduledTriggerRequest',
      description: 'Cron scheduled trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'daily_evening_prompt',
        'minute': 30,
        'hour': 19,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Cron scheduled trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload, cron field range, or trigger name',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addCronTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = CronScheduledTriggerRequest.fromJson(body);

      final stateJson = _service.addCronScheduledTrigger(
        sessionId,
        payload.triggerName,
        payload.minute,
        payload.hour,
        payload.day,
        payload.month,
        payload.weekday,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
