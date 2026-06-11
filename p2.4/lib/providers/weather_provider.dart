import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/weather.dart';
import '../services/ble_service.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  int _tempUnit = 0; // 0 = Celsius, 1 = Fahrenheit
  final BLEService _bleService = BLEService();
  bool _bleLoading = false;
  bool _bleConnected = false;
  String _bleStatus = 'Sin conexion BLE';
  List<int> _bleValue = [];
  String? _lastDeviceId;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  bool _reconnecting = false;

  // Getters
  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _tempUnit == 0 ? '°C' : '°F';
  bool get bleLoading => _bleLoading;
  bool get bleConnected => _bleConnected;
  String get bleStatus => _bleStatus;
  List<int> get bleValue => _bleValue;

  Future<void> loadWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _weather = Weather(
        city: city,
        temperature: 24,
        condition: 'cloudy',
        humidity: 65,
      );
    } catch (e) {
      _errorMessage = 'Error loading weather: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTemperatureUnit() {
    if (_weather != null) {
      int newTemp;
      if (_tempUnit == 0) {
        newTemp = ((_weather!.temperature * 9 / 5) + 32).toInt();
      } else {
        newTemp = ((_weather!.temperature - 32) * 5 / 9).toInt();
      }

      _tempUnit = _tempUnit == 0 ? 1 : 0;
      _weather = _weather!.copyWith(temperature: newTemp);
      notifyListeners();
    }
  }

  // Método que llama la pantalla ble_scan_screen al presionar sobre tu Dispositivo 2
  Future<void> readWearableData(String deviceId) async {
    _lastDeviceId = deviceId;
    _isLoading = true;
    _bleLoading = true;
    _bleStatus = 'Conectando BLE...';
    _errorMessage = null;
    notifyListeners();

    try {
      await _bleService.connect(deviceId);
      
      // Llama al servicio modificado con mapeo corto de UUIDs
      final bytes = await _bleService.readCharacteristic();
      
      // Procesa y aplica las validaciones requeridas
      _applyWearableData(bytes);
      
      _bleConnected = true;
      _bleStatus = 'Conectado BLE';
      _listenForDisconnection();
    } catch (e) {
      _bleConnected = false;
      _bleStatus = 'Sin conexion BLE';
      _errorMessage = 'Error BLE: $e';
    } finally {
      _isLoading = false;
      _bleLoading = false;
      notifyListeners();
    }
  }

  // Procesa el Hexadecimal / Bytes entrante de forma segura
  void _applyWearableData(List<int> bytes) {
    _bleValue = bytes;
    
    // Por defecto toma la temperatura actual si viene vacío
    int targetTemperature = _weather?.temperature ?? 0;

    if (bytes.isNotEmpty) {
      // LightBlue manda los bytes de tu valor Hexadecimal. El primer byte es bytes.first
      int parsedValue = bytes.first;

      // Criterio de seguridad obligatorio: Validar rango estricto (-60 a 60)
      if (parsedValue >= -60 && parsedValue <= 60) {
        targetTemperature = parsedValue;
      } else {
        _errorMessage = "Seguridad BLE: Datos fuera de rango (-60 a 60).";
        print("Dato descartado: $parsedValue");
      }
    }

    _weather = Weather(
      city: _weather?.city ?? 'Wearable',
      temperature: targetTemperature,
      condition: 'sunny', // Forzar a 'sunny' o mantener _weather?.condition
      humidity: _weather?.humidity ?? 50,
    );
  }

  void _listenForDisconnection() {
    _connectionSubscription?.cancel();
    final connectionStream = _bleService.watchConnection();
    if (connectionStream == null) return;

    _connectionSubscription = connectionStream.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _bleConnected = false;
        _bleStatus = 'Sin conexion BLE';
        notifyListeners();
        _attemptReconnection();
      }
    });
  }

  Future<void> _attemptReconnection() async {
    if (_lastDeviceId == null || _reconnecting) return;

    _reconnecting = true;
    _bleStatus = 'Reconectando BLE...';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      await _bleService.connect(_lastDeviceId!);
      final bytes = await _bleService.readCharacteristic();
      _applyWearableData(bytes);
      _bleConnected = true;
      _bleStatus = 'Conectado BLE';
      _listenForDisconnection();
    } catch (_) {
      _bleConnected = false;
      _bleStatus = 'Sin conexion BLE';
    } finally {
      _reconnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnectWearable() async {
    _connectionSubscription?.cancel();
    _lastDeviceId = null;
    await _bleService.disconnect();
    _bleConnected = false;
    _bleStatus = 'Sin conexion BLE';
    notifyListeners();
  }

  void changeTemperature(int newTemp) {
    if (_weather != null) {
      _weather = _weather!.copyWith(temperature: newTemp);
      notifyListeners();
    }
  }

  void changeCity(String newCity) {
    if (_weather != null) {
      _weather = _weather!.copyWith(city: newCity);
      notifyListeners();
    }
  }

  void changeCondition(String newCondition) {
    if (_weather != null) {
      _weather = _weather!.copyWith(condition: newCondition);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}