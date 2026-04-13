part of 'package:study_protocol_authoring_server/src/http/handlers/authoring_routes.dart';

abstract class AuthoringRoutesBase {
  AuthoringRoutesBase(this._service);

  final ProtocolAuthoringService _service;

  static const String defaultProtocolName = 'Unnamed Protocol';
  static const List<String> supportedEndpointTypes = <String>['CAWS', 'SQLITE'];
  static const List<String> supportedUploadMethods = <String>[
    'stream',
    'datapoint',
    'file',
  ];
  static const List<String> supportedParticipantDataTypes = <String>[
    'sex',
    'phone_number',
    'ssn',
    'full_name',
    'informed_consent',
    'address',
    'diagnosis',
    'custom',
  ];

  void register(Router router);

  void registerParticipantRoleRoutes(Router router);

  void registerParticipantExpectedDataRoutes(Router router);

  void registerDataEndpointRoutes(Router router);

  void registerPrimaryDeviceRoutes(Router router);

  void registerServicesRoutes(Router router);

  void registerDeviceRoutes(Router router);

  void registerTasksRoutes(Router router);

  void registerTriggersRoutes(Router router);

  String? _sessionId(Request request) {
    final pathSessionId = request.params['sessionId'];
    if (pathSessionId != null && pathSessionId.trim().isNotEmpty) {
      return pathSessionId.trim();
    }

    return null;
  }

  Response _badRequestMissingSessionId() {
    return _badRequest(
        'Missing session id. Provide /sessions/{sessionId}/... path parameter.');
  }

  Response _sessionNotFoundResponse(String sessionId) {
    return jsonResponse(HttpStatus.notFound, body: <String, dynamic>{
      'error': 'Session not found: $sessionId',
    });
  }

  Response _badRequest(String message) {
    return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
      'error': message,
    });
  }

  Future<Map<String, dynamic>> _requireJsonBody(Request request) async {
    final body = await request.readAsString();
    if (body.trim().isEmpty) {
      throw const _BadRequestException(
        'Missing request body. Provide a JSON object payload.',
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const _BadRequestException(
        'Invalid JSON body. Expected a JSON object.',
      );
    }

    return decoded;
  }

  String? _optionalTrimmedQueryParam(Request request, String name) {
    final value = request.url.queryParameters[name];
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _requireQueryParam(
    Request request,
    String name,
    String missingMessage,
  ) {
    final value = _optionalTrimmedQueryParam(request, name);
    if (value == null) {
      throw _BadRequestException(missingMessage);
    }
    return value;
  }

  String _requireEnumQueryParam(
    Request request,
    String name,
    List<String> supportedValues, {
    String? missingMessage,
  }) {
    final value = _requireQueryParam(
      request,
      name,
      missingMessage ?? 'Missing $name. Provide ?$name=... query parameter.',
    );
    _validateEnumValue(name, value, supportedValues);
    return value;
  }

  void _validateEnumValue(
    String paramName,
    String value,
    List<String> supportedValues,
  ) {
    if (!supportedValues.contains(value)) {
      throw _BadRequestException(
        'Unsupported $paramName. Supported values: '
        '${supportedValues.join(', ')}.',
      );
    }
  }

  Future<Response> _runWithErrorHandling(
      FutureOr<Response> Function() body) async {
    try {
      return await body();
    } on SessionNotFoundException catch (error) {
      return _sessionNotFoundResponse(error.sessionId);
    } on _BadRequestException catch (error) {
      return _badRequest(error.message);
    } on FormatException catch (error) {
      return _badRequest(error.message);
    } on ArgumentError catch (error) {
      final message = error.message;
      return _badRequest(
        message == null ? error.toString() : message.toString(),
      );
    } on StateError catch (error) {
      return _badRequest(error.message);
    }
  }

  CarpUploadMethod _parseUploadMethod(String? raw) {
    if (raw == null || raw.trim().isEmpty) return CarpUploadMethod.stream;

    final normalized = raw.trim().toLowerCase();
    return switch (normalized) {
      'stream' => CarpUploadMethod.stream,
      'datapoint' => CarpUploadMethod.datapoint,
      'file' => CarpUploadMethod.file,
      _ => throw _BadRequestException(
          'Unsupported uploadMethod. Supported values: '
          '${supportedUploadMethods.join(', ')}.'),
    };
  }

  bool? _parseOptionalBool(String? raw, String paramName) {
    if (raw == null) return null;

    final normalized = raw.trim().toLowerCase();
    return switch (normalized) {
      'true' => true,
      'false' => false,
      _ => throw _BadRequestException(
          'Invalid boolean value for $paramName. Use true or false.'),
    };
  }

  bool? _parseOptionalBoolValue(Object? raw, String paramName) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is String) return _parseOptionalBool(raw, paramName);

    throw _BadRequestException(
      'Invalid boolean value for $paramName. Use true or false.',
    );
  }

  String? _parseOptionalStringValue(Object? raw, String paramName) {
    if (raw == null) return null;
    if (raw is! String) {
      throw _BadRequestException(
        'Invalid string value for $paramName. Use a text value.',
      );
    }

    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _requireStringValue(
    Object? raw,
    String paramName,
    String missingMessage,
  ) {
    final value = _parseOptionalStringValue(raw, paramName);
    if (value == null) {
      throw _BadRequestException(missingMessage);
    }
    return value;
  }

  int? _parseOptionalIntValue(Object? raw, String paramName) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) {
      final parsed = int.tryParse(raw.trim());
      if (parsed != null) return parsed;
    }

    throw _BadRequestException(
      'Invalid integer value for $paramName. Use an integer.',
    );
  }

  double? _parseOptionalDoubleValue(Object? raw, String paramName) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final parsed = double.tryParse(raw.trim());
      if (parsed != null) return parsed;
    }

    throw _BadRequestException(
      'Invalid number value for $paramName. Use a numeric value.',
    );
  }
}

@ApiController(
  title: 'Study Protocol Authoring API',
  version: '0.4.0',
  description:
      'Stateful API exposing session-scoped protocol state and serialization endpoints.',
  schemas: <ApiSchemaDoc>[
    ApiSchemaDoc(
      name: 'CreateSessionResponse',
      required: <String>['sessionId'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'sessionId',
          type: 'string',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DataEndpointResponse',
      required: <String>['sessionId', 'unfulfilledRequirements'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'sessionId',
          type: 'string',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'unfulfilledRequirements',
          type: 'object',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'SessionMutationResponse',
      required: <String>['sessionId', 'unfulfilledRequirements'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'sessionId',
          type: 'string',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'unfulfilledRequirements',
          type: 'object',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'RequirementsResponse',
      required: <String>['unfulfilledRequirements'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'unfulfilledRequirements',
          type: 'object',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'PrimaryDeviceResponse',
      required: <String>['roleName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleName',
          type: 'string',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ParticipantRolesResponse',
      required: <String>['roleNames'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleNames',
          type: 'array',
          itemsType: 'string',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ServiceRolesResponse',
      required: <String>['roleNames'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleNames',
          type: 'array',
          itemsType: 'string',
          required: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DeviceRolesResponse',
      required: <String>['roleNames'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'roleNames',
          type: 'array',
          itemsType: 'string',
          required: true,
        ),
      ],
    ),
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
        ApiPropertyDoc(
          name: 'delay',
          ref: 'DurationRequest',
          required: true,
        ),
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
      name: 'NoOpTriggerRequest',
      required: <String>['triggerName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'triggerName',
          type: 'string',
          required: true,
          example: 'always_on',
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
        ApiPropertyDoc(
          name: 'period',
          ref: 'DurationRequest',
          required: true,
        ),
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
        ApiPropertyDoc(
          name: 'time',
          ref: 'TimeOfDayRequest',
          required: true,
        ),
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
        ApiPropertyDoc(
          name: 'time',
          ref: 'TimeOfDayRequest',
          required: true,
        ),
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
    ApiSchemaDoc(
      name: 'DurationRequest',
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'days', type: 'integer', required: false),
        ApiPropertyDoc(name: 'hours', type: 'integer', required: false),
        ApiPropertyDoc(name: 'minutes', type: 'integer', required: false),
        ApiPropertyDoc(name: 'seconds', type: 'integer', required: false),
        ApiPropertyDoc(
          name: 'milliseconds',
          type: 'integer',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'microseconds',
          type: 'integer',
          required: false,
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
          example: 'dk.cachet.carp.activity',
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
    ApiSchemaDoc(
      name: 'SerializeResponse',
      required: <String>['name', 'ownerId', 'version'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          example: 'My Study Protocol',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'ownerId',
          type: 'string',
          example: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
          required: true,
        ),
        ApiPropertyDoc(
          name: 'version',
          type: 'integer',
          example: 0,
          required: true,
        ),
        ApiPropertyDoc(name: 'id', type: 'string', required: false),
        ApiPropertyDoc(name: 'createdOn', type: 'string', required: false),
        ApiPropertyDoc(name: 'description', type: 'string', required: false),
        ApiPropertyDoc(
          name: 'participantRoles',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'primaryDevices',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'connectedDevices',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'tasks',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'triggers',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'taskControls',
          type: 'array',
          itemsType: 'object',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'PrimaryDeviceRequest',
      required: <String>['deviceType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'deviceType',
          type: 'string',
          required: true,
          enumValues: <String>['smartphone', 'browser'],
          example: 'smartphone',
        ),
        ApiPropertyDoc(
          name: 'roleName',
          type: 'string',
          required: false,
          example: 'User Phone',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'DataEndpointRequest',
      required: <String>['endpointType'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'endpointType',
          type: 'string',
          required: true,
          enumValues: AuthoringRoutesBase.supportedEndpointTypes,
          example: 'CAWS',
        ),
        ApiPropertyDoc(
          name: 'uploadMethod',
          type: 'string',
          required: false,
          enumValues: AuthoringRoutesBase.supportedUploadMethods,
          example: 'stream',
        ),
        ApiPropertyDoc(
          name: 'name',
          type: 'string',
          required: false,
          example: 'CARP Web Services',
        ),
        ApiPropertyDoc(
          name: 'deleteWhenUploaded',
          type: 'boolean',
          required: false,
          example: true,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ESenseDeviceRequest',
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'roleName', type: 'string', required: false),
        ApiPropertyDoc(name: 'isOptional', type: 'boolean', required: false),
        ApiPropertyDoc(name: 'deviceName', type: 'string', required: false),
        ApiPropertyDoc(name: 'samplingRate', type: 'integer', required: false),
      ],
    ),
    ApiSchemaDoc(
      name: 'MovesenseDeviceRequest',
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'roleName', type: 'string', required: false),
        ApiPropertyDoc(name: 'isOptional', type: 'boolean', required: false),
        ApiPropertyDoc(name: 'name', type: 'string', required: false),
        ApiPropertyDoc(name: 'address', type: 'string', required: false),
        ApiPropertyDoc(name: 'serial', type: 'string', required: false),
        ApiPropertyDoc(
          name: 'deviceType',
          type: 'string',
          required: false,
          enumValues: <String>['UNKNOWN', 'MD', 'HR_PLUS', 'HR2', 'FLASH'],
          example: 'UNKNOWN',
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'MovisensDeviceRequest',
      required: <String>['deviceName'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'roleName', type: 'string', required: false),
        ApiPropertyDoc(
          name: 'deviceName',
          type: 'string',
          required: true,
          example: 'MOVISENS_ECG_01',
        ),
        ApiPropertyDoc(
          name: 'sensorLocation',
          type: 'string',
          required: false,
          enumValues: <String>[
            'RightSideHip',
            'Chest',
            'RightWrist',
            'LeftWrist',
            'LeftAnkle',
            'RightAnkle',
            'RightThigh',
            'LeftThigh',
            'RightUpperArm',
            'LeftUpperArm',
            'LeftSideHip',
          ],
        ),
        ApiPropertyDoc(
          name: 'sex',
          type: 'string',
          required: false,
          enumValues: <String>['Male', 'Female', 'Intersex'],
        ),
        ApiPropertyDoc(name: 'height', type: 'integer', required: false),
        ApiPropertyDoc(name: 'weight', type: 'integer', required: false),
        ApiPropertyDoc(name: 'age', type: 'integer', required: false),
      ],
    ),
    ApiSchemaDoc(
      name: 'PolarDeviceRequest',
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'roleName', type: 'string', required: false),
        ApiPropertyDoc(name: 'isOptional', type: 'boolean', required: false),
        ApiPropertyDoc(
          name: 'deviceType',
          type: 'string',
          required: false,
          enumValues: <String>['UNKNOWN', 'H9', 'H10', 'SENSE'],
        ),
        ApiPropertyDoc(name: 'identifier', type: 'string', required: false),
        ApiPropertyDoc(name: 'name', type: 'string', required: false),
      ],
    ),
    ApiSchemaDoc(
      name: 'LocationServiceRequest',
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(name: 'roleName', type: 'string', required: false),
        ApiPropertyDoc(
          name: 'accuracy',
          type: 'string',
          required: false,
          enumValues: <String>[
            'powerSave',
            'low',
            'balanced',
            'high',
            'navigation',
            'reduced',
          ],
        ),
        ApiPropertyDoc(name: 'distance', type: 'number', required: false),
        ApiPropertyDoc(
          name: 'interval',
          ref: 'DurationRequest',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'notificationTitle',
          type: 'string',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'notificationMessage',
          type: 'string',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'notificationDescription',
          type: 'string',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'notificationIconName',
          type: 'string',
          required: false,
        ),
        ApiPropertyDoc(
          name: 'notificationOnTapBringToFront',
          type: 'boolean',
          required: false,
        ),
      ],
    ),
    ApiSchemaDoc(
      name: 'ErrorResponse',
      required: <String>['error'],
      properties: <ApiPropertyDoc>[
        ApiPropertyDoc(
          name: 'error',
          type: 'string',
          required: true,
        ),
      ],
    ),
  ],
)
class AuthoringRoutes extends AuthoringRoutesBase
    with
        DataEndpointRoutes,
        PrimaryDeviceRoutes,
        ParticipantRoleRoutes,
        ParticipantExpectedDataRoutes,
        ServicesRoutes,
        DevicesRoutes,
        TasksRoutes,
        TriggersRoutes {
  AuthoringRoutes(super.service);

  @override
  void register(Router router) {
    router.get('/sessions/<sessionId>/requirements', _getRequirements);
    router.post('/protocol/new/smartphone', _startNewSmartphoneProtocol);
    router.post('/protocol/new/default', _startNewDefaultProtocol);
    router.get('/sessions/<sessionId>/serialize', _serializeProtocol);

    registerDataEndpointRoutes(router);
    registerPrimaryDeviceRoutes(router);
    registerParticipantRoleRoutes(router);
    registerParticipantExpectedDataRoutes(router);
    registerServicesRoutes(router);
    registerDeviceRoutes(router);
    registerTasksRoutes(router);
    registerTriggersRoutes(router);
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/requirements',
    summary: 'Get current unfulfilled requirements for the session',
    operationId: 'getRequirements',
    tags: <String>['Requirements and Serialization'],
    description:
        'Returns the current unfulfilled requirements for the session.',
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
        description: 'Current unfulfilled requirements for the session',
        schemaRef: 'RequirementsResponse',
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
  Future<Response> _getRequirements(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      return jsonResponse(
        HttpStatus.ok,
        body: _service.getRequirements(sessionId),
      );
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/new/smartphone',
    summary: 'Create a new smartphone protocol authoring session',
    operationId: 'createSmartphoneProtocolSession',
    tags: <String>['Sessions'],
    description:
        'Creates an in-memory authoring session for a smartphone protocol and returns a sessionId for subsequent requests.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'name',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'Name of the protocol (optional, default: "Unnamed Protocol")',
        example: 'My Study Protocol',
      ),
      ApiParameterDoc(
        name: 'ownerId',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'UUID of the protocol owner (optional, will be generated if not provided)',
        example: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'New authoring session created',
        schemaRef: 'CreateSessionResponse',
      ),
    ],
  )
  Future<Response> _startNewSmartphoneProtocol(Request request) async {
    return _runWithErrorHandling(() {
      final stateJson = _service.createNewProtocol(
        _optionalTrimmedQueryParam(request, 'name') ??
            AuthoringRoutesBase.defaultProtocolName,
        _optionalTrimmedQueryParam(request, 'ownerId'),
        true,
      );

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'post',
    path: '/protocol/new/default',
    summary: 'Create a new default protocol authoring session',
    operationId: 'createDefaultProtocolSession',
    tags: <String>['Sessions'],
    description:
        'Creates an in-memory authoring session for a default protocol and returns a sessionId for subsequent requests.',
    parameters: <ApiParameterDoc>[
      ApiParameterDoc(
        name: 'name',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'Name of the protocol (optional, default: "Unnamed Protocol")',
        example: 'My Study Protocol',
      ),
      ApiParameterDoc(
        name: 'ownerId',
        location: 'query',
        type: 'string',
        required: false,
        description:
            'UUID of the protocol owner (optional, will be generated if not provided)',
        example: '979b408d-784e-4b1b-bb1e-ff9204e072f3',
      ),
    ],
    responses: <ApiResponseDoc>[
      ApiResponseDoc(
        statusCode: HttpStatus.created,
        description: 'New authoring session created',
        schemaRef: 'CreateSessionResponse',
      ),
    ],
  )
  Future<Response> _startNewDefaultProtocol(Request request) async {
    return _runWithErrorHandling(() {
      final stateJson = _service.createNewProtocol(
        _optionalTrimmedQueryParam(request, 'name') ??
            AuthoringRoutesBase.defaultProtocolName,
        _optionalTrimmedQueryParam(request, 'ownerId'),
        false,
      );

      return jsonResponse(HttpStatus.created, body: stateJson);
    });
  }

  @ApiOperation(
    method: 'get',
    path: '/sessions/{sessionId}/serialize',
    summary: 'Return the serialized protocol for the session',
    operationId: 'serializeProtocol',
    tags: <String>['Requirements and Serialization'],
    description: 'Returns the serialized protocol for the session.',
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
        description: 'Serialized protocol for the session',
        schemaRef: 'SerializeResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.badRequest,
        description: 'Missing session id',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.conflict,
        description:
            'Protocol cannot be serialized until critical requirements are fulfilled',
        schemaRef: 'ErrorResponse',
      ),
      ApiResponseDoc(
        statusCode: HttpStatus.notFound,
        description: 'Session id not found',
        schemaRef: 'ErrorResponse',
      ),
    ],
  )
  Future<Response> _serializeProtocol(Request request) async {
    final sessionId = _sessionId(request);
    if (sessionId == null) return _badRequestMissingSessionId();

    return _runWithErrorHandling(() async {
      return jsonResponse(HttpStatus.ok, body: _service.serialize(sessionId));
    });
  }
}

class _BadRequestException implements Exception {
  const _BadRequestException(this.message);

  final String message;
}
