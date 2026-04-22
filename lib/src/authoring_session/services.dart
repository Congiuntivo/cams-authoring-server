part of 'authoring_session.dart';

extension AuthoringSessionServices on AuthoringSession {
  void _addConnectedService(
    DeviceConfiguration serviceConfiguration,
    String primaryDeviceRoleName,
  ) {
    final primaryDeviceConfiguration =
        _state.findPrimaryDevice(primaryDeviceRoleName);
    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding services.');
    }
    if (_state.isDeviceRoleNameUsed(serviceConfiguration.roleName)) {
      throw ArgumentError(
          'Device role name already taken: ${serviceConfiguration.roleName}');
    }

    protocol.addConnectedDevice(
        serviceConfiguration, primaryDeviceConfiguration);
    _state.addService(serviceConfiguration);
    _authoringRequirements
        .registerServiceUsageWarning(serviceConfiguration.roleName);
  }

  void addWeatherService(
      String? connectedDeviceRoleName, String primaryDeviceRoleName) {
    WeatherService weatherService = WeatherService(
      roleName: connectedDeviceRoleName,
      apiKey: '<WEATHER_SERVICE_API_KEY>',
    );

    _addConnectedService(weatherService, primaryDeviceRoleName);
  }

  void addAirQualityService(
      String? connectedDeviceRoleName, String primaryDeviceRoleName) {
    AirQualityService airQualityService = AirQualityService(
      roleName: connectedDeviceRoleName,
      apiKey: '<AIR_QUALITY_SERVICE_API_KEY>',
    );

    _addConnectedService(airQualityService, primaryDeviceRoleName);
  }

  void addHealthService(
      String? connectedDeviceRoleName, String primaryDeviceRoleName) {
    HealthService healthService = connectedDeviceRoleName == null
        ? HealthService()
        : HealthService(roleName: connectedDeviceRoleName);

    _addConnectedService(healthService, primaryDeviceRoleName);
  }

  void addLocationService(
    String? connectedDeviceRoleName,
    String primaryDeviceRoleName,
    GeolocationAccuracy? accuracy,
    double? distance,
    Duration? interval,
    String? notificationTitle,
    String? notificationMessage,
    String? notificationDescription,
    String? notificationIconName,
    bool? notificationOnTapBringToFront,
  ) {
    LocationService locationService = LocationService(
      roleName: connectedDeviceRoleName,
      accuracy: accuracy ?? GeolocationAccuracy.balanced,
      distance: distance ?? 10.0,
      interval: interval ?? const Duration(minutes: 1),
      notificationTitle: notificationTitle,
      notificationMessage: notificationMessage,
      notificationDescription: notificationDescription,
      notificationIconName: notificationIconName,
      notificationOnTapBringToFront: notificationOnTapBringToFront ?? false,
    );

    _addConnectedService(locationService, primaryDeviceRoleName);
  }

  List<Map<String, Object?>> getServices() {
    return _state.allServices
        .map((service) => {
              'name': service.roleName,
              'device': service.toJson(),
            })
        .toList();
  }
}
