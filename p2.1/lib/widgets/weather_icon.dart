import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;

  const WeatherIcon({
    super.key,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (condition) {
      case 'sunny':
        icon = Icons.sunny;
        break;
      case 'rainy':
        icon = Icons.cloudy_snowing;
        break;
      default:
        icon = Icons.cloud;
    }

    return Icon(
      icon,
      size: 120,
      color: Colors.blue,
    );
  }
}