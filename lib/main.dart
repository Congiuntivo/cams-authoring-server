import 'dart:async';
import 'dart:io';

import 'package:study_protocol_authoring_server/protocol_authoring_server.dart';

Future<void> main() async {
  final host = Platform.environment['HOST'] ?? '0.0.0.0';
  final port = _resolvePort();

  final server = ProtocolAuthoringServer();
  final httpServer = await server.start(host: host, port: port);

  final shutdownCompleter = Completer<void>();

  final sigIntSub = ProcessSignal.sigint.watch().listen((_) {
    shutdownCompleter.complete();
  });
  final sigTermSub = ProcessSignal.sigterm.watch().listen((_) {
    shutdownCompleter.complete();
  });

  await shutdownCompleter.future;

  await sigIntSub.cancel();
  await sigTermSub.cancel();

  stdout.writeln('Shutting down protocol authoring server...');
  await httpServer.close(force: true);
}

int _resolvePort() {
  final rawPort = Platform.environment['PORT'];
  if (rawPort == null || rawPort.isEmpty) return 8080;

  final parsed = int.tryParse(rawPort);
  if (parsed != null && parsed > 0 && parsed <= 65535) {
    return parsed;
  }

  stderr.writeln(
    'Invalid PORT value "$rawPort". Falling back to default 8080.',
  );
  return 8080;
}
