import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  static final Guid targetCharacteristicUuid =
      Guid('0000ffe1-0000-1000-8000-00805f9b34fb');

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
      onError: controller.addError,
    );

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    FlutterBluePlus.startScan(
      timeout: timeout,
      oneByOne: true,
    ).whenComplete(() {
      if (!controller.isClosed) {
        controller.close();
      }
    });

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

  Future<List<int>> readCharacteristic({Guid? uuid}) async {
    if (_connectedDevice == null) {
      throw Exception('No hay dispositivo conectado');
    }

    final services = await _connectedDevice!.discoverServices();
    final characteristicUuid = uuid ?? targetCharacteristicUuid;
    final characteristic = services
        .expand((service) => service.characteristics)
        .firstWhere(
          (characteristic) => characteristic.uuid == characteristicUuid,
          orElse: () => throw Exception('Caracteristica BLE no encontrada'),
        );

    return characteristic.read();
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
