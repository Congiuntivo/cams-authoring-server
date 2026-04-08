import 'dart:convert';
import 'dart:io';

import 'package:carp_backend/carp_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:study_protocol_authoring_server/src/authoring_requirements.dart';
import 'package:study_protocol_authoring_server/src/protocol_authoring_request_handler.dart';
import 'package:study_protocol_authoring_server/src/protocol_authoring_service.dart';

class _ThrowingSerializeService extends ProtocolAuthoringService {
  _ThrowingSerializeService({required this.requirements});

  final AuthoringRequirements requirements;

  @override
  Map<String, dynamic> createNewProtocol(
    String name,
    String? ownerId,
    bool isSmartphone,
  ) {
    return <String, dynamic>{
      'sessionId': 'session_test',
      'warnings': <String>[],
      'unfulfilledCritical': <String>[],
    };
  }

  @override
  Map<String, dynamic> getRequirements(String sessionId) => <String, dynamic>{
        'warnings': <String>[],
        'unfulfilledCritical': <String>[],
      };

  @override
  Map<String, dynamic> addDataEndPoint(
    String sessionId,
    String endPointType,
    CarpUploadMethod? method,
    String? name,
    bool? deleteWhenUploaded,
  ) {
    return <String, dynamic>{
      'sessionId': sessionId,
      'warnings': <String>[],
      'unfulfilledCritical': <String>[],
    };
  }

  @override
  Map<String, dynamic> serialize(String sessionId) {
    final criticalCheck = requirements.checkCritical();
    if (!criticalCheck.item1) {
      throw AuthoringRequirementsException(criticalCheck.item2.join(', '));
    }

    return <String, dynamic>{'protocol': <String, dynamic>{}};
  }
}

AuthoringRequirements _requirementsWithMissingCritical() {
  final requirements = AuthoringRequirements(true);
  requirements.dataEndPoint.description =
      'Injected critical requirement is not fulfilled.';
  requirements.dataEndPoint.isCritical = true;
  requirements.dataEndPoint.isFulfilled = false;
  requirements.primaryDevice.isFulfilled = true;
  return requirements;
}

Future<HttpServer> _startTestServer() async {
  final handler = ProtocolAuthoringRequestHandler(
    service: _ThrowingSerializeService(
      requirements: _requirementsWithMissingCritical(),
    ),
  );
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
  test('GET /serialize returns 409 when a critical requirement is unsatisfied',
      () async {
    final server = await _startTestServer();
    final client = HttpClient();

    try {
      final baseUri = Uri.parse('http://127.0.0.1:${server.port}');
      final response = await _requestJson(
        client: client,
        method: 'GET',
        uri: baseUri.resolve('/sessions/session_test/serialize'),
      );

      expect(response['statusCode'], HttpStatus.conflict);
      expect(
        (response['json'] as Map<String, dynamic>)['error'],
        'Injected critical requirement is not fulfilled.',
      );
    } finally {
      client.close(force: true);
      await server.close(force: true);
    }
  });
}
