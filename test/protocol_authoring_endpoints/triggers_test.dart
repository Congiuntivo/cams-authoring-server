import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('GET /sessions/{sessionId}/triggers returns 404 for missing session',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/does-not-exist/triggers'),
      );

      expect(response['statusCode'], HttpStatus.notFound);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        contains('Session not found'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/cron adds cron trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addCronTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/cron'),
        jsonBody: <String, dynamic>{
          'triggerName': 'daily_evening_prompt',
          'minute': 30,
          'hour': 19,
        },
      );

      expect(addCronTrigger['statusCode'], HttpStatus.created);
      expect((addCronTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'daily_evening_prompt',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)['cronExpression'],
        '30 19 * * *',
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/cron validates cron field ranges',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidMinute = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/cron'),
        jsonBody: <String, dynamic>{
          'triggerName': 'invalid_cron',
          'minute': 60,
        },
      );

      expect(invalidMinute['statusCode'], HttpStatus.badRequest);
      expect((invalidMinute['json'] as Map<String, dynamic>)['error'],
          contains('minute must be in the range [0-59]'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/date-time adds date-time trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addDateTimeTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/date-time'),
        jsonBody: <String, dynamic>{
          'triggerName': 'enrollment_follow_up',
          'schedule': '2026-10-01T09:30:00Z',
        },
      );

      expect(addDateTimeTrigger['statusCode'], HttpStatus.created);
      expect((addDateTimeTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'enrollment_follow_up',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)['schedule'],
        '2026-10-01T09:30:00.000Z',
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/date-time validates schedule format',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidSchedule = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/date-time'),
        jsonBody: <String, dynamic>{
          'triggerName': 'bad_date_time',
          'schedule': 'not-a-date',
        },
      );

      expect(invalidSchedule['statusCode'], HttpStatus.badRequest);
      expect((invalidSchedule['json'] as Map<String, dynamic>)['error'],
          contains('Invalid schedule'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/delayed adds delayed trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addDelayedTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/delayed'),
        jsonBody: <String, dynamic>{
          'triggerName': 'delayed_prompt',
          'delay': <String, dynamic>{'minutes': 15},
        },
      );

      expect(addDelayedTrigger['statusCode'], HttpStatus.created);
      expect((addDelayedTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'delayed_prompt',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)
            .containsKey('delay'),
        isTrue,
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/delayed validates delay payload',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidDelay = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/delayed'),
        jsonBody: <String, dynamic>{
          'triggerName': 'bad_delayed',
          'delay': <String, dynamic>{},
        },
      );

      expect(invalidDelay['statusCode'], HttpStatus.badRequest);
      expect((invalidDelay['json'] as Map<String, dynamic>)['error'],
          contains('Provide at least one duration field'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/elapsed-time adds elapsed-time trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addElapsedTimeTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/elapsed-time'),
        jsonBody: <String, dynamic>{
          'triggerName': 'elapsed_30_minutes',
          'elapsedTime': <String, dynamic>{'minutes': 30},
        },
      );

      expect(addElapsedTimeTrigger['statusCode'], HttpStatus.created);
      expect(
          (addElapsedTimeTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'elapsed_30_minutes',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)
            .containsKey('elapsedTime'),
        isTrue,
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/elapsed-time validates elapsed-time payload',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidElapsedTime = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/elapsed-time'),
        jsonBody: <String, dynamic>{
          'triggerName': 'bad_elapsed',
          'elapsedTime': '30',
        },
      );

      expect(invalidElapsedTime['statusCode'], HttpStatus.badRequest);
      expect((invalidElapsedTime['json'] as Map<String, dynamic>)['error'],
          contains('Invalid elapsedTime'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/immediate adds immediate trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addImmediateTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': 'start_now',
        },
      );

      expect(addImmediateTrigger['statusCode'], HttpStatus.created);
      expect((addImmediateTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'start_now',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/immediate validates triggerName',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidImmediate = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{},
      );

      expect(invalidImmediate['statusCode'], HttpStatus.badRequest);
      expect((invalidImmediate['json'] as Map<String, dynamic>)['error'],
          contains('triggerName'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/manual adds manual trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addManualTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/manual'),
        jsonBody: <String, dynamic>{
          'triggerName': 'manual_daily_prompt',
          'label': 'Daily prompt',
          'description': 'Shown manually by the participant.',
        },
      );

      expect(addManualTrigger['statusCode'], HttpStatus.created);
      expect((addManualTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'manual_daily_prompt',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)['label'],
        'Daily prompt',
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/manual validates triggerName',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidManual = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/manual'),
        jsonBody: <String, dynamic>{
          'triggerName': '   ',
        },
      );

      expect(invalidManual['statusCode'], HttpStatus.badRequest);
      expect((invalidManual['json'] as Map<String, dynamic>)['error'],
          contains('triggerName'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/no-op adds no-op trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addNoOpTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/no-op'),
        jsonBody: <String, dynamic>{
          'triggerName': 'always_on',
        },
      );

      expect(addNoOpTrigger['statusCode'], HttpStatus.created);
      expect((addNoOpTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'always_on',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/no-op validates triggerName',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidNoOp = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/no-op'),
        jsonBody: <String, dynamic>{},
      );

      expect(invalidNoOp['statusCode'], HttpStatus.badRequest);
      expect((invalidNoOp['json'] as Map<String, dynamic>)['error'],
          contains('triggerName'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/no-user-task adds no-user-task trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addNoUserTaskTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/no-user-task'),
        jsonBody: <String, dynamic>{
          'triggerName': 'ensure_survey_task',
          'taskName': 'daily_survey',
        },
      );

      expect(addNoUserTaskTrigger['statusCode'], HttpStatus.created);
      expect(
          (addNoUserTaskTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'ensure_survey_task',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)['taskName'],
        'daily_survey',
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/no-user-task validates taskName',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidNoUserTask = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/no-user-task'),
        jsonBody: <String, dynamic>{
          'triggerName': 'ensure_survey_task',
          'taskName': '   ',
        },
      );

      expect(invalidNoUserTask['statusCode'], HttpStatus.badRequest);
      expect((invalidNoUserTask['json'] as Map<String, dynamic>)['error'],
          contains('taskName'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/one-time adds one-time trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addOneTimeTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/one-time'),
        jsonBody: <String, dynamic>{
          'triggerName': 'show_demographics_once',
        },
      );

      expect(addOneTimeTrigger['statusCode'], HttpStatus.created);
      expect((addOneTimeTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'show_demographics_once',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/one-time validates triggerName',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidOneTime = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/one-time'),
        jsonBody: <String, dynamic>{},
      );

      expect(invalidOneTime['statusCode'], HttpStatus.badRequest);
      expect((invalidOneTime['json'] as Map<String, dynamic>)['error'],
          contains('triggerName'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/passive adds passive trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addPassiveTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/passive'),
        jsonBody: <String, dynamic>{
          'triggerName': 'manual_code_trigger',
        },
      );

      expect(addPassiveTrigger['statusCode'], HttpStatus.created);
      expect((addPassiveTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'manual_code_trigger',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/passive validates triggerName',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidPassive = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/passive'),
        jsonBody: <String, dynamic>{
          'triggerName': '   ',
        },
      );

      expect(invalidPassive['statusCode'], HttpStatus.badRequest);
      expect((invalidPassive['json'] as Map<String, dynamic>)['error'],
          contains('triggerName'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/periodic adds periodic trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addPeriodicTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/periodic'),
        jsonBody: <String, dynamic>{
          'triggerName': 'periodic_prompt',
          'period': <String, dynamic>{'minutes': 20},
        },
      );

      expect(addPeriodicTrigger['statusCode'], HttpStatus.created);
      expect((addPeriodicTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'periodic_prompt',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)
            .containsKey('period'),
        isTrue,
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/triggers/periodic validates period payload',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidPeriodic = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/periodic'),
        jsonBody: <String, dynamic>{
          'triggerName': 'periodic_prompt',
          'period': <String, dynamic>{},
        },
      );

      expect(invalidPeriodic['statusCode'], HttpStatus.badRequest);
      expect((invalidPeriodic['json'] as Map<String, dynamic>)['error'],
          contains('Provide at least one duration field'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/random-recurrent adds random recurrent trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addRandomRecurrentTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/random-recurrent'),
        jsonBody: <String, dynamic>{
          'triggerName': 'random_daily_prompts',
          'minNumberOfTriggers': 3,
          'maxNumberOfTriggers': 8,
          'startTime': <String, dynamic>{'hour': 8, 'minute': 0},
          'endTime': <String, dynamic>{'hour': 20, 'minute': 0},
        },
      );

      expect(addRandomRecurrentTrigger['statusCode'], HttpStatus.created);
      expect(
          (addRandomRecurrentTrigger['json']
              as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'random_daily_prompts',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)
            .containsKey('minNumberOfTriggers'),
        isTrue,
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/random-recurrent validates time payload',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidRandomRecurrent = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/random-recurrent'),
        jsonBody: <String, dynamic>{
          'triggerName': 'random_daily_prompts',
          'minNumberOfTriggers': 3,
          'maxNumberOfTriggers': 8,
          'startTime': <String, dynamic>{'hour': 24, 'minute': 0},
          'endTime': <String, dynamic>{'hour': 20, 'minute': 0},
        },
      );

      expect(invalidRandomRecurrent['statusCode'], HttpStatus.badRequest);
      expect((invalidRandomRecurrent['json'] as Map<String, dynamic>)['error'],
          contains('Invalid hour'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/recurrent-scheduled adds recurrent scheduled trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addRecurrentScheduledTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri
            .resolve('/sessions/$sessionId/triggers/recurrent-scheduled'),
        jsonBody: <String, dynamic>{
          'triggerName': 'weekday_checkin',
          'type': 'weekly',
          'time': <String, dynamic>{'hour': 9, 'minute': 30},
          'dayOfWeek': 1,
        },
      );

      expect(addRecurrentScheduledTrigger['statusCode'], HttpStatus.created);
      expect(
          (addRecurrentScheduledTrigger['json']
              as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'weekday_checkin',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>).containsKey('type'),
        isTrue,
      );
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>).containsKey('time'),
        isTrue,
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/recurrent-scheduled validates recurrence type',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidRecurrentScheduled = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri
            .resolve('/sessions/$sessionId/triggers/recurrent-scheduled'),
        jsonBody: <String, dynamic>{
          'triggerName': 'weekday_checkin',
          'type': 'yearly',
          'time': <String, dynamic>{'hour': 9, 'minute': 30},
        },
      );

      expect(invalidRecurrentScheduled['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidRecurrentScheduled['json'] as Map<String, dynamic>)['error'],
        contains('Unsupported recurrent trigger type'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/scheduled adds scheduled trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addScheduledTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/scheduled'),
        jsonBody: <String, dynamic>{
          'triggerName': 'daily_checkin',
          'time': <String, dynamic>{'hour': 9, 'minute': 0},
          'recurrenceRule': <String, dynamic>{
            'frequency': 'daily',
            'interval': 1,
            'end': <String, dynamic>{'type': 'never'},
          },
        },
      );

      expect(addScheduledTrigger['statusCode'], HttpStatus.created);
      expect((addScheduledTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'daily_checkin',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)
            .containsKey('recurrenceRule'),
        isTrue,
      );
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>).containsKey('time'),
        isTrue,
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/scheduled validates recurrence frequency',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidScheduled = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/scheduled'),
        jsonBody: <String, dynamic>{
          'triggerName': 'daily_checkin',
          'time': <String, dynamic>{'hour': 9, 'minute': 0},
          'recurrenceRule': <String, dynamic>{
            'frequency': 'fortnightly',
          },
        },
      );

      expect(invalidScheduled['statusCode'], HttpStatus.badRequest);
      expect((invalidScheduled['json'] as Map<String, dynamic>)['error'],
          contains('Unsupported recurrence frequency'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/user-task adds user-task trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addUserTaskTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/user-task'),
        jsonBody: <String, dynamic>{
          'triggerName': 'survey_completion_trigger',
          'taskName': 'daily_survey',
          'triggerCondition': 'done',
        },
      );

      expect(addUserTaskTrigger['statusCode'], HttpStatus.created);
      expect((addUserTaskTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'survey_completion_trigger',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)['taskName'],
        'daily_survey',
      );
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)
            .containsKey('triggerCondition'),
        isTrue,
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/user-task validates trigger condition',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidUserTaskTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/user-task'),
        jsonBody: <String, dynamic>{
          'triggerName': 'survey_completion_trigger',
          'taskName': 'daily_survey',
          'triggerCondition': 'invalid_state',
        },
      );

      expect(invalidUserTaskTrigger['statusCode'], HttpStatus.badRequest);
      expect((invalidUserTaskTrigger['json'] as Map<String, dynamic>)['error'],
          contains('Unsupported triggerCondition'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/sampling-event adds sampling-event trigger and is visible in trigger list',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addSamplingEventTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/sampling-event'),
        jsonBody: <String, dynamic>{
          'triggerName': 'after_completed_task',
          'measureType': 'dk.cachet.carp.completed_task',
        },
      );

      expect(addSamplingEventTrigger['statusCode'], HttpStatus.created);
      expect(
          (addSamplingEventTrigger['json']
              as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      final triggerList =
          (triggers['json'] as Map<String, dynamic>)['triggers'] as List;
      final createdTrigger =
          triggerList.cast<Map<String, dynamic>>().firstWhere(
                (entry) => entry['name'] == 'after_completed_task',
              );
      expect(createdTrigger['trigger'], isA<Map<String, dynamic>>());
      expect(
        (createdTrigger['trigger'] as Map<String, dynamic>)['measureType'],
        'dk.cachet.carp.completed_task',
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/triggers/sampling-event validates triggerCondition payload',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidSamplingEventTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/sampling-event'),
        jsonBody: <String, dynamic>{
          'triggerName': 'after_completed_task',
          'measureType': 'dk.cachet.carp.completed_task',
          'triggerCondition': <String, dynamic>{
            'taskName': 'daily_survey',
          },
        },
      );

      expect(invalidSamplingEventTrigger['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidSamplingEventTrigger['json'] as Map<String, dynamic>)['error'],
        contains('Invalid triggerCondition'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });
}
