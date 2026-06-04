import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima Actual'), centerTitle: true),
      // Consumer es como un "oyente" que escucha cambios del WeatherProvider
      // Si algo cambia en el clima, Consumer reconstruye automáticamente
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          // Obtenemos los datos del clima desde el provider
          final weather = weatherProvider.weather;
          // Usamos las funciones puras para formatear la información
          final formattedTemp = formatTemperature(weather.temp, weather.unit);
          final icon = getWeatherIcon(weather.condition);

          return OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                // Diseño para teléfono vertical
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formattedTemp,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(weather.city, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 32),
                        Icon(icon, size: 120, color: Colors.blue),
                        const SizedBox(height: 32),
                        Text('Condición: ${weather.condition}'),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SearchScreen()),
                            );
                          },
                          child: const Text('Buscar Ciudades'),
                        ),
                        const SizedBox(height: 16),
                        // Botones de prueba para ver cómo Provider actualiza la pantalla
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Botón 1: aumenta la temperatura 1 grado
                            // Al presionar, llama al método changeTemperature del provider
                            // Provider notifica del cambio y la pantalla se actualiza automáticamente
                            ElevatedButton(
                              onPressed: () {
                                weatherProvider.changeTemperature(weather.temp + 1);
                              },
                              child: const Text('Temp +1'),
                            ),
                            const SizedBox(width: 8),
                            // Botón 2: cambia la ciudad a Barcelona
                            // Funciona igual: cambia el dato, Provider avisa, pantalla se actualiza
                            ElevatedButton(
                              onPressed: () {
                                weatherProvider.changeCity('Barcelona');
                              },
                              child: const Text('Cambiar a Barcelona'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Diseño para teléfono horizontal (paisaje)
                // Muestra la temperatura y ciudad a un lado, y el ícono del otro lado
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Columna 1: Temperatura y Ciudad
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    formattedTemp,
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    weather.city,
                                    style: const TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Columna 2: Ícono y Condición
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(icon, size: 80, color: Colors.blue),
                                  const SizedBox(height: 16),
                                  Text('Condición: ${weather.condition}', style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Botón en 2 columnas
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SearchScreen()),
                            );
                          },
                          child: const Text('Buscar Ciudades'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Botones de prueba para pantalla horizontal
                      // Igual que los botones de arriba, pero organizados para que quepan en pantalla ancha
                      Row(
                        children: [
                          // Botón 1: aumenta la temperatura
                          // Expanded hace que el botón ocupe todo el espacio disponible
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                weatherProvider.changeTemperature(weather.temp + 1);
                              },
                              child: const Text('Temp +1'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Botón 2: cambia a Barcelona
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                weatherProvider.changeCity('Barcelona');
                              },
                              child: const Text('Cambiar a Barcelona'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}