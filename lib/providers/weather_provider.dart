import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherModel? currentWeather;
  List<ForecastModel>? forecastData;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchWeather(String city) async {
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      
      final weatherFuture = WeatherService.getWeather(city);
      final forecastFuture = WeatherService.getForecast(city);

      
      final results = await Future.wait([weatherFuture, forecastFuture]);

      
      currentWeather = results[0] as WeatherModel?;
      forecastData = results[1] as List<ForecastModel>?;

      
      if (currentWeather == null || forecastData == null) {
        errorMessage = 'Failed to fetch weather data';
      }
    } catch (e) {
      
      errorMessage = 'An error occurred: ${e.toString()}';
      currentWeather = null;
      forecastData = null;
    } finally {
      
      isLoading = false;
      notifyListeners();
    }
  }

  
  bool get hasWeatherData => currentWeather != null && forecastData != null;
}
