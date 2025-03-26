import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherModel? currentWeather;
  List<ForecastModel>? forecastData;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchWeather(String city) async {
    // Set loading state
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Fetch current weather and forecast concurrently
      final weatherFuture = WeatherService.getWeather(city);
      final forecastFuture = WeatherService.getForecast(city);

      // Wait for both futures to complete
      final results = await Future.wait([weatherFuture, forecastFuture]);

      // Assign results
      currentWeather = results[0] as WeatherModel?;
      forecastData = results[1] as List<ForecastModel>?;

      // Check if data was successfully fetched
      if (currentWeather == null || forecastData == null) {
        errorMessage = 'Failed to fetch weather data';
      }
    } catch (e) {
      // Capture any unexpected errors
      errorMessage = 'An error occurred: ${e.toString()}';
      currentWeather = null;
      forecastData = null;
    } finally {
      // Always set loading to false
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to check if weather data is available
  bool get hasWeatherData => currentWeather != null && forecastData != null;
}
