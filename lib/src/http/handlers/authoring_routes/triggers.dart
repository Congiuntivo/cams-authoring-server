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
    router.post('/sessions/<sessionId>/triggers/one-time', _addOneTimeTrigger);
    router.post('/sessions/<sessionId>/triggers/passive', _addPassiveTrigger);
    router.post('/sessions/<sessionId>/triggers/periodic', _addPeriodicTrigger);
    router.post(
      '/sessions/<sessionId>/triggers/random-recurrent',
      _addRandomRecurrentTrigger,
    );
    router.post(
      '/sessions/<sessionId>/triggers/recurrent-scheduled',
      _addRecurrentScheduledTrigger,
    );
    router.post(
        '/sessions/<sessionId>/triggers/scheduled', _addScheduledTrigger);
    router.post(
        '/sessions/<sessionId>/triggers/user-task', _addUserTaskTrigger);
    router.post('/sessions/<sessionId>/triggers/sampling-event',
        _addSamplingEventTrigger);
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
        description: 'Session id returned by POST /protocol/new.',
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
        description: 'Session id returned by POST /protocol/new.',
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
        description: 'Session id returned by POST /protocol/new.',
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
        description: 'Session id returned by POST /protocol/new.',
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
        description: 'Session id returned by POST /protocol/new.',
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
        description: 'Session id returned by POST /protocol/new.',
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
        description: 'Session id returned by POST /protocol/new.',
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
        description: 'Session id returned by POST /protocol/new.',
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
        description: 'Session id returned by POST /protocol/new.',
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

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/one-time',
    summary: 'Add a one-time trigger to the session protocol',
    operationId: 'addOneTimeTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a trigger that can only be fired once during deployment.',
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
      schemaRef: 'OneTimeTriggerRequest',
      description: 'One-time trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'show_demographics_once',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'One-time trigger added',
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
  Future<Response> _addOneTimeTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = OneTimeTriggerRequest.fromJson(body);

      final stateJson = _service.addOneTimeTrigger(
        sessionId,
        payload.triggerName,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/passive',
    summary: 'Add a passive trigger to the session protocol',
    operationId: 'addPassiveTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a trigger that fires only when manually triggered from code.',
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
      schemaRef: 'PassiveTriggerRequest',
      description: 'Passive trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'manual_code_trigger',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Passive trigger added',
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
  Future<Response> _addPassiveTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = PassiveTriggerRequest.fromJson(body);

      final stateJson = _service.addPassiveTrigger(
        sessionId,
        payload.triggerName,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/periodic',
    summary: 'Add a periodic trigger to the session protocol',
    operationId: 'addPeriodicTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that repeats with a fixed period.',
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
      schemaRef: 'PeriodicTriggerRequest',
      description: 'Periodic trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'periodic_prompt',
        'period': <String, Object?>{'minutes': 20},
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Periodic trigger added',
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
  Future<Response> _addPeriodicTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = PeriodicTriggerRequest.fromJson(body);

      final stateJson = _service.addPeriodicTrigger(
        sessionId,
        payload.triggerName,
        payload.period.toDuration(),
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/random-recurrent',
    summary: 'Add a random recurrent trigger to the session protocol',
    operationId: 'addRandomRecurrentTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a random recurrent trigger with time window and trigger count bounds.',
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
      schemaRef: 'RandomRecurrentTriggerRequest',
      description: 'Random recurrent trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'random_daily_prompts',
        'minNumberOfTriggers': 3,
        'maxNumberOfTriggers': 8,
        'startTime': <String, Object?>{'hour': 8, 'minute': 0},
        'endTime': <String, Object?>{'hour': 20, 'minute': 0},
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Random recurrent trigger added',
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
  Future<Response> _addRandomRecurrentTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = RandomRecurrentTriggerRequest.fromJson(body);

      final stateJson = _service.addRandomRecurrentTrigger(
        sessionId,
        payload.triggerName,
        payload.minNumberOfTriggers,
        payload.maxNumberOfTriggers,
        payload.startTime.hour,
        payload.startTime.minute,
        payload.startTime.second ?? 0,
        payload.endTime.hour,
        payload.endTime.minute,
        payload.endTime.second ?? 0,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/recurrent-scheduled',
    summary: 'Add a recurrent scheduled trigger to the session protocol',
    operationId: 'addRecurrentScheduledTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a recurrent scheduled trigger with daily, weekly, or monthly recurrence.',
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
      schemaRef: 'RecurrentScheduledTriggerRequest',
      description: 'Recurrent scheduled trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'weekday_checkin',
        'type': 'weekly',
        'time': <String, Object?>{'hour': 9, 'minute': 30},
        'dayOfWeek': 1,
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Recurrent scheduled trigger added',
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
  Future<Response> _addRecurrentScheduledTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = RecurrentScheduledTriggerRequest.fromJson(body);

      final stateJson = _service.addRecurrentScheduledTrigger(
        sessionId,
        payload.triggerName,
        payload.type,
        payload.time.hour,
        payload.time.minute,
        payload.time.second ?? 0,
        payload.end,
        payload.separationCount,
        payload.maxNumberOfSampling,
        payload.dayOfWeek,
        payload.weekOfMonth,
        payload.dayOfMonth,
        payload.duration?.toDuration(),
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/scheduled',
    summary: 'Add a scheduled trigger to the session protocol',
    operationId: 'addScheduledTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a scheduled trigger with a recurrence rule based on RFC-5545 concepts.',
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
      schemaRef: 'ScheduledTriggerRequest',
      description: 'Scheduled trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'daily_checkin',
        'time': <String, Object?>{'hour': 9, 'minute': 0},
        'recurrenceRule': <String, Object?>{
          'frequency': 'daily',
          'interval': 1,
          'end': <String, Object?>{'type': 'never'},
        },
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Scheduled trigger added',
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
  Future<Response> _addScheduledTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = ScheduledTriggerRequest.fromJson(body);

      final stateJson = _service.addScheduledTrigger(
        sessionId,
        payload.triggerName,
        payload.time.hour,
        payload.time.minute,
        payload.time.second ?? 0,
        payload.recurrenceRule.frequency,
        payload.recurrenceRule.interval,
        payload.recurrenceRule.end?.type,
        payload.recurrenceRule.end?.elapsedTime?.toDuration(),
        payload.recurrenceRule.end?.count,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/user-task',
    summary: 'Add a user-task trigger to the session protocol',
    operationId: 'addUserTaskTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a trigger that fires when a named user task reaches the specified state.',
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
      schemaRef: 'UserTaskTriggerRequest',
      description: 'User-task trigger payload.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'survey_completion_trigger',
        'taskName': 'daily_survey',
        'triggerCondition': 'done',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'User-task trigger added',
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
  Future<Response> _addUserTaskTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = UserTaskTriggerRequest.fromJson(body);

      final stateJson = _service.addUserTaskTrigger(
        sessionId,
        payload.triggerName,
        payload.taskName,
        payload.triggerCondition,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/sampling-event',
    summary: 'Add a sampling-event trigger to the session protocol',
    operationId: 'addSamplingEventTrigger',
    tags: <String>['Triggers'],
    description:
        'Adds a trigger that fires when data of a specific measure type is sampled. Optional triggerCondition must be a serialized CARP Data object containing a __type field and any matching data fields.',
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
      schemaRef: 'SamplingEventTriggerRequest',
      description:
          'Sampling-event trigger payload. triggerCondition is optional and should follow serialized CARP Data format.',
      required: true,
      example: <String, Object?>{
        'triggerName': 'after_completed_task',
        'measureType': 'dk.cachet.carp.completed_task',
        'triggerCondition': <String, Object?>{
          '__type': 'dk.cachet.carp.common.application.data.completedtask',
        },
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Sampling-event trigger added',
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
  Future<Response> _addSamplingEventTrigger(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = SamplingEventTriggerRequest.fromJson(body);

      final stateJson = _service.addSamplingEventTrigger(
        sessionId,
        payload.triggerName,
        payload.measureType,
        payload.triggerCondition,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
