part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin TasksRoutes on AuthoringRoutesBase {
  @override
  void registerTasksRoutes(Router router) {
    router.get('/sessions/<sessionId>/tasks', _getTasks);
    router.post('/sessions/<sessionId>/tasks/background', _addBackgroundTask);
    router.post('/sessions/<sessionId>/tasks/web', _addWebTask);
    router.post('/sessions/<sessionId>/tasks/app', _addAppTask);
    router.post('/sessions/<sessionId>/tasks/health-app', _addHealthAppTask);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/tasks',
    summary: 'Get task summaries from the session protocol',
    operationId: 'getTasks',
    tags: <String>['Tasks'],
    description:
        'Returns configured task names and serialized task configurations currently in the session protocol.',
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

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/tasks/background',
    summary: 'Add a background task to the session protocol',
    operationId: 'addBackgroundTask',
    tags: <String>['Tasks'],
    description:
        'Adds a background task with one or more measures to the current session protocol.',
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
      schemaRef: 'BackgroundTaskRequest',
      description: 'Background task payload.',
      required: true,
      example: <String, Object?>{
        'name': 'daily_context_collection',
        'description': 'Collect context snapshots during the day.',
        'duration': <String, Object?>{'minutes': 30},
        'measures': <Map<String, Object?>>[
          <String, Object?>{'measureType': 'dk.cachet.carp.activity'},
          <String, Object?>{
            'measureType': 'dk.cachet.carp.ambientlight',
            'samplingConfiguration': <String, Object?>{
              'samplingType': 'periodic',
              'interval': <String, Object?>{'minutes': 5},
              'duration': <String, Object?>{'seconds': 10},
            },
          },
        ],
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Background task added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or unsupported measure/sampling',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addBackgroundTask(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = BackgroundTaskRequest.fromJson(body);

      final stateJson = _service.addBackgroundTask(
        sessionId,
        payload.name,
        payload.description,
        _toTaskMeasureInputs(payload.measures),
        payload.duration?.toDuration(),
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/tasks/web',
    summary: 'Add a web task to the session protocol',
    operationId: 'addWebTask',
    tags: <String>['Tasks'],
    description:
        'Adds a web task with one or more measures and a valid URL to the current session protocol.',
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
      schemaRef: 'WebTaskRequest',
      description: 'Web task payload.',
      required: true,
      example: <String, Object?>{
        'name': 'daily_survey',
        'description': 'Open a daily web survey for participants.',
        'url': 'https://example.org/surveys/daily',
        'measures': <Map<String, Object?>>[
          <String, Object?>{'measureType': 'dk.cachet.carp.activity'},
        ],
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Web task added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload, invalid URL, or unsupported measure/sampling',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addWebTask(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = WebTaskRequest.fromJson(body);

      final stateJson = _service.addWebTask(
        sessionId,
        payload.name,
        payload.description,
        _toTaskMeasureInputs(payload.measures),
        payload.url,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/tasks/app',
    summary: 'Add an app task to the session protocol',
    operationId: 'addAppTask',
    tags: <String>['Tasks'],
    description:
        'Adds an app task with one or more measures and an app task type to the current session protocol.',
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
      schemaRef: 'AppTaskRequest',
      description: 'App task payload.',
      required: true,
      example: <String, Object?>{
        'name': 'daily_survey_app_task',
        'description': 'Run a survey task in the app.',
        'type': 'survey',
        'title': 'Daily Survey',
        'instructions': 'Answer the questionnaire in-app.',
        'minutesToComplete': 5,
        'expire': <String, Object?>{'hours': 2},
        'notification': true,
        'measures': <Map<String, Object?>>[
          <String, Object?>{'measureType': 'dk.cachet.carp.activity'},
        ],
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'App task added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload, unsupported app task type, or unsupported measure/sampling',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addAppTask(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = AppTaskRequest.fromJson(body);

      final stateJson = _service.addAppTask(
        sessionId,
        payload.name,
        payload.description,
        _toTaskMeasureInputs(payload.measures),
        payload.type,
        payload.title,
        payload.instructions,
        payload.minutesToComplete,
        payload.expire?.toDuration(),
        payload.notification,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/tasks/health-app',
    summary: 'Add a health app task to the session protocol',
    operationId: 'addHealthAppTask',
    tags: <String>['Tasks'],
    description:
        'Adds a health app task with one or more measures and health data types to the current session protocol.',
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
      schemaRef: 'HealthAppTaskRequest',
      description: 'Health app task payload.',
      required: true,
      example: <String, Object?>{
        'name': 'daily_health_assessment',
        'description': 'Collect daily health assessment in-app.',
        'title': 'Health Assessment',
        'instructions': 'Follow the health assessment steps.',
        'minutesToComplete': 5,
        'expire': <String, Object?>{'hours': 1},
        'notification': true,
        'types': <String>['STEPS'],
        'measures': <Map<String, Object?>>[
          <String, Object?>{'measureType': 'dk.cachet.carp.activity'},
        ],
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Health app task added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload, unsupported health data type, or unsupported measure/sampling',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _addHealthAppTask(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = HealthAppTaskRequest.fromJson(body);

      final stateJson = _service.addHealthAppTask(
        sessionId,
        payload.name,
        payload.description,
        _toTaskMeasureInputs(payload.measures),
        payload.title,
        payload.instructions,
        payload.minutesToComplete,
        payload.expire?.toDuration(),
        payload.notification,
        payload.types,
      );
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  List<TaskMeasureInput> _toTaskMeasureInputs(
    List<TaskMeasureRequest> measures,
  ) {
    return measures
        .map(
          (measure) => TaskMeasureInput(
            measureType: measure.measureType,
            samplingConfiguration: measure.samplingConfiguration == null
                ? null
                : TaskSamplingInput(
                    samplingType: measure.samplingConfiguration!.samplingType,
                    interval:
                        measure.samplingConfiguration!.interval?.toDuration(),
                    duration:
                        measure.samplingConfiguration!.duration?.toDuration(),
                    once: measure.samplingConfiguration!.once,
                    usePriorContexts:
                        measure.samplingConfiguration!.usePriorContexts,
                    stopRadius: measure.samplingConfiguration!.stopRadius,
                    placeRadius: measure.samplingConfiguration!.placeRadius,
                    stopDuration: measure.samplingConfiguration!.stopDuration
                        ?.toDuration(),
                  ),
          ),
        )
        .toList(growable: false);
  }
}
