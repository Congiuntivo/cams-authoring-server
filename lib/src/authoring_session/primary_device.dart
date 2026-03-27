part of 'authoring_session.dart';

extension AuthoringSessionPrimaryDevice on AuthoringSession {
  void addPrimaryDevice(String deviceType, String? roleName) {
    switch (deviceType) {
      case "smartphone":
        primaryDeviceConfiguration =
            roleName == null ? Smartphone() : Smartphone(roleName: roleName);
        break;
      case "browser":
        primaryDeviceConfiguration =
            roleName == null ? WebBrowser() : WebBrowser(roleName: roleName);
        break;
      default:
        throw ArgumentError('Unsupported device type: $deviceType');
    }

    protocol!.addPrimaryDevice(primaryDeviceConfiguration!);

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  String getPrimaryDeviceRoleName() {
    if (primaryDeviceConfiguration == null) {
      throw StateError('No primary device configured');
    }
    return primaryDeviceConfiguration!.roleName;
  }
}
