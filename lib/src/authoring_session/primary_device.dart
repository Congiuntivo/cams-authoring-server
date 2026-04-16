part of 'authoring_session.dart';

extension AuthoringSessionPrimaryDevice on AuthoringSession {
  void addSmartphonePrimaryDevice(String? roleName) {
    // TODO: We need to allow more than one primary device
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
    deviceConfigurationRegistry
        .ensureRoleNameAvailable(smartphonePrimaryDevice.roleName);

    protocol!.addPrimaryDevice(smartphonePrimaryDevice);
    deviceConfigurationRegistry.registerPrimaryDevice(smartphonePrimaryDevice);

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
    deviceConfigurationRegistry
        .ensureRoleNameAvailable(browserPrimaryDevice.roleName);

    protocol!.addPrimaryDevice(browserPrimaryDevice);
    deviceConfigurationRegistry.registerPrimaryDevice(browserPrimaryDevice);

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  Map<String, Object?> getPrimaryDevice() {
    final primaryDeviceConfiguration =
        deviceConfigurationRegistry.activePrimaryDevice;
    if (primaryDeviceConfiguration == null) {
      throw StateError('No primary device configured');
    }
    return {
      'name': primaryDeviceConfiguration.roleName,
      'device': primaryDeviceConfiguration.toJson(),
    };
  }
}
