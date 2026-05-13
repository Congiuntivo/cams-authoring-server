import 'dart:io';

import 'package:carp_context_package/carp_context_package.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('GET /sessions/{sessionId}/tasks returns empty task list by default',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final tasks = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/tasks'),
      );

      expect(tasks['statusCode'], HttpStatus.ok);
      expect(tasks['json'], <String, dynamic>{
        'tasks': <Map<String, dynamic>>[],
      });

      final addBackgroundTask = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'daily_context_collection',
          'description': 'Collect context snapshots during the day.',
          'duration': <String, dynamic>{'minutes': 30},
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );
      expect(addBackgroundTask['statusCode'], HttpStatus.created);
      expect((addBackgroundTask['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final updatedTasks = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/tasks'),
      );
      expect(updatedTasks['statusCode'], HttpStatus.ok);
      final tasksAfterCreate =
          (updatedTasks['json'] as Map<String, dynamic>)['tasks'] as List;
      final createdTaskExists = tasksAfterCreate.any(
        (task) =>
            task is Map<String, dynamic> &&
            task['name'] == 'daily_context_collection' &&
            task['serializedObj'] is Map<String, dynamic>,
      );
      expect(createdTaskExists, isTrue);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/tasks/background validates required fields and allows empty measures',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final missingMeasures = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'task_without_measures',
          'description': 'Invalid task',
        },
      );
      expect(missingMeasures['statusCode'], HttpStatus.badRequest);
      expect((missingMeasures['json'] as Map<String, dynamic>)['error'],
          contains('measures'));

      final emptyMeasures = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'task_with_empty_measures',
          'description': 'Invalid task',
          'measures': <Object?>[],
        },
      );
      expect(emptyMeasures['statusCode'], HttpStatus.created);
      expect((emptyMeasures['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final blankName = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': '   ',
          'description': 'Invalid task',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{'measureType': ContextSamplingPackage.ACTIVITY},
          ],
        },
      );
      expect(blankName['statusCode'], HttpStatus.badRequest);
      expect((blankName['json'] as Map<String, dynamic>)['error'],
          contains('name'));

      final blankDescription = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'valid_name',
          'description': '  ',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{'measureType': ContextSamplingPackage.ACTIVITY},
          ],
        },
      );
      expect(blankDescription['statusCode'], HttpStatus.badRequest);
      expect((blankDescription['json'] as Map<String, dynamic>)['error'],
          contains('description'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/tasks/background validates duration, measureType, and sampling compatibility',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidDuration = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'bad_duration',
          'description': 'Invalid task',
          'duration': <String, dynamic>{'seconds': -1},
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{'measureType': ContextSamplingPackage.ACTIVITY},
          ],
        },
      );
      expect(invalidDuration['statusCode'], HttpStatus.badRequest);
      expect((invalidDuration['json'] as Map<String, dynamic>)['error'],
          contains('duration'));

      final invalidMeasureType = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'bad_measure_type',
          'description': 'Invalid task',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{'measureType': 'not.supported.measure'},
          ],
        },
      );
      expect(invalidMeasureType['statusCode'], HttpStatus.badRequest);
      expect((invalidMeasureType['json'] as Map<String, dynamic>)['error'],
          contains('Unsupported measureType'));

      final incompatibleSampling = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'bad_sampling',
          'description': 'Invalid task',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.AIR_QUALITY,
              'samplingConfiguration': <String, dynamic>{
                'samplingType': 'interval',
                'interval': <String, dynamic>{'seconds': 30},
              },
            },
          ],
        },
      );
      expect(incompatibleSampling['statusCode'], HttpStatus.badRequest);
      expect((incompatibleSampling['json'] as Map<String, dynamic>)['error'],
          contains('not supported for measureType'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/tasks/background returns 404 for missing session',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/does-not-exist/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'daily_context_collection',
          'description': 'Collect context snapshots during the day.',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{'measureType': ContextSamplingPackage.ACTIVITY},
          ],
        },
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

  test('POST /sessions/{sessionId}/tasks/web adds web task to session',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addWebTask = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/web'),
        jsonBody: <String, dynamic>{
          'name': 'daily_survey',
          'description': 'Open daily survey in browser.',
          'url': 'https://example.org/surveys/daily',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      expect(addWebTask['statusCode'], HttpStatus.created);
      expect(
        (addWebTask['json'] as Map<String, dynamic>)['sessionId'],
        sessionId,
      );

      final tasks = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/tasks'),
      );
      expect(tasks['statusCode'], HttpStatus.ok);
      final storedTasks =
          (tasks['json'] as Map<String, dynamic>)['tasks'] as List<dynamic>;
      final createdTaskExists = storedTasks.any(
        (task) =>
            task is Map<String, dynamic> &&
            task['name'] == 'daily_survey' &&
            task['serializedObj'] is Map<String, dynamic>,
      );
      expect(createdTaskExists, isTrue);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/tasks/web validates url and allows empty measures',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidUrl = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/web'),
        jsonBody: <String, dynamic>{
          'name': 'daily_survey',
          'description': 'Open daily survey in browser.',
          'url': 'invalid-url',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );
      expect(invalidUrl['statusCode'], HttpStatus.badRequest);
      expect((invalidUrl['json'] as Map<String, dynamic>)['error'],
          contains('Invalid URL'));

      final emptyMeasures = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/web'),
        jsonBody: <String, dynamic>{
          'name': 'daily_survey',
          'description': 'Open daily survey in browser.',
          'url': 'https://example.org/surveys/daily',
          'measures': <Object?>[],
        },
      );
      expect(emptyMeasures['statusCode'], HttpStatus.created);
      expect((emptyMeasures['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/tasks/app adds app task to session',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addAppTask = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/app'),
        jsonBody: <String, dynamic>{
          'name': 'daily_survey_app_task',
          'description': 'Run a survey task in the app.',
          'type': 'survey',
          'title': 'Daily Survey',
          'instructions': 'Answer the questionnaire in-app.',
          'minutesToComplete': 5,
          'expire': <String, dynamic>{'hours': 2},
          'notification': true,
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      expect(addAppTask['statusCode'], HttpStatus.created);
      expect(
        (addAppTask['json'] as Map<String, dynamic>)['sessionId'],
        sessionId,
      );

      final tasks = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/tasks'),
      );
      expect(tasks['statusCode'], HttpStatus.ok);
      final storedTasks =
          (tasks['json'] as Map<String, dynamic>)['tasks'] as List<dynamic>;
      final createdTaskExists = storedTasks.any(
        (task) =>
            task is Map<String, dynamic> &&
            task['name'] == 'daily_survey_app_task' &&
            task['serializedObj'] is Map<String, dynamic>,
      );
      expect(createdTaskExists, isTrue);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/tasks/app validates task type', () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidType = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/app'),
        jsonBody: <String, dynamic>{
          'name': 'bad_app_task_type',
          'description': 'Invalid app task type.',
          'type': 'unsupported_type',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      expect(invalidType['statusCode'], HttpStatus.badRequest);
      expect((invalidType['json'] as Map<String, dynamic>)['error'],
          contains('Unsupported app task type'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/tasks/app allows empty measures', () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final response = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/app'),
        jsonBody: <String, dynamic>{
          'name': 'empty_measures_app_task',
          'description': 'Allow app task without measures.',
          'type': 'survey',
          'measures': <Object?>[],
        },
      );

      expect(response['statusCode'], HttpStatus.created);
      expect(
          (response['json'] as Map<String, dynamic>)['sessionId'], sessionId);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/tasks/health-app adds health app task',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addHealthAppTask = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/health-app'),
        jsonBody: <String, dynamic>{
          'name': 'daily_health_assessment',
          'description': 'Collect daily health assessment in-app.',
          'title': 'Health Assessment',
          'instructions': 'Follow the health assessment steps.',
          'minutesToComplete': 5,
          'expire': <String, dynamic>{'hours': 1},
          'notification': true,
          'types': <String>['STEPS'],
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      expect(addHealthAppTask['statusCode'], HttpStatus.created);
      expect(
        (addHealthAppTask['json'] as Map<String, dynamic>)['sessionId'],
        sessionId,
      );

      final tasks = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/tasks'),
      );
      expect(tasks['statusCode'], HttpStatus.ok);
      final storedTasks =
          (tasks['json'] as Map<String, dynamic>)['tasks'] as List<dynamic>;
      final createdTaskExists = storedTasks.any(
        (task) =>
            task is Map<String, dynamic> &&
            task['name'] == 'daily_health_assessment' &&
            task['serializedObj'] is Map<String, dynamic>,
      );
      expect(createdTaskExists, isTrue);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/tasks/health-app validates health data types',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidTypes = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/health-app'),
        jsonBody: <String, dynamic>{
          'name': 'bad_health_app_task_type',
          'description': 'Invalid health app task types.',
          'types': <String>['not_a_health_type'],
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      expect(invalidTypes['statusCode'], HttpStatus.badRequest);
      expect((invalidTypes['json'] as Map<String, dynamic>)['error'],
          contains('Unsupported healthDataType'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/tasks/health-app allows empty measures',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final response = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/health-app'),
        jsonBody: <String, dynamic>{
          'name': 'empty_measures_health_task',
          'description': 'Allow health task without explicit measures.',
          'types': <String>['STEPS'],
          'measures': <Object?>[],
        },
      );

      expect(response['statusCode'], HttpStatus.created);
      expect(
          (response['json'] as Map<String, dynamic>)['sessionId'], sessionId);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /sessions/{sessionId}/tasks returns 404 for missing session',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/does-not-exist/tasks'),
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
      'task control endpoints add and return task controls on session-scoped paths',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-devices/smartphone'),
        jsonBody: <String, dynamic>{
          'roleName': 'User Phone',
        },
      );

      const taskName = 'daily_context_collection';
      const triggerName = 'start_now';
      final expectedWarning =
          'Task "$taskName" must be used by at least one task control.';
      final triggerWarning =
          'Trigger "$triggerName" must be used by at least one task control.';

      final addTask = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': taskName,
          'description': 'Collect context snapshots during the day.',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      expect(addTask['statusCode'], HttpStatus.created);
      expect(
        ((addTask['json'] as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'],
        contains(expectedWarning),
      );

      final addTrigger = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': triggerName,
        },
      );

      expect(addTrigger['statusCode'], HttpStatus.created);
      expect(
        (((addTrigger['json']
                as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        contains(triggerWarning),
      );

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/e-sense'),
        jsonBody: <String, dynamic>{
          'roleName': 'Left Earbud',
          'primaryDeviceRoleName': 'User Phone',
          'samplingRate': 20,
        },
      );

      final addTaskControl = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
        jsonBody: <String, dynamic>{
          'taskName': taskName,
          'triggerName': triggerName,
          'deviceRoleName': 'Left Earbud',
        },
      );

      expect(addTaskControl['statusCode'], HttpStatus.created);
      expect(
        (addTaskControl['json'] as Map<String, dynamic>)['sessionId'],
        sessionId,
      );
      expect(
        (((addTaskControl['json']
                as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        isNot(contains(expectedWarning)),
      );
      expect(
        (((addTaskControl['json']
                as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        isNot(contains(triggerWarning)),
      );

      final taskControls = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
      );

      expect(taskControls['statusCode'], HttpStatus.ok);
      final controls = (taskControls['json']
          as Map<String, dynamic>)['taskControls'] as List<dynamic>;
      expect(controls, isNotEmpty);
      final firstControl = controls.first as Map<String, dynamic>;
      expect(firstControl['taskControl'], isA<Map<String, dynamic>>());
      expect(firstControl['trigger'], isA<Map<String, dynamic>>());
      expect(firstControl['task'], isA<Map<String, dynamic>>());
      expect(firstControl['targetDevice'], isA<Map<String, dynamic>>());

      final taskControlJson =
          firstControl['taskControl'] as Map<String, dynamic>;
      expect(taskControlJson['taskName'], isA<String>());
      expect((taskControlJson['taskName'] as String).trim(), isNotEmpty);

      final triggerJson = firstControl['trigger'] as Map<String, dynamic>;
      expect(triggerJson, isNotEmpty);

      final taskJson = firstControl['task'] as Map<String, dynamic>;
      expect(taskJson['name'], isA<String>());
      expect((taskJson['name'] as String).trim(), isNotEmpty);
      expect(taskControlJson['taskName'], taskJson['name']);

      final targetDeviceJson =
          firstControl['targetDevice'] as Map<String, dynamic>;
      expect(targetDeviceJson['roleName'], 'User Phone');
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });
}
