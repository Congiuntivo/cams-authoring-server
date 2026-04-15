part of 'authoring_session.dart';

extension AuthoringSessionServices on AuthoringSession {
  // ASK: Find out if services can be added also to a browser-based protocol.

  int _roleNameSourcesCount(String roleName) {
    var count = 0;
    if (deviceConfigurations.containsKey(roleName)) count++;
    if (serviceConfigurations.containsKey(roleName)) count++;
    if (primaryDeviceConfiguration?.roleName == roleName) count++;
    return count;
  }

  bool _isRoleNameTaken(String roleName) {
    return _roleNameSourcesCount(roleName) > 0;
  }

  void _addConnectedService(
    DeviceConfiguration serviceConfiguration,
  ) {
    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding services.');
    }
    if (_isRoleNameTaken(serviceConfiguration.roleName)) {
      throw ArgumentError(
          'Service role name already taken: ${serviceConfiguration.roleName}');
    }

    protocol!
        .addConnectedDevice(serviceConfiguration, primaryDeviceConfiguration!);
    serviceConfigurations[serviceConfiguration.roleName] = serviceConfiguration;
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
    return serviceConfigurations.values
        .map((service) => {
              'name': service.roleName,
              'device': service.toJson(),
            })
        .toList();
  }
}
