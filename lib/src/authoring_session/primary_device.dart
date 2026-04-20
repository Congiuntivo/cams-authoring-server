part of 'authoring_session.dart';

extension AuthoringSessionPrimaryDevice on AuthoringSession {
  void addSmartphonePrimaryDevice(String? roleName) {
    final smartphonePrimaryDevice =
        roleName == null ? Smartphone() : Smartphone(roleName: roleName);
    deviceConfigurationRegistry
        .ensureRoleNameAvailable(smartphonePrimaryDevice.roleName);

    protocol.addPrimaryDevice(smartphonePrimaryDevice);
    deviceConfigurationRegistry.registerPrimaryDevice(smartphonePrimaryDevice);

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  void addBrowserPrimaryDevice(String? roleName) {
    final browserPrimaryDevice =
        roleName == null ? WebBrowser() : WebBrowser(roleName: roleName);
    deviceConfigurationRegistry
        .ensureRoleNameAvailable(browserPrimaryDevice.roleName);

    protocol.addPrimaryDevice(browserPrimaryDevice);
    deviceConfigurationRegistry.registerPrimaryDevice(browserPrimaryDevice);

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  List<Map<String, Object?>> getPrimaryDevices() {
    return deviceConfigurationRegistry.primaryDeviceConfigurations.entries
        .map((entry) => {
              'name': entry.key,
              'device': entry.value.toJson(),
            })
        .toList();
  }
}
