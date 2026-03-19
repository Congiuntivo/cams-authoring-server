import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(int statusCode, {required Map<String, dynamic> body}) {
  return Response(statusCode,
      body: jsonEncode(body),
      headers: <String, String>{'content-type': 'application/json'});
}