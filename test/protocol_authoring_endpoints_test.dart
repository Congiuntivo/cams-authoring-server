import 'dart:convert';
import 'dart:io';

import 'package:carp_context_package/carp_context_package.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:study_protocol_authoring_server/src/protocol_authoring_request_handler.dart';

Future<HttpServer> _startTestServer() async {
  final handler = ProtocolAuthoringRequestHandler();
  return shelf_io.serve(handler.handler, InternetAddress.loopbackIPv4, 0);
}

Future<Map<String, dynamic>> _requestJson({
  required HttpClient client,
  required String method,
  required Uri uri,
  Map<String, dynamic>? jsonBody,
}) async {
  final request = await client.openUrl(method, uri);
  if (jsonBody != null) {
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(jsonBody));
  }

  final response = await request.close();
  final body = await utf8.decoder.bind(response).join();
  return <String, dynamic>{
    'statusCode': response.statusCode,
    'json': jsonDecode(body) as Map<String, dynamic>,
  };
}

void main() {
  test(
      'POST /protocol/new/smartphone creates session used by session-scoped requirements and serialize',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final newProtocol = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      expect(newProtocol['statusCode'], HttpStatus.created);
      final sessionId =
          (newProtocol['json'] as Map<String, dynamic>)['sessionId'] as String;

      final requirements = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/requirements'),
      );
      expect(requirements['statusCode'], HttpStatus.ok);

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/data-endpoint'),
        jsonBody: <String, dynamic>{'endpointType': 'CAWS'},
      );

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'smartphone'},
      );

      final serialize = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/serialize'),
      );
      expect(serialize['statusCode'], HttpStatus.ok);
      final protocol = (serialize['json'] as Map<String, dynamic>)['protocol']
          as Map<String, dynamic>;
      expect(protocol['name'], 'Unnamed Protocol');
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/data-endpoint adds data endpoint', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addEndPoint = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/data-endpoint'),
        jsonBody: <String, dynamic>{
          'endpointType': 'CAWS',
          'uploadMethod': 'stream',
          'name': 'CARP Web Services',
          'deleteWhenUploaded': true,
        },
      );

      expect(addEndPoint['statusCode'], HttpStatus.ok);
      expect((addEndPoint['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /sessions/{sessionId}/primary-device supports smartphone and browser',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final smartphoneCreated = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final smartphoneSessionId = (smartphoneCreated['json']
          as Map<String, dynamic>)['sessionId'] as String;

      final addSmartphonePrimary = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$smartphoneSessionId/primary-device'),
        jsonBody: <String, dynamic>{
          'deviceType': 'smartphone',
          'roleName': 'User Phone',
        },
      );
      expect(addSmartphonePrimary['statusCode'], HttpStatus.ok);

      final getSmartphonePrimary = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$smartphoneSessionId/primary-device'),
      );
      expect(getSmartphonePrimary['statusCode'], HttpStatus.ok);
      expect((getSmartphonePrimary['json'] as Map<String, dynamic>)['roleName'],
          'User Phone');

      final defaultCreated = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/default'),
      );
      final defaultSessionId = (defaultCreated['json']
          as Map<String, dynamic>)['sessionId'] as String;

      final addBrowserPrimary = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$defaultSessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'browser'},
      );
      expect(addBrowserPrimary['statusCode'], HttpStatus.ok);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'participant role and expected-data endpoints work on session-scoped paths',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/data-endpoint'),
        jsonBody: <String, dynamic>{'endpointType': 'CAWS'},
      );

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'smartphone'},
      );

      final addRole = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri
            .resolve('/sessions/$sessionId/participant-roles?roleName=Patient'),
      );
      expect(addRole['statusCode'], HttpStatus.ok);

      final addExpectedRoleData = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/sessions/$sessionId/participant-roles/Patient/expected-data?dataType=sex',
        ),
      );
      expect(addExpectedRoleData['statusCode'], HttpStatus.ok);

      final addExpectedAllData = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri
            .resolve('/sessions/$sessionId/expected-data?dataType=address'),
      );
      expect(addExpectedAllData['statusCode'], HttpStatus.ok);

      final roles = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/participant-roles'),
      );
      expect(roles['statusCode'], HttpStatus.ok);
      expect(roles['json'], <String, dynamic>{
        'roleNames': <String>['Patient'],
      });
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('device endpoints use typed session paths with JSON body', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'smartphone'},
      );

      final addESense = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/e-sense'),
        jsonBody: <String, dynamic>{
          'roleName': 'Left Earbud',
          'samplingRate': 20,
        },
      );
      expect(addESense['statusCode'], HttpStatus.ok);

      final addPolar = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/polar'),
        jsonBody: <String, dynamic>{
          'roleName': 'Polar Chest Sensor',
          'deviceType': 'H10',
        },
      );
      expect(addPolar['statusCode'], HttpStatus.ok);

      final devices = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/devices'),
      );
      expect(devices['statusCode'], HttpStatus.ok);
      expect((devices['json'] as Map<String, dynamic>)['roleNames'],
          contains('Left Earbud'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('services endpoints use typed session paths', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'smartphone'},
      );

      final addWeather = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/sessions/$sessionId/services/weather?roleName=Local%20Weather',
        ),
      );
      expect(addWeather['statusCode'], HttpStatus.ok);

      final addLocation = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/location'),
        jsonBody: <String, dynamic>{
          'roleName': 'User Location',
          'accuracy': 'high',
          'distance': 25,
          'intervalSeconds': 30,
          'notificationTitle': 'Tracking active',
          'notificationMessage': 'Location tracking is running.',
          'notificationDescription': 'Tap to return to the app.',
          'notificationIconName': 'ic_notification',
          'notificationOnTapBringToFront': true,
        },
      );
      expect(addLocation['statusCode'], HttpStatus.ok);

      final services = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/services'),
      );
      expect(services['statusCode'], HttpStatus.ok);
      expect((services['json'] as Map<String, dynamic>)['roleNames'],
          contains('Local Weather'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('validation errors are preserved for moved endpoints', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'smartphone'},
      );

      final invalidPolar = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/polar'),
        jsonBody: <String, dynamic>{'deviceType': 'INVALID'},
      );
      expect(invalidPolar['statusCode'], HttpStatus.badRequest);
      expect((invalidPolar['json'] as Map<String, dynamic>)['error'],
          contains('Unsupported deviceType'));

      final invalidLocation = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/location'),
        jsonBody: <String, dynamic>{'accuracy': 'invalid_accuracy'},
      );
      expect(invalidLocation['statusCode'], HttpStatus.badRequest);
      expect((invalidLocation['json'] as Map<String, dynamic>)['error'],
          contains('Unsupported accuracy'));
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('non-task DTOs reject unknown fields and wrong JSON types', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final unknownDataEndpointField = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/data-endpoint'),
        jsonBody: <String, dynamic>{
          'endpointType': 'CAWS',
          'unexpected': true,
        },
      );
      expect(unknownDataEndpointField['statusCode'], HttpStatus.badRequest);
      expect(
        (unknownDataEndpointField['json'] as Map<String, dynamic>)['error'],
        contains('Unsupported field(s)'),
      );

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'smartphone'},
      );

      final unknownPrimaryDeviceField = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{
          'deviceType': 'smartphone',
          'unexpected': true,
        },
      );
      expect(unknownPrimaryDeviceField['statusCode'], HttpStatus.badRequest);
      expect(
        (unknownPrimaryDeviceField['json'] as Map<String, dynamic>)['error'],
        contains('Unsupported field(s)'),
      );

      final invalidSamplingRateType = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/e-sense'),
        jsonBody: <String, dynamic>{
          'roleName': 'Left Earbud',
          'samplingRate': 20.5,
        },
      );
      expect(invalidSamplingRateType['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidSamplingRateType['json'] as Map<String, dynamic>)['error'],
        contains('samplingRate'),
      );

      final invalidLocationIntervalType = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/location'),
        jsonBody: <String, dynamic>{
          'intervalSeconds': '30',
        },
      );
      expect(invalidLocationIntervalType['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidLocationIntervalType['json'] as Map<String, dynamic>)['error'],
        contains('intervalSeconds'),
      );

      final unknownLocationField = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/location'),
        jsonBody: <String, dynamic>{
          'accuracy': 'high',
          'distance': 10,
          'unknownField': 'x',
        },
      );
      expect(unknownLocationField['statusCode'], HttpStatus.badRequest);
      expect(
        (unknownLocationField['json'] as Map<String, dynamic>)['error'],
        contains('Unsupported field(s)'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /sessions/{sessionId}/tasks returns empty task list by default',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final tasks = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/tasks'),
      );

      expect(tasks['statusCode'], HttpStatus.ok);
      expect(tasks['json'], <String, dynamic>{
        'tasks': <Map<String, dynamic>>[],
      });

      final addBackgroundTask = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'daily_context_collection',
          'description': 'Collect context snapshots during the day.',
          'durationSeconds': 1800,
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );
      expect(addBackgroundTask['statusCode'], HttpStatus.ok);
      expect((addBackgroundTask['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final updatedTasks = await _requestJson(
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
            task['description'] == 'Collect context snapshots during the day.',
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final missingMeasures = await _requestJson(
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

      final emptyMeasures = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'task_with_empty_measures',
          'description': 'Invalid task',
          'measures': <Object?>[],
        },
      );
      expect(emptyMeasures['statusCode'], HttpStatus.ok);
      expect((emptyMeasures['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final blankName = await _requestJson(
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

      final blankDescription = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidDuration = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'bad_duration',
          'description': 'Invalid task',
          'durationSeconds': -1,
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{'measureType': ContextSamplingPackage.ACTIVITY},
          ],
        },
      );
      expect(invalidDuration['statusCode'], HttpStatus.badRequest);
      expect((invalidDuration['json'] as Map<String, dynamic>)['error'],
          contains('durationSeconds'));

      final invalidMeasureType = await _requestJson(
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

      final incompatibleSampling = await _requestJson(
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
                'intervalSeconds': 30,
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addWebTask = await _requestJson(
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

      expect(addWebTask['statusCode'], HttpStatus.ok);
      expect(
        (addWebTask['json'] as Map<String, dynamic>)['sessionId'],
        sessionId,
      );

      final tasks = await _requestJson(
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
            task['description'] == 'Open daily survey in browser.',
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidUrl = await _requestJson(
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

      final emptyMeasures = await _requestJson(
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
      expect(emptyMeasures['statusCode'], HttpStatus.ok);
      expect((emptyMeasures['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/tasks/app adds app task to session',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addAppTask = await _requestJson(
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
          'expireSeconds': 7200,
          'notification': true,
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      expect(addAppTask['statusCode'], HttpStatus.ok);
      expect(
        (addAppTask['json'] as Map<String, dynamic>)['sessionId'],
        sessionId,
      );

      final tasks = await _requestJson(
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
            task['description'] == 'Run a survey task in the app.',
      );
      expect(createdTaskExists, isTrue);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/tasks/app validates task type', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidType = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final response = await _requestJson(
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

      expect(response['statusCode'], HttpStatus.ok);
      expect(
          (response['json'] as Map<String, dynamic>)['sessionId'], sessionId);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/tasks/health-app adds health app task',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addHealthAppTask = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/health-app'),
        jsonBody: <String, dynamic>{
          'name': 'daily_health_assessment',
          'description': 'Collect daily health assessment in-app.',
          'title': 'Health Assessment',
          'instructions': 'Follow the health assessment steps.',
          'minutesToComplete': 5,
          'expireSeconds': 3600,
          'notification': true,
          'types': <String>['STEPS'],
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      expect(addHealthAppTask['statusCode'], HttpStatus.ok);
      expect(
        (addHealthAppTask['json'] as Map<String, dynamic>)['sessionId'],
        sessionId,
      );

      final tasks = await _requestJson(
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
            task['description'] == 'Collect daily health assessment in-app.',
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidTypes = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final response = await _requestJson(
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

      expect(response['statusCode'], HttpStatus.ok);
      expect(
          (response['json'] as Map<String, dynamic>)['sessionId'], sessionId);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /sessions/{sessionId}/tasks returns 404 for missing session',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await _requestJson(
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
      'GET /sessions/{sessionId}/triggers returns empty trigger list by default',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final triggers = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/triggers'),
      );

      expect(triggers['statusCode'], HttpStatus.ok);
      expect(triggers['json'], <String, dynamic>{
        'triggers': <Map<String, dynamic>>[],
      });
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /sessions/{sessionId}/triggers returns 404 for missing session',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await _requestJson(
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
}
