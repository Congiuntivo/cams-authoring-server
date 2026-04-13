part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin TriggersRoutes on AuthoringRoutesBase {
  @override
  void registerTriggersRoutes(Router router) {
    router.get('/sessions/<sessionId>/triggers', _getTriggers);
    router.post('/sessions/<sessionId>/triggers/cron', _addCronTrigger);
    router.post(
        '/sessions/<sessionId>/triggers/date-time', _addDateTimeTrigger);
    router.post('/sessions/<sessionId>/triggers/delayed', _addDelayedTrigger);
    router.post(
        '/sessions/<sessionId>/triggers/elapsed-time', _addElapsedTimeTrigger);
    router.post(
        '/sessions/<sessionId>/triggers/immediate', _addImmediateTrigger);
    router.post('/sessions/<sessionId>/triggers/manual', _addManualTrigger);
    router.post('/sessions/<sessionId>/triggers/no-op', _addNoOpTrigger);
    router.post(
      '/sessions/<sessionId>/triggers/no-user-task',
      _addNoUserTaskTrigger,
    );
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

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/date-time',
    summary: 'Add a date-time trigger to the session protocol',
    operationId: 'addDateTimeTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a trigger that fires once at the specified ISO-8601 date-time.',
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
      schemaRef: 'DateTimeTriggerRequest',
      description: 'Date-time trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'enrollment_follow_up',
        'schedule': '2026-10-01T09:30:00Z',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Date-time trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addDateTimeTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = DateTimeTriggerRequest.fromJson(body);

      final stateJson = _service.addDateTimeTrigger(
        sessionId,
        payload.triggerName,
        payload.schedule,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/delayed',
    summary: 'Add a delayed trigger to the session protocol',
    operationId: 'addDelayedTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires after a delay from sensing start.',
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
      schemaRef: 'DelayedTriggerRequest',
      description: 'Delayed trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'delayed_prompt',
        'delay': <String, Object?>{'minutes': 15},
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Delayed trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addDelayedTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = DelayedTriggerRequest.fromJson(body);

      final stateJson = _service.addDelayedTrigger(
        sessionId,
        payload.triggerName,
        payload.delay.toDuration(),
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/elapsed-time',
    summary: 'Add an elapsed-time trigger to the session protocol',
    operationId: 'addElapsedTimeTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a trigger that fires when elapsed time from sensing start is reached.',
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
      schemaRef: 'ElapsedTimeTriggerRequest',
      description: 'Elapsed-time trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'elapsed_30_minutes',
        'elapsedTime': <String, Object?>{'minutes': 30},
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Elapsed-time trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addElapsedTimeTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = ElapsedTimeTriggerRequest.fromJson(body);

      final stateJson = _service.addElapsedTimeTrigger(
        sessionId,
        payload.triggerName,
        payload.elapsedTime.toDuration(),
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/immediate',
    summary: 'Add an immediate trigger to the session protocol',
    operationId: 'addImmediateTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires immediately when sensing starts.',
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
      schemaRef: 'ImmediateTriggerRequest',
      description: 'Immediate trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'start_now',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Immediate trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addImmediateTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = ImmediateTriggerRequest.fromJson(body);

      final stateJson = _service.addImmediateTrigger(
        sessionId,
        payload.triggerName,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/manual',
    summary: 'Add a manual trigger to the session protocol',
    operationId: 'addManualTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a manual trigger with optional label and description.',
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
      schemaRef: 'ManualTriggerRequest',
      description: 'Manual trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'manual_daily_prompt',
        'label': 'Daily prompt',
        'description': 'Shown manually by the participant.',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Manual trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addManualTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = ManualTriggerRequest.fromJson(body);

      final stateJson = _service.addManualTrigger(
        sessionId,
        payload.triggerName,
        payload.label,
        payload.description,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/no-op',
    summary: 'Add a no-op trigger to the session protocol',
    operationId: 'addNoOpTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that starts immediately and never stops.',
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
      schemaRef: 'NoOpTriggerRequest',
      description: 'No-op trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'always_on',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'No-op trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addNoOpTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = NoOpTriggerRequest.fromJson(body);

      final stateJson = _service.addNoOpTrigger(
        sessionId,
        payload.triggerName,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/no-user-task',
    summary: 'Add a no-user-task trigger to the session protocol',
    operationId: 'addNoUserTaskTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a trigger that fires when the specified task is not on the task list.',
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
      schemaRef: 'NoUserTaskTriggerRequest',
      description: 'No-user-task trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'ensure_survey_task',
        'taskName': 'daily_survey',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'No-user-task trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addNoUserTaskTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = NoUserTaskTriggerRequest.fromJson(body);

      final stateJson = _service.addNoUserTaskTrigger(
        sessionId,
        payload.triggerName,
        payload.taskName,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
