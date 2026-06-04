import 'package:flutter/material.dart';
import '../models/weather.dart';

// Este es el "gerente" de la información del clima
// Aquí se guarda la información y se controla cómo cambia
// Cuando algo cambia, notifica a todos los widgets que lo están observando
class WeatherProvider extends ChangeNotifier {
  
  // Almacenamos los datos del clima (temperatura inicial, ciudad, etc)
  Weather _weather = Weather(
    city: 'Madrid',
    temp: 22.5,
    condition: 'Soleado',
    unit: '°C',
  );

  // Permite que otros archivos lean los datos del clima
  // (pero no puedan cambiarlos directamente)
  Weather get weather => _weather;

  // Cuando cambias la ciudad:
  // 1. Actualiza el dato
  // 2. Avisa a todos los widgets para que se redibjen
  void changeCity(String newCity) {
    _weather = _weather.copyWith(city: newCity);
    notifyListeners(); // "Oye, algo cambió, actualiza lo que estás mostrando"
  }

  // Mismo proceso pero para la temperatura
  void changeTemperature(double newTemp) {
    _weather = _weather.copyWith(temp: newTemp);
    notifyListeners();
  }

  // Mismo proceso pero para la condición (soleado, nublado, etc)
  void changeCondition(String newCondition) {
    _weather = _weather.copyWith(condition: newCondition);
    notifyListeners();
  }

  // Mismo proceso pero para la unidad (Celsius o Fahrenheit)
  void changeUnit(String newUnit) {
    _weather = _weather.copyWith(unit: newUnit);
    notifyListeners();
  }
}