import 'dart:io';

import 'package:carp_context_package/carp_context_package.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('POST /sessions/{sessionId}/task-controls preserves validation errors',
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

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-devices/smartphone'),
        jsonBody: <String, dynamic>{
          'roleName': 'User Phone',
        },
      );

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': 'start_now',
        },
      );

      final invalidTaskControl = await requestJson(
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

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-devices/smartphone'),
        jsonBody: <String, dynamic>{
          'roleName': 'User Phone',
        },
      );

      await requestJson(
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

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': 'start_now',
        },
      );

      final invalidTaskControl = await requestJson(
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
      const deviceRoleName = 'Left Earbud';
      final deviceWarning =
          'Device "$deviceRoleName" must be used by at least one task control.';

      await requestJson(
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

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': triggerName,
        },
      );

      final addDevice = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/e-sense'),
        jsonBody: <String, dynamic>{
          'roleName': deviceRoleName,
          'primaryDeviceRoleName': 'User Phone',
          'samplingRate': 20,
        },
      );
      expect(addDevice['statusCode'], HttpStatus.created);
      expect(
        (((addDevice['json'] as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        contains(deviceWarning),
      );

      final addTaskControl = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
        jsonBody: <String, dynamic>{
          'taskName': taskName,
          'triggerName': triggerName,
          'deviceRoleName': deviceRoleName,
        },
      );
      expect(addTaskControl['statusCode'], HttpStatus.created);
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
      const serviceRoleName = 'Local Weather';
      final serviceWarning =
          'Service "$serviceRoleName" must be used by at least one task control.';

      await requestJson(
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

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/triggers/immediate'),
        jsonBody: <String, dynamic>{
          'triggerName': triggerName,
        },
      );

      final addService = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/weather'),
        jsonBody: <String, dynamic>{
          'roleName': 'Local Weather',
          'primaryDeviceRoleName': 'User Phone',
        },
      );
      expect(addService['statusCode'], HttpStatus.created);
      expect(
        (((addService['json']
                as Map<String, dynamic>)['unfulfilledRequirements']
            as Map<String, dynamic>)['warnings'] as List<dynamic>),
        contains(serviceWarning),
      );

      final addTaskControl = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/task-controls'),
        jsonBody: <String, dynamic>{
          'taskName': taskName,
          'triggerName': triggerName,
          'deviceRoleName': serviceRoleName,
        },
      );
      expect(addTaskControl['statusCode'], HttpStatus.created);
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

      final triggers = await requestJson(
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
}
