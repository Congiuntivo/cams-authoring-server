import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('validation errors are preserved for moved endpoints', () async {
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
        jsonBody: <String, dynamic>{},
      );

      final invalidPolar = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/polar'),
        jsonBody: <String, dynamic>{'deviceType': 'INVALID'},
      );
      expect(invalidPolar['statusCode'], HttpStatus.badRequest);
      expect((invalidPolar['json'] as Map<String, dynamic>)['error'],
          contains('Unsupported field(s)'));

      final invalidLocation = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/location'),
        jsonBody: <String, dynamic>{
          'primaryDeviceRoleName': 'Smartphone',
          'accuracy': 'invalid_accuracy',
        },
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

      final unknownDataEndpointField = await requestJson(
        client: client,
        method: 'PUT',
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

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-devices/smartphone'),
        jsonBody: <String, dynamic>{},
      );

      final unknownPrimaryDeviceField = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-devices/smartphone'),
        jsonBody: <String, dynamic>{
          'roleName': 'User Phone',
          'unexpected': true,
        },
      );
      expect(unknownPrimaryDeviceField['statusCode'], HttpStatus.badRequest);
      expect(
        (unknownPrimaryDeviceField['json'] as Map<String, dynamic>)['error'],
        contains('Unsupported field(s)'),
      );

      final invalidSamplingRateType = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/e-sense'),
        jsonBody: <String, dynamic>{
          'roleName': 'Left Earbud',
          'primaryDeviceRoleName': 'Smartphone',
          'samplingRate': 20.5,
        },
      );
      expect(invalidSamplingRateType['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidSamplingRateType['json'] as Map<String, dynamic>)['error'],
        contains('samplingRate'),
      );

      final removedMovesenseField = await requestJson(
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

      final removedMovisensField = await requestJson(
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

      final invalidLocationIntervalType = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/location'),
        jsonBody: <String, dynamic>{
          'primaryDeviceRoleName': 'Smartphone',
          'interval': '30',
        },
      );
      expect(invalidLocationIntervalType['statusCode'], HttpStatus.badRequest);
      expect(
        (invalidLocationIntervalType['json'] as Map<String, dynamic>)['error'],
        contains('interval'),
      );

      final unknownLocationField = await requestJson(
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
}
