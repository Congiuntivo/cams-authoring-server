part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'TaskSummary',
      required: <String>['name', 'serializedObj'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: true,
          example: 'daily_survey',
        ),
        ApiPropertyDoc(
          name: 'serializedObj',
          type: 'object',
          required: true,
          additionalProperties: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'TasksResponse',
      required: <String>['tasks'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'tasks',
          type: 'array',
          itemsRef: 'TaskSummary',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'TaskSamplingConfigurationRequest',
      required: <String>['samplingType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'samplingType',
          type: 'string',
          required: true,
          enumValues: <String>[
            'none',
            'interval',
            'periodic',
            'location',
            'mobility',
          ],
        ),
        ApiPropertyDoc(
          name: 'interval',
          ref: 'DurationRequest',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'duration',
          ref: 'DurationRequest',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'once',
          type: 'boolean',
          required: false,
          example: false,
        ),
        ApiPropertyDoc(
          name: 'usePriorContexts',
          type: 'boolean',
          required: false,
          example: true,
        ),
        ApiPropertyDoc(
          name: 'stopRadius',
          type: 'number',
          required: false,
          example: 25,
        ),
        ApiPropertyDoc(
          name: 'placeRadius',
          type: 'number',
          required: false,
          example: 50,
        ),
        ApiPropertyDoc(
          name: 'stopDuration',
          ref: 'DurationRequest',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'TaskMeasureRequest',
      required: <String>['measureType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'measureType',
          type: 'string',
          required: true,
          enumValues: <String>[
            'dk.cachet.carp.acceleration',
            'dk.cachet.carp.accelerationfeatures',
            'dk.cachet.carp.activity',
            'dk.cachet.carp.airquality',
            'dk.cachet.carp.ambientlight',
            'dk.cachet.carp.batterystate',
            'dk.cachet.carp.deviceinformation',
            'dk.cachet.carp.freememory',
            'dk.cachet.carp.geofence',
            'dk.cachet.carp.location',
            'dk.cachet.carp.magneticfield',
            'dk.cachet.carp.mobility',
            'dk.cachet.carp.movesense.deviceinformation',
            'dk.cachet.carp.movesense.ecg',
            'dk.cachet.carp.movesense.hr',
            'dk.cachet.carp.movesense.imu',
            'dk.cachet.carp.movesense.state',
            'dk.cachet.carp.movesense.temperature',
            'dk.cachet.carp.nongravitationalacceleration',
            'dk.cachet.carp.polar.accelerometer',
            'dk.cachet.carp.polar.ecg',
            'dk.cachet.carp.polar.gyroscope',
            'dk.cachet.carp.polar.hr',
            'dk.cachet.carp.polar.magnetometer',
            'dk.cachet.carp.polar.ppg',
            'dk.cachet.carp.polar.ppi',
            'dk.cachet.carp.rotation',
            'dk.cachet.carp.screenevent',
            'dk.cachet.carp.stepevent',
            'dk.cachet.carp.timezone',
            'dk.cachet.carp.weather',
          ],
        ),
        ApiPropertyDoc(
          name: 'samplingConfiguration',
          ref: 'TaskSamplingConfigurationRequest',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'BackgroundTaskRequest',
      required: <String>['name', 'description', 'measures'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: true,
          example: 'daily_context_collection',
        ),
        ApiPropertyDoc(
          name: 'description',
          type: 'string',
          required: true,
          example: 'Collect context snapshots during the day.',
        ),
        ApiPropertyDoc(
          name: 'measures',
          type: 'array',
          itemsRef: 'TaskMeasureRequest',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'duration',
          ref: 'DurationRequest',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'WebTaskRequest',
      required: <String>['name', 'description', 'measures', 'url'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: true,
          example: 'daily_survey',
        ),
        ApiPropertyDoc(
          name: 'description',
          type: 'string',
          required: true,
          example: 'Open a daily web survey for participants.',
        ),
        ApiPropertyDoc(
          name: 'measures',
          type: 'array',
          itemsRef: 'TaskMeasureRequest',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'url',
          type: 'string',
          required: true,
          example: 'https://example.org/surveys/daily',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'AppTaskRequest',
      required: <String>['name', 'description', 'measures', 'type'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: true,
          example: 'daily_survey_app_task',
        ),
        ApiPropertyDoc(
          name: 'description',
          type: 'string',
          required: true,
          example: 'Run a survey task in the app.',
        ),
        ApiPropertyDoc(
          name: 'measures',
          type: 'array',
          itemsRef: 'TaskMeasureRequest',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'type',
          type: 'string',
          required: true,
          example: 'survey',
        ),
        ApiPropertyDoc(
          name: 'title',
          type: 'string',
          required: false,
          example: 'Daily Survey',
        ),
        ApiPropertyDoc(
          name: 'instructions',
          type: 'string',
          required: false,
          example: 'Answer the questionnaire in-app.',
        ),
        ApiPropertyDoc(
          name: 'minutesToComplete',
          type: 'integer',
          required: false,
          example: 5,
        ),
        ApiPropertyDoc(
          name: 'expire',
          ref: 'DurationRequest',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'notification',
          type: 'boolean',
          required: false,
          example: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'HealthAppTaskRequest',
      required: <String>['name', 'description', 'measures', 'types'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: true,
          example: 'daily_health_assessment',
        ),
        ApiPropertyDoc(
          name: 'description',
          type: 'string',
          required: true,
          example: 'Collect daily health assessment in-app.',
        ),
        ApiPropertyDoc(
          name: 'measures',
          type: 'array',
          itemsRef: 'TaskMeasureRequest',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'types',
          type: 'array',
          itemsType: 'string',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'title',
          type: 'string',
          required: false,
          example: 'Health Assessment',
        ),
        ApiPropertyDoc(
          name: 'instructions',
          type: 'string',
          required: false,
          example: 'Follow the health assessment steps.',
        ),
        ApiPropertyDoc(
          name: 'minutesToComplete',
          type: 'integer',
          required: false,
          example: 5,
        ),
        ApiPropertyDoc(
          name: 'expire',
          ref: 'DurationRequest',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'notification',
          type: 'boolean',
          required: false,
          example: true,
        ),
      ],
    ),
  ],
)
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
    sharedParameterRefs: <String>['sessionId'],
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
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Background task added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Invalid request payload or unsupported measure/sampling',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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
      return jsonResponse(HttpStatus.created, body: stateJson);
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
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Web task added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload, invalid URL, or unsupported measure/sampling',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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
      return jsonResponse(HttpStatus.created, body: stateJson);
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
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'App task added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload, unsupported app task type, or unsupported measure/sampling',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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
      return jsonResponse(HttpStatus.created, body: stateJson);
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
    sharedParameterRefs: <String>['sessionId'],
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
        statusCode: HttpStatus.created,
        description: 'Health app task added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload, unsupported health data type, or unsupported measure/sampling',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
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
      return jsonResponse(HttpStatus.created, body: stateJson);
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
