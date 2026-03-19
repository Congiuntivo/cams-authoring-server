import 'package:flutter/material.dart';

import 'package:study_protocol_authoring_server/protocol_authoring_server.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _ServerHostApp());
}

class _ServerHostApp extends StatelessWidget {
  const _ServerHostApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _ServerHostPage(),
    );
  }
}

class _ServerHostPage extends StatefulWidget {
  const _ServerHostPage();

  @override
  State<_ServerHostPage> createState() => _ServerHostPageState();
}

class _ServerHostPageState extends State<_ServerHostPage> {
  String _status = 'Starting local protocol authoring server...';

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    const host = '0.0.0.0';
    const port = 8080;

    try {
      final server = ProtocolAuthoringServer();
      setState(() => _status = 'Server running on http://$host:$port');
      await server.start(host: host, port: port);
    } catch (error) {
      setState(() => _status = 'Server failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CARP Protocol Authoring Server')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _status,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
