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
  test('GET /state, POST /protocol/new, GET /serialize work as expected',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');

      final stateBefore = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/state'),
      );
      expect(stateBefore['statusCode'], HttpStatus.ok);
      expect(
        stateBefore['json'],
        <String, dynamic>{'state': 'ready'},
      );

      final newProtocol = await _requestJson(
        client: client,
        method: 'POST',
        uri: baseUri.resolve('/protocol/new'),
      );
      expect(newProtocol['statusCode'], HttpStatus.created);
      expect(
        newProtocol['json'],
        <String, dynamic>{'state': 'protocolStarted'},
      );

      final serialized = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/serialize'),
      );
      expect(serialized['statusCode'], HttpStatus.ok);

      final serializedJson = serialized['json'] as Map<String, dynamic>;
      expect(serializedJson['state'], 'protocolStarted');
      final protocol = serializedJson['protocol'] as Map<String, dynamic>;
      expect(protocol['dummy'], true);
      expect((protocol['protocol'] as Map<String, dynamic>)['name'],
          'dummy_protocol');
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });
}
