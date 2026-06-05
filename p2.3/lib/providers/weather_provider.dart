import 'package:flutter/material.dart';
import '../models/weather.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  int _tempUnit = 0; // 0 = Celsius, 1 = Fahrenheit

  // Getters
  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _tempUnit == 0 ? '°C' : '°F';

  // Cargar datos (simulado)
  Future<void> loadWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simula delay de red
      await Future.delayed(const Duration(seconds: 1));

      // Datos hardcodeados (en P2.5 será API real)
      _weather = Weather(
        city: city,
        temperature: 24,
        condition: 'cloudy',
        humidity: 65,
      );
    } catch (e) {
      _errorMessage = 'Error loading weather: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cambiar unidad de temperatura
  void toggleTemperatureUnit() {
    if (_weather != null) {
      int newTemp;
      if (_tempUnit == 0) {
        // Pasar de Celsius a Fahrenheit
        newTemp = ((_weather!.temperature * 9 / 5) + 32).toInt();
      } else {
        // Pasar de Fahrenheit a Celsius
        newTemp = ((_weather!.temperature - 32) * 5 / 9).toInt();
      }
      
      _tempUnit = _tempUnit == 0 ? 1 : 0;
      _weather = Weather(
        city: _weather!.city,
        temperature: newTemp,
        condition: _weather!.condition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  // Actualizar temperatura manualmente
  void changeTemperature(int newTemp) {
    if (_weather != null) {
      _weather = Weather(
        city: _weather!.city,
        temperature: newTemp,
        condition: _weather!.condition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  // Cambiar ciudad
  void changeCity(String newCity) {
    if (_weather != null) {
      _weather = Weather(
        city: newCity,
        temperature: _weather!.temperature,
        condition: _weather!.condition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  // Cambiar condición
  void changeCondition(String newCondition) {
    if (_weather != null) {
      _weather = Weather(
        city: _weather!.city,
        temperature: _weather!.temperature,
        condition: newCondition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }
}