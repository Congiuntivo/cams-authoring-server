import 'dart:convert';

import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_serializable/carp_serializable.dart';

class AuthoringSession {
  static const String startedState = 'protocolStarted';

  SmartphoneStudyProtocol? protocol;

  void newProtocol(
    String name,
    String? ownerId,
  ) {
    if (protocol != null) {
      throw StateError('Protocol already exists in session');
    }
    protocol = SmartphoneStudyProtocol(
      name: name,
      ownerId: ownerId ?? const Uuid().v1,
    );
  }

  Map<String, dynamic> toStateJson() => <String, dynamic>{
        'state': startedState,
      };

  Map<String, dynamic> serialize() {
    if (protocol == null) {
      throw StateError('No protocol to serialize');
    }
    return jsonDecode(toJsonString(protocol));
  }
}
