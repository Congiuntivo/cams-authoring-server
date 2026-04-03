import 'dart:convert';
import 'dart:io';

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
}) async {
  final request = await client.openUrl(method, uri);
  final response = await request.close();
  final body = await utf8.decoder.bind(response).join();
  return <String, dynamic>{
    'statusCode': response.statusCode,
    'json': jsonDecode(body) as Map<String, dynamic>,
  };
}

void main() {
  test(
      'POST /protocol/new/smartphone creates session used by /requirements and /serialize',
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
      final createdJson = newProtocol['json'] as Map<String, dynamic>;
      expect(createdJson.containsKey('sessionId'), isTrue);

      final sessionId = createdJson['sessionId'] as String;
      expect(sessionId.isNotEmpty, isTrue);

      final requirements = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/requirements?sessionId=$sessionId'),
      );
      expect(requirements['statusCode'], HttpStatus.ok);
      expect(requirements['json'], <String, dynamic>{
        'unfulfilledRequirements': {
          'warnings': <String>[
            'A data end point must be configured.',
            'At least one participant role must be configured.'
          ],
          'critical': <String>['A primary device must be configured.'],
        }
      });

      final addEndPoint = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/data-endpoint?sessionId=$sessionId&endpointType=CAWS&uploadMethod=stream&name=CARP%20Web%20Services&deleteWhenUploaded=true',
        ),
      );
      expect(addEndPoint['statusCode'], HttpStatus.ok);
      expect(addEndPoint['json'], <String, dynamic>{
        'sessionId': sessionId,
        'unfulfilledRequirements': {
          'warnings': <String>[
            'At least one participant role must be configured.'
          ],
          'critical': <String>['A primary device must be configured.'],
        }
      });

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId&roleName=User%20Phone',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);
      expect(addPrimaryDevice['json'], <String, dynamic>{
        'sessionId': sessionId,
        'unfulfilledRequirements': {
          'warnings': <String>[
            'At least one participant role must be configured.'
          ],
          'critical': <String>[],
        }
      });

      final getPrimaryDevice = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/protocol/primary-device?sessionId=$sessionId'),
      );
      expect(getPrimaryDevice['statusCode'], HttpStatus.ok);
      expect(getPrimaryDevice['json'], <String, dynamic>{
        'roleName': 'User Phone',
      });

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize?sessionId=$sessionId'),
      );
      expect(serialized['statusCode'], HttpStatus.ok);
      final protocol = (serialized['json'] as Map<String, dynamic>)['protocol']
          as Map<String, dynamic>;
      expect(protocol['name'], 'Unnamed Protocol');
      expect(protocol['ownerId'], isA<String>());
      expect(protocol['version'], 0);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /protocol/new/smartphone then GET /serialize returns created protocol',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      const expectedName = 'My Study Protocol';
      const expectedOwnerId = '979b408d-784e-4b1b-bb1e-ff9204e072f3';

      final newProtocol = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/new/smartphone?name=$expectedName&ownerId=$expectedOwnerId',
        ),
      );

      expect(newProtocol['statusCode'], HttpStatus.created);
      final createdJson = newProtocol['json'] as Map<String, dynamic>;
      final sessionId = createdJson['sessionId'] as String;
      expect(sessionId.isNotEmpty, isTrue);

      final addEndPoint = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/data-endpoint?sessionId=$sessionId&endpointType=CAWS&uploadMethod=stream&name=CARP%20Web%20Services&deleteWhenUploaded=false',
        ),
      );
      expect(addEndPoint['statusCode'], HttpStatus.ok);
      expect(addEndPoint['json'], <String, dynamic>{
        'sessionId': sessionId,
        'unfulfilledRequirements': {
          'warnings': <String>[
            'At least one participant role must be configured.'
          ],
          'critical': <String>['A primary device must be configured.'],
        }
      });

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);
      expect(addPrimaryDevice['json'], <String, dynamic>{
        'sessionId': sessionId,
        'unfulfilledRequirements': {
          'warnings': <String>[
            'At least one participant role must be configured.'
          ],
          'critical': <String>[],
        }
      });

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize?sessionId=$sessionId'),
      );

      expect(serialized['statusCode'], HttpStatus.ok);
      final protocol = (serialized['json'] as Map<String, dynamic>)['protocol']
          as Map<String, dynamic>;
      expect(protocol['name'], expectedName);
      expect(protocol['ownerId'], expectedOwnerId);
      expect(protocol['version'], 0);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /protocol/new/default then GET /serialize returns created default protocol',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      const expectedName = 'Default Study Protocol';
      const expectedOwnerId = '979b408d-784e-4b1b-bb1e-ff9204e072f3';

      final newProtocol = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/new/default?name=$expectedName&ownerId=$expectedOwnerId',
        ),
      );

      expect(newProtocol['statusCode'], HttpStatus.created);
      final createdJson = newProtocol['json'] as Map<String, dynamic>;
      final sessionId = createdJson['sessionId'] as String;
      expect(sessionId.isNotEmpty, isTrue);

      final requirements = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/requirements?sessionId=$sessionId'),
      );
      expect(requirements['statusCode'], HttpStatus.ok);
      expect(requirements['json'], <String, dynamic>{
        'unfulfilledRequirements': {
          'warnings': <String>[
            'At least one participant role must be configured.'
          ],
          'critical': <String>['A primary device must be configured.'],
        }
      });

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/browser?sessionId=$sessionId',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize?sessionId=$sessionId'),
      );

      expect(serialized['statusCode'], HttpStatus.ok);
      final serializedJson = serialized['json'] as Map<String, dynamic>;
      final protocol = serializedJson['protocol'] as Map<String, dynamic>;
      expect(protocol['name'], expectedName);
      expect(protocol['ownerId'], expectedOwnerId);
      expect(protocol['description'], 'study.description.description');
      expect(serializedJson['warnings'],
          <String>['At least one participant role must be configured.']);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /protocol/data-endpoint returns 400 without session id', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/data-endpoint'),
      );

      expect(response['statusCode'], HttpStatus.badRequest);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        contains('Missing session id'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /requirements returns 400 when session id is missing', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/requirements'),
      );

      expect(response['statusCode'], HttpStatus.badRequest);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        contains('Missing session id'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /serialize returns 404 when session does not exist', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize?sessionId=does-not-exist'),
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

  test('GET /protocol/primary-device returns 400 when no primary device exists',
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
        method: 'GET',
        uri: baseUri.resolve('/protocol/primary-device?sessionId=$sessionId'),
      );

      expect(response['statusCode'], HttpStatus.badRequest);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        contains('No primary device configured'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /protocol/primary-device/browser returns 400 for smartphone protocol',
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
        uri: baseUri
            .resolve('/protocol/primary-device/browser?sessionId=$sessionId'),
      );

      expect(response['statusCode'], HttpStatus.badRequest);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        contains('Browser primary device can only be added to default'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /protocol/primary-device/smartphone returns 400 for default protocol',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/default'),
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final response = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );

      expect(response['statusCode'], HttpStatus.badRequest);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        contains('Smartphone primary device can only be added'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /protocol/participant-role and /participant-expected-data/role work for specific role',
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

      final addDataEndpoint = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/data-endpoint?sessionId=$sessionId&endpointType=CAWS&uploadMethod=stream&name=CARP%20Web%20Services',
        ),
      );
      expect(addDataEndpoint['statusCode'], HttpStatus.ok);

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);

      final addRole = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/participant-role?sessionId=$sessionId&roleName=Patient&isOptional=false',
        ),
      );
      expect(addRole['statusCode'], HttpStatus.ok);

      final getParticipantRoles = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/protocol/participant-role?sessionId=$sessionId'),
      );
      expect(getParticipantRoles['statusCode'], HttpStatus.ok);
      expect(getParticipantRoles['json'], <String, dynamic>{
        'roleNames': <String>['Patient'],
      });

      final addExpectedRoleData = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/participant-expected-data/role?sessionId=$sessionId&roleName=Patient&dataType=sex',
        ),
      );
      expect(addExpectedRoleData['statusCode'], HttpStatus.ok);

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize?sessionId=$sessionId'),
      );
      expect(serialized['statusCode'], HttpStatus.ok);
      final protocol = (serialized['json'] as Map<String, dynamic>)['protocol']
          as Map<String, dynamic>;
      expect(
          (protocol['participantRoles'] as List<dynamic>).isNotEmpty, isTrue);
      expect((protocol['expectedParticipantData'] as List<dynamic>).isNotEmpty,
          isTrue);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'POST /protocol/participant-role and /participant-expected-data/all work for all roles',
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
        uri: baseUri.resolve(
          '/protocol/data-endpoint?sessionId=$sessionId&endpointType=CAWS&uploadMethod=stream&name=CARP%20Web%20Services',
        ),
      );
      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );

      final addRole = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/participant-role?sessionId=$sessionId&roleName=Caregiver',
        ),
      );
      expect(addRole['statusCode'], HttpStatus.ok);

      final addExpectedAllData = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/participant-expected-data/all?sessionId=$sessionId&dataType=informed_consent',
        ),
      );
      expect(addExpectedAllData['statusCode'], HttpStatus.ok);

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize?sessionId=$sessionId'),
      );
      expect(serialized['statusCode'], HttpStatus.ok);
      final protocol = (serialized['json'] as Map<String, dynamic>)['protocol']
          as Map<String, dynamic>;
      expect(
          (protocol['participantRoles'] as List<dynamic>).isNotEmpty, isTrue);
      expect((protocol['expectedParticipantData'] as List<dynamic>).isNotEmpty,
          isTrue);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /protocol/participant-role returns empty list when no roles exist',
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
        method: 'GET',
        uri: baseUri.resolve('/protocol/participant-role?sessionId=$sessionId'),
      );

      expect(response['statusCode'], HttpStatus.ok);
      expect(response['json'], <String, dynamic>{
        'roleNames': <String>[],
      });
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /protocol/services returns empty list when no services exist',
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
        method: 'GET',
        uri: baseUri.resolve('/protocol/services?sessionId=$sessionId'),
      );

      expect(response['statusCode'], HttpStatus.ok);
      expect(response['json'], <String, dynamic>{
        'roleNames': <String>[],
      });
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /protocol/devices returns empty list when no devices exist',
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
        method: 'GET',
        uri: baseUri.resolve('/protocol/devices?sessionId=$sessionId'),
      );

      expect(response['statusCode'], HttpStatus.ok);
      expect(response['json'], <String, dynamic>{
        'roleNames': <String>[],
      });
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /protocol/services/weather returns 400 without primary device',
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
        uri: baseUri.resolve(
          '/protocol/services/weather?sessionId=$sessionId&roleName=Local%20Weather',
        ),
      );

      expect(response['statusCode'], HttpStatus.badRequest);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        contains('Primary device configuration must be set'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST services endpoints add weather and air quality roles', () async {
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

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);

      final addWeather = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/services/weather?sessionId=$sessionId&roleName=Local%20Weather',
        ),
      );
      expect(addWeather['statusCode'], HttpStatus.ok);

      final addAirQuality = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/services/air-quality?sessionId=$sessionId&roleName=Local%20Air%20Quality',
        ),
      );
      expect(addAirQuality['statusCode'], HttpStatus.ok);

      final services = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/protocol/services?sessionId=$sessionId'),
      );
      expect(services['statusCode'], HttpStatus.ok);
      expect(services['json'], <String, dynamic>{
        'roleNames': <String>['Local Weather', 'Local Air Quality'],
      });
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /protocol/services/location adds location role', () async {
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

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);

      final addLocation = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/services/location?sessionId=$sessionId&roleName=User%20Location&accuracy=high&distance=25&intervalSeconds=30&notificationTitle=Tracking%20active&notificationMessage=Location%20tracking%20is%20running.&notificationDescription=Tap%20to%20return%20to%20the%20app.&notificationIconName=ic_notification&notificationOnTapBringToFront=true',
        ),
      );
      expect(addLocation['statusCode'], HttpStatus.ok);

      final services = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/protocol/services?sessionId=$sessionId'),
      );
      expect(services['statusCode'], HttpStatus.ok);
      expect(services['json'], <String, dynamic>{
        'roleNames': <String>['User Location'],
      });
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /protocol/services/location returns 400 for invalid accuracy',
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

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);

      final response = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/services/location?sessionId=$sessionId&accuracy=invalid_accuracy',
        ),
      );

      expect(response['statusCode'], HttpStatus.badRequest);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        contains('Unsupported accuracy'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /protocol/services/health adds health role', () async {
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

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);

      final addHealth = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/services/health?sessionId=$sessionId&roleName=Device%20Health',
        ),
      );
      expect(addHealth['statusCode'], HttpStatus.ok);

      final services = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/protocol/services?sessionId=$sessionId'),
      );
      expect(services['statusCode'], HttpStatus.ok);
      expect(services['json'], <String, dynamic>{
        'roleNames': <String>['Device Health'],
      });
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /protocol/services/weather returns 400 when role name is taken',
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

      final addPrimaryDevice = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/primary-device/smartphone?sessionId=$sessionId',
        ),
      );
      expect(addPrimaryDevice['statusCode'], HttpStatus.ok);

      final addWeather = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/services/weather?sessionId=$sessionId&roleName=Local%20Weather',
        ),
      );
      expect(addWeather['statusCode'], HttpStatus.ok);

      final duplicateWeather = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/protocol/services/weather?sessionId=$sessionId&roleName=Local%20Weather',
        ),
      );
      expect(duplicateWeather['statusCode'], HttpStatus.badRequest);
      expect(
        (duplicateWeather['json'] as Map<String, dynamic>)['error'],
        contains('Service role name already taken'),
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });
}
