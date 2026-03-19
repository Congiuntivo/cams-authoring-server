enum AuthoringSessionState {
  sessionCreated,
  protocolStarted,
  addedDataEndPoint,
}

enum AuthoringSessionAction {
  startProtocol,
  serializeProtocol,
  addDataEndPoint,
}

class InvalidAuthoringTransitionException implements Exception {
  InvalidAuthoringTransitionException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'Invalid authoring transition: $message';
}

class AuthoringSessionWorkflow {
  AuthoringSessionState _state = AuthoringSessionState.sessionCreated;

  String get stateName => switch (_state) {
        AuthoringSessionState.sessionCreated => 'sessionCreated',
        AuthoringSessionState.protocolStarted => 'protocolStarted',
        AuthoringSessionState.addedDataEndPoint => 'addedDataEndPoint',
      };

  void startProtocol() {
    _dispatch(AuthoringSessionAction.startProtocol,
        reason: 'start protocol before session has been created');
  }

  void requestSerialization() {
    _dispatch(AuthoringSessionAction.serializeProtocol,
        reason: 'serialize protocol before adding data endpoint');
  }

  void addDataEndPoint() {
    _dispatch(AuthoringSessionAction.addDataEndPoint,
        reason: 'add data endpoint before protocol has started');
  }

  void _dispatch(
    AuthoringSessionAction action, {
    required String reason,
  }) {
    final isValidTransition = switch ((_state, action)) {
      (
        AuthoringSessionState.sessionCreated,
        AuthoringSessionAction.startProtocol
      ) =>
        true,
      (
        AuthoringSessionState.protocolStarted,
        AuthoringSessionAction.addDataEndPoint
      ) =>
        true,
      (
        AuthoringSessionState.addedDataEndPoint,
        AuthoringSessionAction.serializeProtocol
      ) =>
        true,
      (
        AuthoringSessionState.addedDataEndPoint,
        AuthoringSessionAction.addDataEndPoint
      ) =>
        true,
      _ => false,
    };

    if (!isValidTransition) {
      throw InvalidAuthoringTransitionException(
        '$reason (current state: $stateName)',
      );
    }

    if (action == AuthoringSessionAction.startProtocol) {
      _state = AuthoringSessionState.protocolStarted;
    }
    if (action == AuthoringSessionAction.addDataEndPoint) {
      _state = AuthoringSessionState.addedDataEndPoint;
    }
  }
}
