import 'authoring_session.dart';

class ProtocolAuthoringService {
  ProtocolAuthoringService({AuthoringSession? session})
      : _session = session ?? AuthoringSession();

  final AuthoringSession _session;

  Map<String, dynamic> getState() => _session.toStateJson();

  Map<String, dynamic> startNewProtocol() {
    _session.startNewProtocol();
    return _session.toStateJson();
  }

  Map<String, dynamic> serialize() => <String, dynamic>{
        'state': _session.state.name,
        'protocol': _session.toDummySerialization(),
      };
}
