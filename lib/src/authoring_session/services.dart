part of 'authoring_session.dart';

extension AuthoringSessionServices on AuthoringSession {
  // TODO: Find out if services can be added also to a browser-based protocol.

  bool _isServiceRoleNameTaken(String roleName) {
    return serviceConfigurations.any((service) => service.roleName == roleName);
  }

  void addWeatherService(String? roleName) {
    WeatherService weatherService = WeatherService(
      roleName: roleName,
      apiKey: '<WEATHER_SERVICE_API_KEY>',
    );

    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding services.');
    }
    if (_isServiceRoleNameTaken(weatherService.roleName)) {
      throw ArgumentError('Service role name already taken: $roleName');
    }

    protocol!.addConnectedDevice(weatherService, primaryDeviceConfiguration!);
    serviceConfigurations.add(weatherService);
  }

  void addAirQualityService(String? roleName) {
    AirQualityService airQualityService = AirQualityService(
      roleName: roleName,
      apiKey: '<AIR_QUALITY_SERVICE_API_KEY>',
    );

    if (primaryDeviceConfiguration == null) {
      throw StateError(
          'Primary device configuration must be set before adding services.');
    }
    if (_isServiceRoleNameTaken(airQualityService.roleName)) {
      throw ArgumentError('Service role name already taken: $roleName');
    }

    protocol!
        .addConnectedDevice(airQualityService, primaryDeviceConfiguration!);
    serviceConfigurations.add(airQualityService);
  }

  List<String> getServiceRoleNames() {
    return serviceConfigurations.map((service) => service.roleName).toList();
  }
}
