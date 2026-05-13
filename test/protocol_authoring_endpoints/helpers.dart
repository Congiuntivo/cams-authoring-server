import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:study_protocol_authoring_server/src/authoring_request_handler.dart';

Future<HttpServer> startTestServer() async {
  final handler = ProtocolAuthoringRequestHandler();
  return shelf_io.serve(handler.handler, InternetAddress.loopbackIPv4, 0);
}

Future<Map<String, dynamic>> requestJson({
  required HttpClient client,
  required String method,
  required Uri uri,
  Map<String, dynamic>? jsonBody,
}) async {
  Map<String, dynamic>? effectiveJsonBody = jsonBody;
  if (effectiveJsonBody == null && method.toUpperCase() == 'POST') {
    if (uri.path == '/sessions') {
      effectiveJsonBody = <String, dynamic>{
        'name': 'Unnamed Protocol',
      };
    }
  }

  final request = await client.openUrl(method, uri);
  if (effectiveJsonBody != null) {
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(effectiveJsonBody));
  }

  final response = await request.close();
  final body = await utf8.decoder.bind(response).join();
  return <String, dynamic>{
    'statusCode': response.statusCode,
    'json': jsonDecode(body) as Map<String, dynamic>,
  };
}
