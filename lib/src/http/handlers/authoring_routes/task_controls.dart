part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

@ApiSchemas(
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'TaskControlsResponse',
      required: <String>['taskControls'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'taskControls',
          type: 'array',
          itemsRef: 'TaskControlSummary',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'TaskControlSummary',
      required: <String>['taskControl', 'trigger', 'task', 'targetDevice'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'taskControl',
          type: 'object',
          required: true,
          additionalProperties: true,
        ),
        ApiPropertyDoc(
          name: 'trigger',
          type: 'object',
          required: true,
          additionalProperties: true,
        ),
        ApiPropertyDoc(
          name: 'task',
          type: 'object',
          required: true,
          additionalProperties: true,
        ),
        ApiPropertyDoc(
          name: 'targetDevice',
          type: 'object',
          required: true,
          additionalProperties: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'TaskControlRequest',
      required: <String>['taskName', 'triggerName', 'deviceRoleName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'taskName',
          type: 'string',
          required: true,
          example: 'daily_survey',
        ),
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'start_now',
        ),
        ApiPropertyDoc(
          name: 'deviceRoleName',
          type: 'string',
          required: true,
          example: 'User Phone',
        ),
      ],
    ),
  ],
)
mixin TaskControlsRoutes on AuthoringRoutesBase {
  @override
  void registerTaskControlsRoutes(Router router) {
    router.get('/sessions/<sessionId>/task-controls', _getTaskControls);
    router.post('/sessions/<sessionId>/task-controls', _addTaskControl);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/task-controls',
    summary: 'Get task controls from the session protocol',
    operationId: 'getTaskControls',
    tags: <String>['Task Controls'],
    description:
        'Returns configured task controls currently in the session protocol, including taskControl, trigger, task, and targetDevice payloads for each entry.',
    sharedParameterRefs: <String>['sessionId'],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Expanded task control entries returned',
        schemaRef: 'TaskControlsResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing session id',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _getTaskControls(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() {
      final stateJson = _service.getTaskControls(sessionId);
      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/sessions/{sessionId}/task-controls',
    summary: 'Add a task control to the session protocol',
    operationId: 'addTaskControl',
    tags: <String>['Task Controls'],
    description:
        'Adds a task control that binds a trigger, task, and destination device role in the session protocol.',
    sharedParameterRefs: <String>['sessionId'],
    requestBody: ApiRequestBodyDoc(
      schemaRef: 'TaskControlRequest',
      description: 'Task control payload.',
      required: true,
      example: <String, Object?>{
        'taskName': 'daily_survey',
        'triggerName': 'start_now',
        'deviceRoleName': 'User Phone',
      },
    ),
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.ok,
        description: 'Task control added',
        schemaRef: 'SessionMutationResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description:
            'Invalid request payload or unresolved task/trigger/device role references',
        schemaRef: 'ErrorResponse',
      ),
    ],
    sharedResponseRefs: <String>['SessionNotFound'],
  )
  Future<Response> _addTaskControl(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      final body = await _requireJsonBody(request);
      final payload = TaskControlRequest.fromJson(body);

      final stateJson = _service.addTaskControl(
        sessionId,
        payload.taskName,
        payload.triggerName,
        payload.deviceRoleName,
      );

      return jsonResponse(HttpStatus.ok, body: stateJson);
    });
  }
}
