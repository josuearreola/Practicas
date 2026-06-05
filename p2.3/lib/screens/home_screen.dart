import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).loadWeather('Madrid');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Actual'),
        centerTitle: true,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (weatherProvider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${weatherProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final weather = weatherProvider.weather;
          if (weather == null) {
            return const Center(
              child: Text('No data available'),
            );
          }

          final formattedTemp = formatTemperature(
            weather.temperature,
            weatherProvider.temperatureUnit,
          );

          final icon = getWeatherIcon(weather.condition);

          return OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                // Diseño vertical (portrait)
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
                        Text(
                          weather.city,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 32),
                        Icon(
                          icon,
                          size: 120,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 32),
                        Text('Condición: ${weather.condition}'),
                        const SizedBox(height: 16),
                        Text('Humedad: ${weather.humidity}%'),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                          child: const Text('Buscar Ciudades'),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                weatherProvider.changeTemperature(
                                  weather.temperature + 1,
                                );
                              },
                              child: const Text('Temp +1'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                weatherProvider.changeCity('Barcelona');
                              },
                              child: const Text('Cambiar a Barcelona'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                weatherProvider.toggleTemperatureUnit();
                              },
                              child: const Text('°C ↔ °F'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Diseño horizontal (landscape)
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icon,
                                    size: 80,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Condición: ${weather.condition}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Humedad: ${weather.humidity}%',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          },
                          child: const Text('Buscar Ciudades'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                weatherProvider.changeTemperature(
                                  weather.temperature + 1,
                                );
                              },
                              child: const Text('Temp +1'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                weatherProvider.changeCity('Barcelona');
                              },
                              child: const Text('Cambiar a Barcelona'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                weatherProvider.toggleTemperatureUnit();
                              },
                              child: const Text('°C ↔ °F'),
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