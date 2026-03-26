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
    router.get('/', _getLandingPage);
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

  Response _getLandingPage(Request request) {
    return Response.ok(
        '<!DOCTYPE html>'
        '<html lang="en">'
        '<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>CAMS Authoring Server</title><link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css"></head>'
        '<body>'
        '<h1 class="title">CAMS Authoring Server</h1>'
        '<p>There is nothing here.</p></br><p>You may want to check the <a href="/docs">API documentation</a>.</p></body>'
        '</html>',
        headers: <String, String>{'content-type': 'text/html'});
  }
}
