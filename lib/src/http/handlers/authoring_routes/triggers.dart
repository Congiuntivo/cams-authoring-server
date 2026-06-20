part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'TriggerSummary',
      required: <String>['name', 'trigger'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: true,
          example: '0',
        ),
        ApiPropertyDoc(
          name: 'trigger',
          type: 'object',
          required: true,
          additionalProperties: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'TriggersResponse',
      required: <String>['triggers'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggers',
          type: 'array',
          itemsRef: 'TriggerSummary',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'CronScheduledTriggerRequest',
      required: <String>['triggerName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'daily_evening_prompt',
        ),
        ApiPropertyDoc(
          name: 'minute',
          type: 'integer',
          required: false,
          example: 30,
        ),
        ApiPropertyDoc(
          name: 'hour',
          type: 'integer',
          required: false,
          example: 19,
        ),
        ApiPropertyDoc(
          name: 'day',
          type: 'integer',
          required: false,
          example: 1,
        ),
        ApiPropertyDoc(
          name: 'month',
          type: 'integer',
          required: false,
          example: 1,
        ),
        ApiPropertyDoc(
          name: 'weekday',
          type: 'integer',
          required: false,
          example: 1,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DateTimeTriggerRequest',
      required: <String>['triggerName', 'schedule'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'enrollment_follow_up',
        ),
        ApiPropertyDoc(
          name: 'schedule',
          type: 'string',
          required: true,
          example: '2026-10-01T09:30:00Z',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DelayedTriggerRequest',
      required: <String>['triggerName', 'delay'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'delayed_prompt',
        ),
        ApiPropertyDoc(name: 'delay', ref: 'DurationRequest', required: true),
      ],
    ),
    ApiSchemaDoc(
      name: 'ElapsedTimeTriggerRequest',
      required: <String>['triggerName', 'elapsedTime'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'elapsed_30_minutes',
        ),
        ApiPropertyDoc(
          name: 'elapsedTime',
          ref: 'DurationRequest',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ImmediateTriggerRequest',
      required: <String>['triggerName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'start_now',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ManualTriggerRequest',
      required: <String>['triggerName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'manual_daily_prompt',
        ),
        ApiPropertyDoc(
          name: 'label',
          type: 'string',
          required: false,
          example: 'Daily prompt',
        ),
        ApiPropertyDoc(
          name: 'description',
          type: 'string',
          required: false,
          example: 'Shown manually by the participant.',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'NoUserTaskTriggerRequest',
      required: <String>['triggerName', 'taskName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'ensure_survey_task',
        ),
        ApiPropertyDoc(
          name: 'taskName',
          type: 'string',
          required: true,
          example: 'daily_survey',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'OneTimeTriggerRequest',
      required: <String>['triggerName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'show_demographics_once',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'PassiveTriggerRequest',
      required: <String>['triggerName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'manual_code_trigger',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'PeriodicTriggerRequest',
      required: <String>['triggerName', 'period'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'periodic_prompt',
        ),
        ApiPropertyDoc(name: 'period', ref: 'DurationRequest', required: true),
      ],
    ),
    ApiSchemaDoc(
      name: 'TimeOfDayRequest',
      required: <String>['hour', 'minute'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'hour',
          type: 'integer',
          required: true,
          example: 8,
        ),
        ApiPropertyDoc(
          name: 'minute',
          type: 'integer',
          required: true,
          example: 30,
        ),
        ApiPropertyDoc(
          name: 'second',
          type: 'integer',
          required: false,
          example: 0,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'RandomRecurrentTriggerRequest',
      required: <String>[
        'triggerName',
        'minNumberOfTriggers',
        'maxNumberOfTriggers',
        'startTime',
        'endTime',
      ],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'random_daily_prompts',
        ),
        ApiPropertyDoc(
          name: 'minNumberOfTriggers',
          type: 'integer',
          required: true,
          example: 3,
        ),
        ApiPropertyDoc(
          name: 'maxNumberOfTriggers',
          type: 'integer',
          required: true,
          example: 8,
        ),
        ApiPropertyDoc(
          name: 'startTime',
          ref: 'TimeOfDayRequest',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'endTime',
          ref: 'TimeOfDayRequest',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'RecurrentScheduledTriggerRequest',
      required: <String>['triggerName', 'type', 'time'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'weekday_checkin',
        ),
        ApiPropertyDoc(
          name: 'type',
          type: 'string',
          required: true,
          enumValues: <String>['daily', 'weekly', 'monthly'],
          example: 'weekly',
        ),
        ApiPropertyDoc(name: 'time', ref: 'TimeOfDayRequest', required: true),
        ApiPropertyDoc(
          name: 'end',
          type: 'string',
          required: false,
          example: '2026-12-31T23:59:59Z',
        ),
        ApiPropertyDoc(
          name: 'separationCount',
          type: 'integer',
          required: false,
          example: 1,
        ),
        ApiPropertyDoc(
          name: 'maxNumberOfSampling',
          type: 'integer',
          required: false,
          example: 10,
        ),
        ApiPropertyDoc(
          name: 'dayOfWeek',
          type: 'integer',
          required: false,
          example: 1,
        ),
        ApiPropertyDoc(
          name: 'weekOfMonth',
          type: 'integer',
          required: false,
          example: 2,
        ),
        ApiPropertyDoc(
          name: 'dayOfMonth',
          type: 'integer',
          required: false,
          example: 15,
        ),
        ApiPropertyDoc(
          name: 'duration',
          ref: 'DurationRequest',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'RecurrenceEndRequest',
      required: <String>['type'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'type',
          type: 'string',
          required: true,
          enumValues: <String>['until', 'count', 'never'],
          example: 'never',
        ),
        ApiPropertyDoc(
          name: 'elapsedTime',
          ref: 'DurationRequest',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'count',
          type: 'integer',
          required: false,
          example: 10,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'RecurrenceRuleRequest',
      required: <String>['frequency'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'frequency',
          type: 'string',
          required: true,
          enumValues: <String>[
            'secondly',
            'minutely',
            'hourly',
            'daily',
            'weekly',
            'monthly',
            'yearly',
          ],
          example: 'daily',
        ),
        ApiPropertyDoc(
          name: 'interval',
          type: 'integer',
          required: false,
          example: 1,
        ),
        ApiPropertyDoc(
          name: 'end',
          ref: 'RecurrenceEndRequest',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ScheduledTriggerRequest',
      required: <String>['triggerName', 'time', 'recurrenceRule'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'daily_checkin',
        ),
        ApiPropertyDoc(name: 'time', ref: 'TimeOfDayRequest', required: true),
        ApiPropertyDoc(
          name: 'recurrenceRule',
          ref: 'RecurrenceRuleRequest',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'UserTaskTriggerRequest',
      required: <String>['triggerName', 'taskName', 'triggerCondition'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'survey_completion_trigger',
        ),
        ApiPropertyDoc(
          name: 'taskName',
          type: 'string',
          required: true,
          example: 'daily_survey',
        ),
        ApiPropertyDoc(
          name: 'triggerCondition',
          type: 'string',
          required: true,
          enumValues: <String>[
            'initialized',
            'enqueued',
            'dequeued',
            'notified',
            'started',
            'canceled',
            'done',
            'expired',
            'undefined',
          ],
          example: 'done',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'SamplingEventTriggerRequest',
      required: <String>['triggerName', 'measureType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'after_completed_task',
        ),
        ApiPropertyDoc(
          name: 'measureType',
          type: 'string',
          required: true,
          example: 'dk.cachet.carp.completed_task',
        ),
        ApiPropertyDoc(
          name: 'triggerCondition',
          ref: 'SerializedCarpDataRequest',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'SerializedCarpDataRequest',
      required: <String>['__type'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: '__type',
          type: 'string',
          required: true,
          example: 'dk.cachet.carp.common.application.data.completedtask',
        ),
      ],
    ),
  ],
)
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
    description: 'Returns trigger summaries currently configured in the '
        'session protocol. Each summary includes the full serialized trigger '
        'object, which contains a __type discriminator identifying the '
        'concrete CARP trigger type.',
    sharedParameterRefs: <String>['sessionId'],
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
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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
    description: 'Adds a cron-based scheduled trigger. triggerName must be '
        'unique within the protocol. The individual cron fields (minute, '
        'hour, dayOfMonth, month, dayOfWeek) are all optional; an omitted '
        'field matches all values. Returns 400 if any field is out of range '
        'or triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Cron scheduled trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload, cron field range, or trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/date-time',
    summary: 'Add a date-time trigger to the session protocol',
    operationId: 'addDateTimeTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires once at the specified date and '
        'time. triggerName must be unique within the protocol. schedule '
        'must be a valid ISO 8601 date-time string. Returns 400 if the '
        'format is invalid or triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Date-time trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/delayed',
    summary: 'Add a delayed trigger to the session protocol',
    operationId: 'addDelayedTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires after a fixed delay from when '
        'sensing starts. triggerName must be unique within the protocol. '
        'delay is specified as a DurationRequest object with optional days, '
        'hours, minutes, seconds, milliseconds, and microseconds fields. '
        'Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Delayed trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/elapsed-time',
    summary: 'Add an elapsed-time trigger to the session protocol',
    operationId: 'addElapsedTimeTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires when elapsed time from sensing '
        'start reaches the specified duration. triggerName must be unique '
        'within the protocol. elapsedTime is specified as a DurationRequest '
        'object. Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Elapsed-time trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/immediate',
    summary: 'Add an immediate trigger to the session protocol',
    operationId: 'addImmediateTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires immediately when sensing starts. '
        'triggerName must be unique within the protocol. Returns 400 if '
        'triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Immediate trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/manual',
    summary: 'Add a manual trigger to the session protocol',
    operationId: 'addManualTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that is fired manually by the participant '
        'or researcher. triggerName must be unique within the protocol. '
        'label and description are shown to the participant in the app. '
        'Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Manual trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/no-user-task',
    summary: 'Add a no-user-task trigger to the session protocol',
    operationId: 'addNoUserTaskTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires when the specified user task is '
        'absent from the task list. triggerName must be unique within the '
        'protocol. taskName references the task that must be absent. '
        'Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'No-user-task trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/one-time',
    summary: 'Add a one-time trigger to the session protocol',
    operationId: 'addOneTimeTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires exactly once during the entire '
        'study deployment. triggerName must be unique within the protocol. '
        'Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'One-time trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/passive',
    summary: 'Add a passive trigger to the session protocol',
    operationId: 'addPassiveTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a passive trigger that fires only when explicitly '
        'triggered from application code — no automatic scheduling. '
        'triggerName must be unique within the protocol. Returns 400 if '
        'triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Passive trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/periodic',
    summary: 'Add a periodic trigger to the session protocol',
    operationId: 'addPeriodicTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires repeatedly at a fixed interval. '
        'triggerName must be unique within the protocol. period is specified '
        'as a DurationRequest object and must be greater than zero. Returns '
        '400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Periodic trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/random-recurrent',
    summary: 'Add a random recurrent trigger to the session protocol',
    operationId: 'addRandomRecurrentTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires at random times within a daily '
        'time window. triggerName must be unique within the protocol. '
        'minNumberOfTriggers and maxNumberOfTriggers bound how many times '
        'the trigger may fire each day. startTime and endTime define the '
        'daily window as clock time objects with hour and minute fields. '
        'Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Random recurrent trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/recurrent-scheduled',
    summary: 'Add a recurrent scheduled trigger to the session protocol',
    operationId: 'addRecurrentScheduledTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires at a fixed clock time on a '
        'recurring schedule. triggerName must be unique within the protocol. '
        'type selects the recurrence (daily, weekly, monthly). For weekly '
        'recurrence dayOfWeek is required (1=Monday); for monthly recurrence '
        'dayOfMonth is required. time specifies the clock time with hour and '
        'minute fields. Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Recurrent scheduled trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/scheduled',
    summary: 'Add a scheduled trigger to the session protocol',
    operationId: 'addScheduledTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger with a time and a full recurrence rule '
        'based on RFC 5545 concepts. triggerName must be unique within the '
        'protocol. time specifies the clock time (hour, minute, optional '
        'second). recurrenceRule selects the frequency (daily, weekly, '
        'monthly, yearly), the interval, and the end condition (never, '
        'count, or elapsed time). Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Scheduled trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/user-task',
    summary: 'Add a user-task trigger to the session protocol',
    operationId: 'addUserTaskTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires when a named user task reaches '
        'the specified state. triggerName must be unique within the protocol. '
        'taskName identifies the user task to watch; triggerCondition '
        'specifies the required state (e.g. done, expired, discarded). '
        'Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'User-task trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/triggers/sampling-event',
    summary: 'Add a sampling-event trigger to the session protocol',
    operationId: 'addSamplingEventTrigger',
    tags: <String>['Triggers'],
    description: 'Adds a trigger that fires when data of a specific measure '
        'type is sampled and optionally matches a condition. triggerName '
        'must be unique within the protocol. measureType is the CARP data '
        'type URI whose measurements are evaluated. triggerCondition is an '
        'optional serialized CARP Data object (including __type); when '
        'provided, only measurements matching its fields fire the trigger. '
        'Returns 400 if triggerName is a duplicate.',
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Sampling-event trigger added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or duplicate trigger name',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }
}
