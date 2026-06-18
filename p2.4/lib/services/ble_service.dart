import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  // Las 2 variables cortas requeridas basadas en tus capturas
  static const String serviceUuid = "0x1809";
  static const String temperatureCharacteristicUuid = "0x2222";

  BluetoothDevice? _connectedDevice;

  Stream<ScanResult> scanForDevices({
    Duration timeout = const Duration(seconds: 5),
  }) {
    final controller = StreamController<ScanResult>();

    final subscription = FlutterBluePlus.scanResults.listen(
      (results) {
        for (final result in results) {
          controller.add(result);
        }
      },
      onError: (error) {
        if (!controller.isClosed) controller.addError(error);
      },
    );

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    // Try-Catch para evitar el PlatformException si el Bluetooth está apagado
    try {
      FlutterBluePlus.startScan(
        timeout: timeout,
        oneByOne: true,
      ).whenComplete(() {
        if (!controller.isClosed) {
          controller.close();
        }
      });
    } catch (e) {
      print("Error al iniciar escaneo (Bluetooth apagado): $e");
      if (!controller.isClosed) {
        controller.addError("Asegúrate de encender el Bluetooth y la Ubicación.");
        controller.close();
      }
    }

    return controller.stream;
  }

  Future<void> stopScan() {
    return FlutterBluePlus.stopScan();
  }

  Future<void> connect(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    _connectedDevice = device;
    await device.connect(
      timeout: const Duration(seconds: 10),
      autoConnect: false,
    );
  }

  // Descubre servicios y lee la característica usando los UUIDs cortos sin "0x"
  Future<List<int>> readCharacteristic() async {
    if (_connectedDevice == null) {
      throw Exception('No hay dispositivo conectado');
    }

    // Forzar el descubrimiento de servicios GATT
    final services = await _connectedDevice!.discoverServices();
    
    // Limpiar el prefijo "0x" para buscar coincidencia parcial en el UUID largo de Android/iOS
    final targetService = serviceUuid.replaceAll("0x", "").toLowerCase();
    final targetChar = temperatureCharacteristicUuid.replaceAll("0x", "").toLowerCase();

    // 1. Buscar el servicio correspondiente (0x1809)
    final service = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase().contains(targetService),
      orElse: () => throw Exception('Servicio de Salud (0x1809) no encontrado en el dispositivo'),
    );

    // 2. Buscar la característica correspondiente (0x2222)
    final characteristic = service.characteristics.firstWhere(
      (c) => c.uuid.toString().toLowerCase().contains(targetChar),
      orElse: () => throw Exception('Característica de temperatura (0x2222) no encontrada'),
    );

    // Leer el valor del Hexadecimal convertido a bytes
    return await characteristic.read();
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
  }

  Stream<BluetoothConnectionState>? watchConnection() {
    if (_connectedDevice == null) return null;
    return _connectedDevice!.connectionState;
  }
}