import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'src/protocol_authoring_request_handler.dart';

class ProtocolAuthoringServer {
  ProtocolAuthoringServer({ProtocolAuthoringRequestHandler? handler})
      : _handler = handler ?? ProtocolAuthoringRequestHandler();

  final ProtocolAuthoringRequestHandler _handler;

  Future<void> start({required String host, required int port}) async {
    await shelf_io.serve(_handler.handler, host, port);
    stdout.writeln('Protocol authoring server listening on http://$host:$port');
  }
}
