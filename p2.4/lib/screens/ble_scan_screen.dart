import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../services/ble_service.dart';

class BLEScanScreen extends StatefulWidget {
  const BLEScanScreen({super.key});

  @override
  State<BLEScanScreen> createState() => _BLEScanScreenState();
}

class _BLEScanScreenState extends State<BLEScanScreen> {
  final BLEService _bleService = BLEService();
  bool _isScanning = false;
  StreamSubscription<bool>? _scanningSubscription;

  @override
  void initState() {
    super.initState();
    // Monitorear el estado del escaneo para actualizar los indicadores visuales
    _scanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      if (mounted) {
        setState(() {
          _isScanning = scanning;
        });
      }
    });
    
    // Iniciar escaneo automático al entrar a la pantalla
    _startAutomaticScan();
  }

  void _startAutomaticScan() {
    // Escaneo continuo de 30 segundos para dar tiempo de detectar todo en tiempo real
    _bleService.scanForDevices(timeout: const Duration(seconds: 30));
  }

  @override
  void dispose() {
    _scanningSubscription?.cancel();
    _bleService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos BLE Disponibles'),
        actions: [
          if (_isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                ),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          if (_isScanning) const LinearProgressIndicator(),
          
          // LISTA EN TIEMPO REAL: Escucha globalmente todos los cambios del adaptador BLE
          Expanded(
            child: StreamBuilder<List<ScanResult>>(
              stream: FlutterBluePlus.scanResults,
              initialData: const [],
              builder: (context, snapshot) {
                final results = snapshot.data ?? [];

                if (results.isEmpty) {
                  return const Center(
                    child: Text(
                      'Buscando wearables...\nAsegúrate de que LightBlue esté transmitiendo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    
                    // Obtener nombre del dispositivo o alternar al ID remoto si está vacío
                    final deviceName = result.device.platformName.isNotEmpty
                        ? result.device.platformName
                        : (result.advertisementData.advName.isNotEmpty 
                            ? result.advertisementData.advName 
                            : "Dispositivo no identificado");

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: deviceName.contains("Dispositivo") ? Colors.grey.shade200 : Colors.blue.shade100,
                        child: Icon(
                          Icons.bluetooth, 
                          color: deviceName.contains("Dispositivo") ? Colors.grey : Colors.blue
                        ),
                      ),
                      title: Text(
                        deviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(result.device.remoteId.str),
                      trailing: Text(
                        "${result.rssi} dBm", // Muestra la potencia de la señal en vivo
                        style: TextStyle(
                          color: result.rssi > -70 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        // Detener escaneo inmediatamente al seleccionar para asegurar la conexión
                        await _bleService.stopScan();
                        
                        await weatherProvider.readWearableData(
                          result.device.remoteId.str,
                        );
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Sección de control inferior sin botones obligatorios estorbosos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Estado: ${weatherProvider.bleStatus}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: weatherProvider.bleConnected ? Colors.green : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startAutomaticScan,
                  icon: const Icon(Icons.refresh),
                  label: Text(_isScanning ? 'Escaneando automáticamente...' : 'Forzar Re-escaneo'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}