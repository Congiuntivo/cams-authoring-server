enum ProtocolAuthoringState {
  ready,
  protocolStarted,
}

class AuthoringSession {
  ProtocolAuthoringState state = ProtocolAuthoringState.ready;

  void startNewProtocol() {
    state = ProtocolAuthoringState.protocolStarted;
  }

  Map<String, dynamic> toStateJson() => <String, dynamic>{
        'state': state.name,
      };

  Map<String, dynamic> toDummySerialization() => <String, dynamic>{
        'dummy': true,
        'protocol': <String, dynamic>{
          'name': 'dummy_protocol',
          'version': 1,
        },
      };
}
