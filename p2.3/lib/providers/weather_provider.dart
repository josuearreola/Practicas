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

  // Cargar datos (simulado)
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
      _weather = Weather(
        city: _weather!.city,
        temperature: newTemp,
        condition: _weather!.condition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  Future<void> readWearableData(String deviceId) async {
    _lastDeviceId = deviceId;
    _isLoading = true;
    _bleLoading = true;
    _bleStatus = 'Conectando BLE...';
    _errorMessage = null;
    notifyListeners();

    try {
      await _bleService.connect(deviceId);
      final bytes = await _bleService.readCharacteristic();
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

  void _applyWearableData(List<int> bytes) {
    _bleValue = bytes;
    final temperature =
        bytes.isNotEmpty ? bytes.first : _weather?.temperature ?? 0;

    _weather = Weather(
      city: _weather?.city ?? 'Wearable',
      temperature: temperature,
      condition: _weather?.condition ?? 'connected',
      humidity: _weather?.humidity ?? 0,
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
      _weather = Weather(
        city: _weather!.city,
        temperature: newTemp,
        condition: _weather!.condition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  void changeCity(String newCity) {
    if (_weather != null) {
      _weather = Weather(
        city: newCity,
        temperature: _weather!.temperature,
        condition: _weather!.condition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  void changeCondition(String newCondition) {
    if (_weather != null) {
      _weather = Weather(
        city: _weather!.city,
        temperature: _weather!.temperature,
        condition: newCondition,
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
