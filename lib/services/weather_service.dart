import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';

class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double feelsLike;
  final int humidity;
  final double windSpeed;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown City',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? 'No description',
      icon: json['weather'][0]['icon'] ?? '01d',
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}

class ForecastModel {
  final String date;
  final double temperature;
  final String description;
  final String icon;

  ForecastModel({
    required this.date,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: json['dt_txt'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? 'No description',
      icon: json['weather'][0]['icon'] ?? '01d',
    );
  }
}

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const int _timeoutDuration = 10; 

  // Get Current Weather Data
  static Future<WeatherModel?> getWeather(String city) async {
    final url = Uri.parse(
      '$_baseUrl/weather?q=$city&appid=$WEATHER_API_KEY&units=metric',
    );

    try {
      final response = await http
          .get(url)
          .timeout(
            Duration(seconds: _timeoutDuration),
            onTimeout: () {
              throw TimeoutException('Connection timeout');
            },
          );

      _logResponse(response, 'Current Weather');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        _handleErrorResponse(response);
        return null;
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      return null;
    } on http.ClientException catch (e) {
      print('Network Error: $e');
      return null;
    } catch (e) {
      print('Unexpected Error: $e');
      return null;
    }
  }

  // Get 5-day Weather Forecast
  static Future<List<ForecastModel>?> getForecast(String city) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?q=$city&appid=$WEATHER_API_KEY&units=metric',
    );

    try {
      final response = await http
          .get(url)
          .timeout(
            Duration(seconds: _timeoutDuration),
            onTimeout: () {
              throw TimeoutException('Connection timeout');
            },
          );

      _logResponse(response, 'Weather Forecast');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Filter forecast to get one entry per day
        List<dynamic> forecastList = data['list'];
        Set<String> processedDates = {};
        List<ForecastModel> dailyForecasts = [];

        for (var forecast in forecastList) {
          String date = (forecast['dt_txt'] as String).split(' ')[0];
          if (!processedDates.contains(date)) {
            processedDates.add(date);
            dailyForecasts.add(ForecastModel.fromJson(forecast));
          }
        }

        return dailyForecasts;
      } else {
        _handleErrorResponse(response);
        return null;
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      return null;
    } on http.ClientException catch (e) {
      print('Network Error: $e');
      return null;
    } catch (e) {
      print('Unexpected Error: $e');
      return null;
    }
  }

  // Detailed Logging Method
  static void _logResponse(http.Response response, String requestType) {
    print('$requestType Request:');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }

  // Error Handling Method
  static void _handleErrorResponse(http.Response response) {
    switch (response.statusCode) {
      case 401:
        print('Unauthorized: Check your API key');
        break;
      case 404:
        print('City not found');
        break;
      case 429:
        print('Too many requests. Check API usage limits');
        break;
      case 500:
        print('Server error. Try again later');
        break;
      default:
        print('Unexpected error: ${response.statusCode}');
    }
  }
}
