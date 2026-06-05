import 'package:flutter/material.dart';

// Convierte Celsius a Fahrenheit
double celsiusToFahrenheit(int celsius) {
  return (celsius * 9 / 5) + 32;
}

// Convierte Fahrenheit a Celsius
int fahrenheitToCelsius(double fahrenheit) {
  return ((fahrenheit - 32) * 5 / 9).toInt();
}

// Obtiene ícono según condición
IconData getWeatherIcon(String condition) {
  switch (condition.toLowerCase()) {
    case 'sunny':
    case 'clear':
      return Icons.wb_sunny;
    case 'cloudy':
    case 'clouds':
      return Icons.wb_cloudy;
    case 'rainy':
    case 'rain':
      return Icons.grain;
    case 'snowy':
    case 'snow':
      return Icons.ac_unit;
    default:
      return Icons.cloud;
  }
}

// Formatea la temperatura con su unidad
String formatTemperature(int temperature, String unit) {
  return '$temperature$unit';
}

// Valida temperatura (está en rango válido)
bool isValidTemperature(int temp) {
  return temp >= -50 && temp <= 50;
}