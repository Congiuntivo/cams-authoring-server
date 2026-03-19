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
  test('POST /protocol/new creates session used by /state and /serialize',
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
      final createdJson = newProtocol['json'] as Map<String, dynamic>;
      expect(createdJson.containsKey('sessionId'), isTrue);

      final sessionId = createdJson['sessionId'] as String;
      expect(sessionId.isNotEmpty, isTrue);

      final state = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/state?sessionId=$sessionId'),
      );
      expect(state['statusCode'], HttpStatus.ok);
      expect(state['json'], <String, dynamic>{'state': 'protocolStarted'});

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize?sessionId=$sessionId'),
      );
      expect(serialized['statusCode'], HttpStatus.ok);

      final serializedJson = serialized['json'] as Map<String, dynamic>;
      expect(serializedJson['name'], 'Unnamed Protocol');
      expect(serializedJson['ownerId'], isA<String>());
      expect(serializedJson['version'], 0);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /protocol/new then GET /serialize returns created protocol',
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
          '/protocol/new?name=$expectedName&ownerId=$expectedOwnerId',
        ),
      );

      expect(newProtocol['statusCode'], HttpStatus.created);
      final createdJson = newProtocol['json'] as Map<String, dynamic>;
      final sessionId = createdJson['sessionId'] as String;
      expect(sessionId.isNotEmpty, isTrue);

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize?sessionId=$sessionId'),
      );

      expect(serialized['statusCode'], HttpStatus.ok);
      final serializedJson = serialized['json'] as Map<String, dynamic>;
      expect(serializedJson['name'], expectedName);
      expect(serializedJson['ownerId'], expectedOwnerId);
      expect(serializedJson['version'], 0);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('GET /state returns 400 when session id is missing', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/state'),
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
}
