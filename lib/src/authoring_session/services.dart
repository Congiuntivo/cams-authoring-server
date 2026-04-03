part of 'authoring_session.dart';

extension AuthoringSessionServices on AuthoringSession {
  // TODO: Find out if services can be added also to a browser-based protocol.

  void _addConnectedService(
    DeviceConfiguration serviceConfiguration,
    String? requestedRoleName,
  ) {
    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding services.');
    }
    if (_isServiceRoleNameTaken(serviceConfiguration.roleName)) {
      throw ArgumentError(
          'Service role name already taken: $requestedRoleName');
    }

    protocol!
        .addConnectedDevice(serviceConfiguration, primaryDeviceConfiguration!);
    serviceConfigurations.add(serviceConfiguration);
  }

  bool _isServiceRoleNameTaken(String roleName) {
    return serviceConfigurations.any((service) => service.roleName == roleName);
  }

  void addWeatherService(String? roleName) {
    WeatherService weatherService = WeatherService(
      roleName: roleName,
      apiKey: '<WEATHER_SERVICE_API_KEY>',
    );

    _addConnectedService(weatherService, roleName);
  }

  void addAirQualityService(String? roleName) {
    AirQualityService airQualityService = AirQualityService(
      roleName: roleName,
      apiKey: '<AIR_QUALITY_SERVICE_API_KEY>',
    );

    _addConnectedService(airQualityService, roleName);
  }

  void addHealthService(String? roleName) {
    HealthService healthService =
        roleName == null ? HealthService() : HealthService(roleName: roleName);

    _addConnectedService(healthService, roleName);
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

    _addConnectedService(locationService, roleName);
  }

  List<String> getServiceRoleNames() {
    return serviceConfigurations.map((service) => service.roleName).toList();
  }
}
