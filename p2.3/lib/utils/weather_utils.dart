import 'package:flutter/material.dart';

// Esta función toma un número de temperatura y lo prepara para mostrar en pantalla
// Por ejemplo: 22.567 se convierte en "22.6°C"
// Solo tiene 1 decimal para que se vea más limpio
String formatTemperature(double temp, String unit) {
  return '${temp.toStringAsFixed(1)}$unit';
}

// Esta función toma una descripción del clima (texto) y devuelve un ícono
// Por ejemplo: si dice "Soleado", devuelve un ícono de sol
// Es útil para mostrar visualmente qué tiempo hace sin escribir texto
IconData getWeatherIcon(String condition) {
  switch (condition.toLowerCase()) {
    case 'soleado':
      return Icons.wb_sunny;      // Ícono de sol
    case 'nublado':
      return Icons.cloud;          // Ícono de nube
    case 'lluvia':
      return Icons.cloud_queue;    // Ícono de lluvia
    case 'tormenta':
      return Icons.flash_on;       // Ícono de rayo
    case 'nieve':
      return Icons.ac_unit;        // Ícono de nieve
    default:
      return Icons.cloud_circle;   // Si no reconoce, mostrar nube genérica
  }
}