// Esta clase es como un contenedor de información del clima
// Guarda todos los datos que necesitamos: ciudad, temperatura, condición, unidad
class Weather {
  final String city;      // Nombre de la ciudad
  final double temp;      // Temperatura en números
  final String condition; // Si está soleado, nublado, lluvia, etc
  final String unit;      // Si es Celsius (°C) o Fahrenheit (°F)

  // Constructor: para crear un objeto Weather con información
  Weather({
    required this.city,
    required this.temp,
    required this.condition,
    required this.unit,
  });

  // copyWith: hace una copia del objeto pero cambia solo lo que le pidas
  // Por ejemplo, si quiero cambiar la ciudad pero mantener la temperatura igual
  // En lugar de crear uno nuevo, usamos copyWith para no perder los otros datos
  Weather copyWith({
    String? city,
    double? temp,
    String? condition,
    String? unit,
  }) {
    return Weather(
      city: city ?? this.city,           // Usa el nuevo valor o mantiene el anterior
      temp: temp ?? this.temp,
      condition: condition ?? this.condition,
      unit: unit ?? this.unit,
    );
  }
}