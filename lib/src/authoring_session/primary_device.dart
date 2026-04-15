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

    final smartphonePrimaryDevice =
        roleName == null ? Smartphone() : Smartphone(roleName: roleName);
    if (_isRoleNameTaken(smartphonePrimaryDevice.roleName)) {
      throw ArgumentError(
          'Primary device role name already taken: ${smartphonePrimaryDevice.roleName}');
    }

    primaryDeviceConfiguration = smartphonePrimaryDevice;

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

    final browserPrimaryDevice =
        roleName == null ? WebBrowser() : WebBrowser(roleName: roleName);
    if (_isRoleNameTaken(browserPrimaryDevice.roleName)) {
      throw ArgumentError(
          'Primary device role name already taken: ${browserPrimaryDevice.roleName}');
    }

    primaryDeviceConfiguration = browserPrimaryDevice;

    protocol!.addPrimaryDevice(primaryDeviceConfiguration!);

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  Map<String, Object?> getPrimaryDevice() {
    if (primaryDeviceConfiguration == null) {
      throw StateError('No primary device configured');
    }
    return {
      'name': primaryDeviceConfiguration!.roleName,
      'device': primaryDeviceConfiguration!.toJson(),
    };
  }
}
