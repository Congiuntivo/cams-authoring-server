import 'dart:io' show HttpStatus;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'authoring_requirements.dart';
import 'http/handlers/authoring_routes.dart';
import 'http/handlers/docs_routes.dart';
import 'http/response/json_response.dart';
import 'protocol_authoring_service.dart';

class ProtocolAuthoringRequestHandler {
  ProtocolAuthoringRequestHandler({ProtocolAuthoringService? service})
      : _service = service ?? ProtocolAuthoringService(),
        _docsRoutes = DocsRoutes();

  final ProtocolAuthoringService _service;
  final DocsRoutes _docsRoutes;

  AuthoringRoutes get _authoringRoutes => AuthoringRoutes(_service);

  Handler get handler => const Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(_errorMiddleware)
      .addHandler(_router.call);

  Router get _router {
    final router = Router();

    _docsRoutes.register(router);
    _authoringRoutes.register(router);

    router.all('/<ignored|.*>', (Request request, String ignored) {
      final path = request.requestedUri.path;
      return jsonResponse(HttpStatus.notFound, body: <String, dynamic>{
        'error': 'Route not found: ${request.method} /$path',
      });
    });

    return router;
  }

  static Middleware get _errorMiddleware => (Handler innerHandler) =>
      (Request request) async {
        try {
          return await innerHandler(request);
        } on FormatException catch (error) {
          return jsonResponse(HttpStatus.badRequest, body: <String, dynamic>{
            'error': 'Invalid JSON: ${error.message}',
          });
        } on AuthoringRequirementsException catch (error) {
          return jsonResponse(HttpStatus.conflict, body: <String, dynamic>{
            'error': error.message,
          });
        } catch (error) {
          return jsonResponse(HttpStatus.internalServerError,
              body: <String, dynamic>{
                'error': 'Unexpected error: $error',
              });
        }
      };
}
