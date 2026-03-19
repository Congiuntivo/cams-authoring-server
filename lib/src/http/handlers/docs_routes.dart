import 'dart:io' show HttpStatus;

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../openapi.dart';
import '../response/json_response.dart';

class DocsRoutes {
  void register(Router router) {
    router.get('/openapi.json', _getOpenApiJson);
    router.get('/openapi.yaml', _getOpenApiYaml);
    router.get('/docs', _getDocs);
  }

  Response _getOpenApiJson(Request request) {
    final host = request.headers['host'];
    final serverUrl = host == null || host.isEmpty
        ? request.requestedUri.origin
        : '${request.requestedUri.scheme}://$host';
    return jsonResponse(HttpStatus.ok,
        body: buildOpenApiSpec(serverUrl: serverUrl));
  }

  Response _getOpenApiYaml(Request request) {
    return Response.ok(openApiYaml(),
        headers: <String, String>{'content-type': 'application/yaml'});
  }

  Response _getDocs(Request request) {
    return Response.ok(swaggerUiHtml(),
        headers: <String, String>{'content-type': 'text/html'});
  }
}