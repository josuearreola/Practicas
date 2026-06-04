import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider: esto es como un "distribuidor" de información
    // Toma el WeatherProvider y lo pone disponible en toda la aplicación
    // Todos los pantallas pueden acceder a los datos del clima desde aquí
    return MultiProvider(
      providers: [
        // Registramos el WeatherProvider para que esté disponible globalmente
        // Esto significa que cualquier widget puede usarlo sin importar dónde esté
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Climate App',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}