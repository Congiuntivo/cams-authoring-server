import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('addParticipantRole returns 400 when roleName is absent from body',
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

      final result = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/participant-roles'),
        jsonBody: <String, dynamic>{},
      );
      expect(result['statusCode'], HttpStatus.badRequest);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('addExpectedParticipantDataForRole returns 400 for unsupported dataType',
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
        uri: baseUri.resolve('/sessions/$sessionId/participant-roles'),
        jsonBody: <String, dynamic>{'roleName': 'Patient'},
      );

      final result = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve(
          '/sessions/$sessionId/participant-roles/expected-data',
        ),
        jsonBody: <String, dynamic>{
          'roleName': 'Patient',
          'dataType': 'unsupported_type',
        },
      );
      expect(result['statusCode'], HttpStatus.badRequest);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('addExpectedParticipantDataForAllRoles accepts dataType from JSON body',
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
        uri: baseUri.resolve('/sessions/$sessionId/participant-roles'),
        jsonBody: <String, dynamic>{'roleName': 'Patient'},
      );

      final result = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/expected-data'),
        jsonBody: <String, dynamic>{'dataType': 'informed_consent'},
      );
      expect(result['statusCode'], HttpStatus.ok);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('addExpectedParticipantDataForRole returns 400 when roleName is absent',
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

      final result = await requestJson(
        client: client,
        method: 'POST',
        uri: baseUri
            .resolve('/sessions/$sessionId/participant-roles/expected-data'),
        jsonBody: <String, dynamic>{'dataType': 'sex'},
      );
      expect(result['statusCode'], HttpStatus.badRequest);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });
}
