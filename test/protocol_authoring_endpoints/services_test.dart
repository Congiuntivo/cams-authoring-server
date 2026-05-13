import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('services endpoints use typed session paths', () async {
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

      final addWeather = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/weather'),
        jsonBody: <String, dynamic>{
          'roleName': 'Local Weather',
          'primaryDeviceRoleName': 'Smartphone',
        },
      );
      expect(addWeather['statusCode'], HttpStatus.created);

      final addLocation = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/services/location'),
        jsonBody: <String, dynamic>{
          'roleName': 'User Location',
          'primaryDeviceRoleName': 'Smartphone',
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
      expect(addLocation['statusCode'], HttpStatus.created);

      final services = await requestJson(
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
}
