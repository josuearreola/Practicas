import 'package:flutter/material.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima Actual'), centerTitle: true),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            // Layout Portrait
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '24°C',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Santiago de Querétaro', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 32),
                    const Icon(Icons.cloud, size: 120, color: Colors.blue),
                    const SizedBox(height: 32),
                    const Text('Humedad: 65% | Viento: 12 km/h'),
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
                  ],
                ),
              ),
            );
          } else {
            // Layout Landscape
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
                              const Text(
                                '24°C',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Santiago de Querétaro',
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Columna 2: Humedad y Viento
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud, size: 80, color: Colors.blue),
                              const SizedBox(height: 16),
                              const Text('Humedad: 65%', style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              const Text('Viento: 12 km/h', style: TextStyle(fontSize: 16)),
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
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
