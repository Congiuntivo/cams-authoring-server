part of 'authoring_session.dart';

extension AuthoringSessionPrimaryDevice on AuthoringSession {
  void addSmartphonePrimaryDevice(String? roleName) {
    final smartphonePrimaryDevice =
        roleName == null ? Smartphone() : Smartphone(roleName: roleName);
    if (_state.isDeviceRoleNameUsed(smartphonePrimaryDevice.roleName)) {
      throw ArgumentError(
          'Device role name already taken: ${smartphonePrimaryDevice.roleName}');
    }

    protocol.addPrimaryDevice(smartphonePrimaryDevice);
    _state.addPrimaryDevice(smartphonePrimaryDevice);

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  void addBrowserPrimaryDevice(String? roleName) {
    final browserPrimaryDevice =
        roleName == null ? WebBrowser() : WebBrowser(roleName: roleName);
    if (_state.isDeviceRoleNameUsed(browserPrimaryDevice.roleName)) {
      throw ArgumentError(
          'Device role name already taken: ${browserPrimaryDevice.roleName}');
    }

    protocol.addPrimaryDevice(browserPrimaryDevice);
    _state.addPrimaryDevice(browserPrimaryDevice);

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  List<Map<String, Object?>> getPrimaryDevices() {
    return _state.primaryDeviceEntries
        .map((entry) => {
              'name': entry.key,
              'device': entry.value.toJson(),
            })
        .toList();
  }
}
