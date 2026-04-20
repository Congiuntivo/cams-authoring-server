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
  Map<String, dynamic>? effectiveJsonBody = jsonBody;
  if (effectiveJsonBody == null && method.toUpperCase() == 'POST') {
    if (uri.path == '/protocol/new') {
      effectiveJsonBody = <String, dynamic>{
        'name': 'Unnamed Protocol',
      };
    }
  }

  final request = await client.openUrl(method, uri);
  if (effectiveJsonBody != null) {
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(effectiveJsonBody));
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
      'POST /protocol/new creates session used by session-scoped requirements and serialize',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final newProtocol = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
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
        uri: baseUri.resolve('/protocol/new'),
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
        uri: baseUri.resolve('/protocol/new'),
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
      final primaryDevice = ((getSmartphonePrimary['json']
          as Map<String, dynamic>)['primaryDevice'] as Map<String, dynamic>);
      expect(primaryDevice['name'], 'User Phone');
      expect(
        (primaryDevice['device'] as Map<String, dynamic>)['roleName'],
        'User Phone',
      );

      final browserCreated = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final browserSessionId = (browserCreated['json']
          as Map<String, dynamic>)['sessionId'] as String;

      final addBrowserPrimary = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$browserSessionId/primary-device'),
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
        uri: baseUri.resolve('/protocol/new'),
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
        uri: baseUri.resolve('/protocol/new'),
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
          'isOptional': false,
          'namePrefix': 'Polar',
        },
      );
      expect(addPolar['statusCode'], HttpStatus.ok);

      final devices = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/devices'),
      );
      expect(devices['statusCode'], HttpStatus.ok);
      final deviceSummaries = ((devices['json']
          as Map<String, dynamic>)['devices'] as List<dynamic>);
      final hasLeftEarbud = deviceSummaries.any(
        (summary) =>
            summary is Map<String, dynamic> && summary['name'] == 'Left Earbud',
      );
      expect(hasLeftEarbud, isTrue);
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
        uri: baseUri.resolve('/protocol/new'),
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
          'interval': <String, dynamic>{'seconds': 30},
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
      final serviceSummaries = ((services['json']
          as Map<String, dynamic>)['services'] as List<dynamic>);
      final hasLocalWeather = serviceSummaries.any(
        (summary) =>
            summary is Map<String, dynamic> &&
            summary['name'] == 'Local Weather',
      );
      expect(hasLocalWeather, isTrue);
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
        uri: baseUri.resolve('/protocol/new'),
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
          contains('Unsupported field(s)'));

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
        uri: baseUri.resolve('/protocol/new'),
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

      final removedMovesenseField = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/movesense'),
        jsonBody: <String, dynamic>{
          'roleName': 'Chest Sensor',
          'name': 'legacy-movesense-name',
        },
      );
      expect(removedMovesenseField['statusCode'], HttpStatus.badRequest);
      expect(
        (removedMovesenseField['json'] as Map<String, dynamic>)['error'],
        contains('Unsupported field(s)'),
      );

      final removedMovisensField = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/movisens'),
        jsonBody: <String, dynamic>{
          'roleName': 'Torso Sensor',
          'deviceName': 'LEGACY_NAME',
        },
      );
      expect(removedMovisensField['statusCode'], HttpStatus.badRequest);
      expect(
        (removedMovisensField['json'] as Map<String, dynamic>)['error'],
        contains('Unsupported field(s)'),
      );

      final invalidLocationIntervalType = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/location'),
        jsonBody: <String, dynamic>{
          'interval': '30',
        },
      );
      expect(invalidLocationIntervalType['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidLocationIntervalType['json'] as Map<String, dynamic>)['error'],
        contains('interval'),
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
        uri: baseUri.resolve('/protocol/new'),
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
          'duration': <String, dynamic>{'minutes': 30},
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
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
        uri: baseUri.resolve('/protocol/new'),
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
          'duration': <String, dynamic>{'seconds': -1},
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{'measureType': ContextSamplingPackage.ACTIVITY},
          ],
        },
      );
      expect(invalidDuration['statusCode'], HttpStatus.badRequest);
      expect((invalidDuration['json'] as Map<String, dynamic>)['error'],
          contains('duration'));

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
        uri: baseUri.resolve('/protocol/new'),
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
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
        uri: baseUri.resolve('/protocol/new'),
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
          'expire': <String, dynamic>{'hours': 2},
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
            task['serializedObj'] is Map<String, dynamic>,
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
        uri: baseUri.resolve('/protocol/new'),
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
        uri: baseUri.resolve('/protocol/new'),
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
        uri: baseUri.resolve('/protocol/new'),
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
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
        uri: baseUri.resolve('/protocol/new'),
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
      'task control endpoints add and return task controls on session-scoped paths',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{
          'deviceType': 'smartphone',
          'roleName': 'User Phone',
        },
      );

      const taskName = 'daily_context_collection';
      const triggerName = 'start_now';
      final expectedWarning =
          'Task "$taskName" must be used by at least one task control.';
      final triggerWarning =
          'Trigger "$triggerName" must be used by at least one task control.';

      final addTask = await _requestJson(
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

      expect(addTask['statusCode'], HttpStatus.ok);
      expect(
        ((addTask['json'] as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'],
        contains(expectedWarning),
      );

      final addTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': triggerName,
        },
      );

      expect(addTrigger['statusCode'], HttpStatus.ok);
      expect(
        (((addTrigger['json']
                as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        contains(triggerWarning),
      );

      final addTaskControl = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
        jsonBody: <String, dynamic>{
          'taskName': taskName,
          'triggerName': triggerName,
          'deviceRoleName': 'User Phone',
        },
      );

      expect(addTaskControl['statusCode'], HttpStatus.ok);
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

      final taskControls = await _requestJson(
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

  test('POST /sessions/{sessionId}/task-controls preserves validation errors',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{
          'deviceType': 'smartphone',
          'roleName': 'User Phone',
        },
      );

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': 'start_now',
        },
      );

      final invalidTaskControl = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
        jsonBody: <String, dynamic>{
          'taskName': 'missing_task',
          'triggerName': 'start_now',
          'deviceRoleName': 'User Phone',
        },
      );

      expect(invalidTaskControl['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidTaskControl['json'] as Map<String, dynamic>)['error'],
        contains('Task "missing_task" is not defined in task configurations'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /sessions/{sessionId}/task-controls validates device role name',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{
          'deviceType': 'smartphone',
          'roleName': 'User Phone',
        },
      );

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/tasks/background'),
        jsonBody: <String, dynamic>{
          'name': 'daily_context_collection',
          'description': 'Collect context snapshots during the day.',
          'measures': <Map<String, dynamic>>[
            <String, dynamic>{
              'measureType': ContextSamplingPackage.ACTIVITY,
            },
          ],
        },
      );

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': 'start_now',
        },
      );

      final invalidTaskControl = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
        jsonBody: <String, dynamic>{
          'taskName': 'daily_context_collection',
          'triggerName': 'start_now',
          'deviceRoleName': 'Missing Device',
        },
      );

      expect(invalidTaskControl['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidTaskControl['json'] as Map<String, dynamic>)['error'],
        contains('Device role "Missing Device" is not defined'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'device usage warning is added on device endpoint and removed by task control binding',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{
          'deviceType': 'smartphone',
          'roleName': 'User Phone',
        },
      );

      const taskName = 'daily_context_collection';
      const triggerName = 'start_now';
      const deviceRoleName = 'Left Earbud';
      final deviceWarning =
          'Device "$deviceRoleName" must be used by at least one task control.';

      await _requestJson(
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

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': triggerName,
        },
      );

      final addDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/e-sense'),
        jsonBody: <String, dynamic>{
          'roleName': deviceRoleName,
          'samplingRate': 20,
        },
      );
      expect(addDevice['statusCode'], HttpStatus.ok);
      expect(
        (((addDevice['json'] as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        contains(deviceWarning),
      );

      final addTaskControl = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
        jsonBody: <String, dynamic>{
          'taskName': taskName,
          'triggerName': triggerName,
          'deviceRoleName': deviceRoleName,
        },
      );
      expect(addTaskControl['statusCode'], HttpStatus.ok);
      expect(
        (((addTaskControl['json']
                as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        isNot(contains(deviceWarning)),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'service usage warning is added on service endpoint and removed by task control binding',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{
          'deviceType': 'smartphone',
          'roleName': 'User Phone',
        },
      );

      const taskName = 'daily_context_collection';
      const triggerName = 'start_now';
      const serviceRoleName = 'Local Weather';
      final serviceWarning =
          'Service "$serviceRoleName" must be used by at least one task control.';

      await _requestJson(
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

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': triggerName,
        },
      );

      final addService = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/sessions/$sessionId/services/weather?roleName=Local%20Weather',
        ),
      );
      expect(addService['statusCode'], HttpStatus.ok);
      expect(
        (((addService['json']
                as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        contains(serviceWarning),
      );

      final addTaskControl = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
        jsonBody: <String, dynamic>{
          'taskName': taskName,
          'triggerName': triggerName,
          'deviceRoleName': serviceRoleName,
        },
      );
      expect(addTaskControl['statusCode'], HttpStatus.ok);
      expect(
        (((addTaskControl['json']
                as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        isNot(contains(serviceWarning)),
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
        uri: baseUri.resolve('/protocol/new'),
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

  test(
      'POST /sessions/{sessionId}/triggers/cron adds cron trigger and is visible in trigger list',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addCronTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/cron'),
        jsonBody: <String, dynamic>{
          'triggerName': 'daily_evening_prompt',
          'minute': 30,
          'hour': 19,
        },
      );

      expect(addCronTrigger['statusCode'], HttpStatus.ok);
      expect((addCronTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidMinute = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addDateTimeTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/date-time'),
        jsonBody: <String, dynamic>{
          'triggerName': 'enrollment_follow_up',
          'schedule': '2026-10-01T09:30:00Z',
        },
      );

      expect(addDateTimeTrigger['statusCode'], HttpStatus.ok);
      expect((addDateTimeTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidSchedule = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addDelayedTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/delayed'),
        jsonBody: <String, dynamic>{
          'triggerName': 'delayed_prompt',
          'delay': <String, dynamic>{'minutes': 15},
        },
      );

      expect(addDelayedTrigger['statusCode'], HttpStatus.ok);
      expect((addDelayedTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidDelay = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addElapsedTimeTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/elapsed-time'),
        jsonBody: <String, dynamic>{
          'triggerName': 'elapsed_30_minutes',
          'elapsedTime': <String, dynamic>{'minutes': 30},
        },
      );

      expect(addElapsedTimeTrigger['statusCode'], HttpStatus.ok);
      expect(
          (addElapsedTimeTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidElapsedTime = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addImmediateTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': 'start_now',
        },
      );

      expect(addImmediateTrigger['statusCode'], HttpStatus.ok);
      expect((addImmediateTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidImmediate = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addManualTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/manual'),
        jsonBody: <String, dynamic>{
          'triggerName': 'manual_daily_prompt',
          'label': 'Daily prompt',
          'description': 'Shown manually by the participant.',
        },
      );

      expect(addManualTrigger['statusCode'], HttpStatus.ok);
      expect((addManualTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidManual = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addNoOpTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/no-op'),
        jsonBody: <String, dynamic>{
          'triggerName': 'always_on',
        },
      );

      expect(addNoOpTrigger['statusCode'], HttpStatus.ok);
      expect((addNoOpTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidNoOp = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addNoUserTaskTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/no-user-task'),
        jsonBody: <String, dynamic>{
          'triggerName': 'ensure_survey_task',
          'taskName': 'daily_survey',
        },
      );

      expect(addNoUserTaskTrigger['statusCode'], HttpStatus.ok);
      expect(
          (addNoUserTaskTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidNoUserTask = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addOneTimeTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/one-time'),
        jsonBody: <String, dynamic>{
          'triggerName': 'show_demographics_once',
        },
      );

      expect(addOneTimeTrigger['statusCode'], HttpStatus.ok);
      expect((addOneTimeTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidOneTime = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addPassiveTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/passive'),
        jsonBody: <String, dynamic>{
          'triggerName': 'manual_code_trigger',
        },
      );

      expect(addPassiveTrigger['statusCode'], HttpStatus.ok);
      expect((addPassiveTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidPassive = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addPeriodicTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/periodic'),
        jsonBody: <String, dynamic>{
          'triggerName': 'periodic_prompt',
          'period': <String, dynamic>{'minutes': 20},
        },
      );

      expect(addPeriodicTrigger['statusCode'], HttpStatus.ok);
      expect((addPeriodicTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidPeriodic = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addRandomRecurrentTrigger = await _requestJson(
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

      expect(addRandomRecurrentTrigger['statusCode'], HttpStatus.ok);
      expect(
          (addRandomRecurrentTrigger['json']
              as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidRandomRecurrent = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addRecurrentScheduledTrigger = await _requestJson(
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

      expect(addRecurrentScheduledTrigger['statusCode'], HttpStatus.ok);
      expect(
          (addRecurrentScheduledTrigger['json']
              as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidRecurrentScheduled = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addScheduledTrigger = await _requestJson(
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

      expect(addScheduledTrigger['statusCode'], HttpStatus.ok);
      expect((addScheduledTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidScheduled = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addUserTaskTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/user-task'),
        jsonBody: <String, dynamic>{
          'triggerName': 'survey_completion_trigger',
          'taskName': 'daily_survey',
          'triggerCondition': 'done',
        },
      );

      expect(addUserTaskTrigger['statusCode'], HttpStatus.ok);
      expect((addUserTaskTrigger['json'] as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidUserTaskTrigger = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addSamplingEventTrigger = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/sampling-event'),
        jsonBody: <String, dynamic>{
          'triggerName': 'after_completed_task',
          'measureType': 'dk.cachet.carp.completed_task',
        },
      );

      expect(addSamplingEventTrigger['statusCode'], HttpStatus.ok);
      expect(
          (addSamplingEventTrigger['json']
              as Map<String, dynamic>)['sessionId'],
          sessionId);

      final triggers = await _requestJson(
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
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final invalidSamplingEventTrigger = await _requestJson(
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
