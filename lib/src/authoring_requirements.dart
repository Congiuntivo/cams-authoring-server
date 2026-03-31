import 'package:tuple/tuple.dart';

// Represents the requirements for the authoring session to be able to serialize the protocol.
class AuthoringRequirements {
  AuthoringRequirement dataEndPoint = AuthoringRequirement(
      description: "A data end point must be configured.", isCritical: false);
  AuthoringRequirement primaryDevice =
      AuthoringRequirement(description: "A primary device must be configured.");
  AuthoringRequirement partecipantRole = AuthoringRequirement(
      description: "At least one participant role must be configured.",
      isCritical: false);

  List<AuthoringRequirement> requirements = [];

  List<AuthoringRequirement> get all => requirements;

  AuthoringRequirements(bool isSmartphoneProtocol) {
    if (isSmartphoneProtocol) {
      requirements = [dataEndPoint, primaryDevice, partecipantRole];
    } else {
      requirements = [primaryDevice, partecipantRole];
    }
  }

  Tuple2<bool, List<String>> check() {
    List<String> unfulfilled = [];
    for (var prerequisite in all) {
      if (!prerequisite.isFulfilled) {
        unfulfilled.add(prerequisite.description);
      }
    }
    return Tuple2(unfulfilled.isEmpty, unfulfilled);
  }

  Tuple2<bool, List<String>> checkCritical() {
    List<String> unfulfilled = [];
    for (var prerequisite in all) {
      if (prerequisite.isCritical && !prerequisite.isFulfilled) {
        unfulfilled.add(prerequisite.description);
      }
    }
    return Tuple2(unfulfilled.isEmpty, unfulfilled);
  }

  List<String> get unfulfilledCritical => all
      .where((r) => r.isCritical && !r.isFulfilled)
      .map((r) => r.description)
      .toList();

  List<String> get unfulfilledWarnings => all
      .where((r) => !r.isCritical && !r.isFulfilled)
      .map((r) => r.description)
      .toList();
}

// Represents a single requirement for the authoring session to be able to serialize the protocol.
class AuthoringRequirement {
  bool isFulfilled = false;
  bool isCritical;
  String description;

  // Create a new requirement with the given description and criticality.
  //
  // @param description A description of the requirement.
  // @param isCritical Whether the requirement is critical for the protocol to be serialized. If true, the requirement must be fulfilled for the protocol to be serialized. If false, the requirement is not critical, it will be just a warning if it is not fulfilled.
  AuthoringRequirement({required this.description, this.isCritical = true});
}

class AuthoringRequirementsException implements Exception {
  final String message;

  AuthoringRequirementsException(this.message);

  @override
  String toString() => 'AuthoringRequirementsException: $message';
}
