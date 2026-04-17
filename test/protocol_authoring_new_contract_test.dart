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
  test('POST /protocol/new/smartphone requires a JSON body with name',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final missingBody = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
      );
      expect(missingBody['statusCode'], HttpStatus.badRequest);

      final missingName = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
        jsonBody: <String, dynamic>{},
      );
      expect(missingName['statusCode'], HttpStatus.badRequest);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('POST /protocol/new/default requires a JSON body with name', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final missingBody = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/default'),
      );
      expect(missingBody['statusCode'], HttpStatus.badRequest);

      final missingName = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/default'),
        jsonBody: <String, dynamic>{},
      );
      expect(missingName['statusCode'], HttpStatus.badRequest);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('smartphone protocol accepts metadata and strict privacy schema',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final invalidPrivacy = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
        jsonBody: <String, dynamic>{
          'name': 'My Study Protocol',
          'privacySchemaName': 'invalid-schema',
        },
      );
      expect(invalidPrivacy['statusCode'], HttpStatus.badRequest);

      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
        jsonBody: <String, dynamic>{
          'name': 'My Study Protocol',
          'protocolVersionTag': 'v1.0.0',
          'protocolApiLevel': '2.0',
          'applicationName': 'carp_study_app',
          'privacySchemaName': 'default-privacy-schema',
        },
      );
      expect(created['statusCode'], HttpStatus.created);
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/data-endpoint'),
        jsonBody: <String, dynamic>{
          'endpointType': 'CAWS',
          'name': 'CARP Web Services',
        },
      );

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'smartphone'},
      );

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/serialize'),
      );
      expect(serialized['statusCode'], HttpStatus.ok);

      final protocol = (serialized['json'] as Map<String, dynamic>)['protocol']
          as Map<String, dynamic>;
      final applicationData =
          protocol['applicationData'] as Map<String, dynamic>;

      expect(applicationData['protocolVersionTag'], 'v1.0.0');
      expect(applicationData['protocolApiLevel'], '2.0');
      expect(applicationData['applicationName'], 'carp_study_app');
      expect(applicationData['privacySchemaName'], 'default-privacy-schema');
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('FILE endpoint requires publicKey when encrypt is true', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
        jsonBody: <String, dynamic>{'name': 'My Study Protocol'},
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addEndpoint = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/data-endpoint'),
        jsonBody: <String, dynamic>{
          'endpointType': 'FILE',
          'encrypt': true,
        },
      );

      expect(addEndpoint['statusCode'], HttpStatus.badRequest);
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });

  test('FILE endpoint advanced parameters are serialized', () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final created = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new/smartphone'),
        jsonBody: <String, dynamic>{'name': 'My Study Protocol'},
      );
      final sessionId =
          (created['json'] as Map<String, dynamic>)['sessionId'] as String;

      final addEndpoint = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/data-endpoint'),
        jsonBody: <String, dynamic>{
          'endpointType': 'FILE',
          'bufferSize': 123456,
          'zip': false,
          'encrypt': true,
          'publicKey': 'public-key',
        },
      );
      expect(addEndpoint['statusCode'], HttpStatus.ok);

      await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/sessions/$sessionId/primary-device'),
        jsonBody: <String, dynamic>{'deviceType': 'smartphone'},
      );

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/$sessionId/serialize'),
      );
      expect(serialized['statusCode'], HttpStatus.ok);

      final protocol = (serialized['json'] as Map<String, dynamic>)['protocol']
          as Map<String, dynamic>;
      final applicationData =
          protocol['applicationData'] as Map<String, dynamic>;
      final dataEndPoint =
          applicationData['dataEndPoint'] as Map<String, dynamic>;

      expect(dataEndPoint['type'], 'FILE');
      expect(dataEndPoint['bufferSize'], 123456);
      expect(dataEndPoint['zip'], false);
      expect(dataEndPoint['encrypt'], true);
      expect(dataEndPoint['publicKey'], 'public-key');
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });
}
