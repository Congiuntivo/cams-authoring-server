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
  final Map<String, AuthoringRequirement> _taskUsageWarnings =
      <String, AuthoringRequirement>{};

  List<AuthoringRequirement> get all => requirements;

  AuthoringRequirements(bool isSmartphoneProtocol) {
    if (isSmartphoneProtocol) {
      requirements = [dataEndPoint, primaryDevice, partecipantRole];
    } else {
      requirements = [primaryDevice, partecipantRole];
    }
  }

  String _taskUsageDescription(String taskName) =>
      'Task "$taskName" must be used by at least one task control.';

  void registerTaskUsageWarning(String taskName) {
    final existing = _taskUsageWarnings[taskName];
    if (existing != null) {
      existing.isFulfilled = false;
      return;
    }

    final warning = AuthoringRequirement(
      description: _taskUsageDescription(taskName),
      isCritical: false,
    );
    _taskUsageWarnings[taskName] = warning;
    requirements.add(warning);
  }

  void markTaskUsageWarningFulfilled(String taskName) {
    final warning = _taskUsageWarnings[taskName];
    if (warning == null) return;

    warning.isFulfilled = true;
  }

  ({bool allFulfilled, List<String> unfulfilled}) check() {
    final unfulfilled = <String>[];

    for (var prerequisite in all) {
      if (!prerequisite.isFulfilled) {
        unfulfilled.add(prerequisite.description);
      }
    }

    return (
      allFulfilled: unfulfilled.isEmpty,
      unfulfilled: unfulfilled,
    );
  }

  ({bool allFulfilled, List<String> unfulfilled}) checkCritical() {
    final unfulfilled = <String>[];

    for (var prerequisite in all) {
      if (prerequisite.isCritical && !prerequisite.isFulfilled) {
        unfulfilled.add(prerequisite.description);
      }
    }

    return (
      allFulfilled: unfulfilled.isEmpty,
      unfulfilled: unfulfilled,
    );
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
