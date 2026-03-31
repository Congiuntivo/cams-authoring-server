part of 'authoring_session.dart';

extension AuthoringSessionPrimaryDevice on AuthoringSession {
  void addSmartphonePrimaryDevice(String? roleName) {
    if (protocol == null) {
      throw StateError(
          'Cannot add primary device before protocol has started.');
    }
    if (!isSmartphoneProtocol) {
      throw StateError(
          'Smartphone primary device can only be added to smartphone protocols');
    }

    primaryDeviceConfiguration =
        roleName == null ? Smartphone() : Smartphone(roleName: roleName);

    protocol!.addPrimaryDevice(primaryDeviceConfiguration!);

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  void addBrowserPrimaryDevice(String? roleName) {
    if (protocol == null) {
      throw StateError(
          'Cannot add primary device before protocol has started.');
    }
    if (isSmartphoneProtocol) {
      throw StateError(
          'Browser primary device can only be added to default protocols');
    }

    primaryDeviceConfiguration =
        roleName == null ? WebBrowser() : WebBrowser(roleName: roleName);

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
