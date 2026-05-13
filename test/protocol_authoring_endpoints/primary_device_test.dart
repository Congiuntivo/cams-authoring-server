import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('primary device endpoints support smartphone and web-browser routes',
      () async {
    final server = await startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final smartphoneCreated = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final smartphoneSessionId = (smartphoneCreated['json']
          as Map<String, dynamic>)['sessionId'] as String;

      final addSmartphonePrimary = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
            '/sessions/$smartphoneSessionId/primary-devices/smartphone'),
        jsonBody: <String, dynamic>{
          'roleName': 'User Phone',
        },
      );
      expect(addSmartphonePrimary['statusCode'], HttpStatus.created);

      final getSmartphonePrimary = await requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$smartphoneSessionId/primary-devices'),
      );
      expect(getSmartphonePrimary['statusCode'], HttpStatus.ok);
      final primaryDevices = (getSmartphonePrimary['json']
          as Map<String, dynamic>)['primaryDevices'] as List<dynamic>;
      final primaryDevice = primaryDevices.first as Map<String, dynamic>;
      expect(primaryDevice['name'], 'User Phone');
      expect(
        (primaryDevice['device'] as Map<String, dynamic>)['roleName'],
        'User Phone',
      );

      final browserCreated = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      final browserSessionId = (browserCreated['json']
          as Map<String, dynamic>)['sessionId'] as String;

      final addBrowserPrimary = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri
            .resolve('/sessions/$browserSessionId/primary-devices/web-browser'),
        jsonBody: <String, dynamic>{},
      );
      expect(addBrowserPrimary['statusCode'], HttpStatus.created);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test(
      'participant role and expected-data endpoints work on session-scoped paths',
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
        uri: baseUri.resolve('/sessions/$sessionId/data-endpoint'),
        jsonBody: <String, dynamic>{'endpointType': 'CAWS'},
      );

      await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-devices/smartphone'),
        jsonBody: <String, dynamic>{},
      );

      final addRole = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/participant-roles'),
        jsonBody: <String, dynamic>{'roleName': 'Patient'},
      );
      expect(addRole['statusCode'], HttpStatus.created);

      final addExpectedRoleData = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/sessions/$sessionId/participant-roles/expected-data',
        ),
        jsonBody: <String, dynamic>{
          'roleName': 'Patient',
          'dataType': 'sex',
        },
      );
      expect(addExpectedRoleData['statusCode'], HttpStatus.created);

      final addExpectedAllData = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/expected-data'),
        jsonBody: <String, dynamic>{'dataType': 'address'},
      );
      expect(addExpectedAllData['statusCode'], HttpStatus.created);

      final roles = await requestJson(
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
}
