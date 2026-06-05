class Weather {
  final String city;
  final int temperature;
  final String condition;
  final int humidity;

  Weather({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.humidity,
  });

  // Crear una copia con algunos campos modificados
  Weather copyWith({
    String? city,
    int? temperature,
    String? condition,
    int? humidity,
  }) {
    return Weather(
      city: city ?? this.city,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      humidity: humidity ?? this.humidity,
    );
  }

  // Convertir JSON a Weather
  factory Weather.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('main')) {
      throw FormatException('Missing main field in weather data');
    }

    final temp = json['main']['temp'];
    if (temp is! num) {
      throw FormatException('Temperature must be number');
    }

    return Weather(
      city: json['name'] ?? 'Unknown',
      temperature: temp.toInt(),
      condition: (json['weather'] as List?)?.isNotEmpty == true
          ? json['weather'][0]['main'] ?? 'unknown'
          : 'unknown',
      humidity: json['main']['humidity'] ?? 0,
    );
  }

  // Convertir Weather a JSON
  Map<String, dynamic> toJson() => {
    'city': city,
    'temperature': temperature,
    'condition': condition,
    'humidity': humidity,
  };

  @override
  String toString() {
    return 'Weather(city: $city, temp: $temperature°C, condition: $condition, humidity: $humidity%)';
  }
}