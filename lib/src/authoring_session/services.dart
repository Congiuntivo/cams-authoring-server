part of 'authoring_session.dart';

extension AuthoringSessionServices on AuthoringSession {
  // ASK: Find out if services can be added also to a browser-based protocol.

  void _addConnectedService(
    DeviceConfiguration serviceConfiguration,
  ) {
    // TODO: There can be more than one primary device
    final primaryDeviceConfiguration =
        deviceConfigurationRegistry.activePrimaryDevice;
    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding services.');
    }
    deviceConfigurationRegistry
        .ensureRoleNameAvailable(serviceConfiguration.roleName);

    protocol!
        .addConnectedDevice(serviceConfiguration, primaryDeviceConfiguration);
    deviceConfigurationRegistry.registerService(serviceConfiguration);
    _authoringRequirements
        .registerServiceUsageWarning(serviceConfiguration.roleName);
  }

  void addWeatherService(String? roleName) {
    WeatherService weatherService = WeatherService(
      roleName: roleName,
      apiKey: '<WEATHER_SERVICE_API_KEY>',
    );

    _addConnectedService(weatherService);
  }

  void addAirQualityService(String? roleName) {
    AirQualityService airQualityService = AirQualityService(
      roleName: roleName,
      apiKey: '<AIR_QUALITY_SERVICE_API_KEY>',
    );

    _addConnectedService(airQualityService);
  }

  void addHealthService(String? roleName) {
    HealthService healthService =
        roleName == null ? HealthService() : HealthService(roleName: roleName);

    _addConnectedService(healthService);
  }

  void addLocationService(
    String? roleName,
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
      roleName: roleName,
      accuracy: accuracy ?? GeolocationAccuracy.balanced,
      distance: distance ?? 10.0,
      interval: interval ?? const Duration(minutes: 1),
      notificationTitle: notificationTitle,
      notificationMessage: notificationMessage,
      notificationDescription: notificationDescription,
      notificationIconName: notificationIconName,
      notificationOnTapBringToFront: notificationOnTapBringToFront ?? false,
    );

    _addConnectedService(locationService);
  }

  List<Map<String, Object?>> getServices() {
    return deviceConfigurationRegistry.serviceConfigurations.values
        .map((service) => {
              'name': service.roleName,
              'device': service.toJson(),
            })
        .toList();
  }
}
