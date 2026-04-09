part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

mixin TasksRoutes on AuthoringRoutesBase {
  @override
  void registerTasksRoutes(Router router) {
    router.get('/sessions/<sessionId>/tasks', _getTasks);
    router.post('/sessions/<sessionId>/tasks/background', _addBackgroundTask);
    router.post('/sessions/<sessionId>/tasks/web', _addWebTask);
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
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
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
        'durationSeconds': 1800,
        'measures': <Map<String, Object?>>[
          <String, Object?>{'measureType': 'dk.cachet.carp.activity'},
          <String, Object?>{
            'measureType': 'dk.cachet.carp.ambientlight',
            'samplingConfiguration': <String, Object?>{
              'samplingType': 'periodic',
              'intervalSeconds': 300,
              'durationSeconds': 10,
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
        payload.durationSeconds,
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
        description:
            'Session id returned by POST /protocol/new/smartphone or POST /protocol/new/default.',
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
                    intervalSeconds:
                        measure.samplingConfiguration!.intervalSeconds,
                    durationSeconds:
                        measure.samplingConfiguration!.durationSeconds,
                    once: measure.samplingConfiguration!.once,
                    usePriorContexts:
                        measure.samplingConfiguration!.usePriorContexts,
                    stopRadius: measure.samplingConfiguration!.stopRadius,
                    placeRadius: measure.samplingConfiguration!.placeRadius,
                    stopDurationSeconds:
                        measure.samplingConfiguration!.stopDurationSeconds,
                  ),
          ),
        )
        .toList(growable: false);
  }
}
