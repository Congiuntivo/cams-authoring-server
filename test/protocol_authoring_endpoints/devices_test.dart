import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('device endpoints use typed session paths with JSON body', () async {
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
        jsonBody: <String, dynamic>{},
      );

      final addESense = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/e-sense'),
        jsonBody: <String, dynamic>{
          'roleName': 'Left Earbud',
          'primaryDeviceRoleName': 'Smartphone',
          'samplingRate': 20,
        },
      );
      expect(addESense['statusCode'], HttpStatus.created);

      final addPolar = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/devices/polar'),
        jsonBody: <String, dynamic>{
          'roleName': 'Polar Chest Sensor',
          'primaryDeviceRoleName': 'Smartphone',
          'isOptional': false,
          'namePrefix': 'Polar',
        },
      );
      expect(addPolar['statusCode'], HttpStatus.created);

      final devices = await requestJson(
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
}
