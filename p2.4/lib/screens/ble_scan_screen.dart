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
  final List<ScanResult> _devices = [];
  StreamSubscription<ScanResult>? _scanSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    if (_scanning) return;

    setState(() {
      _scanning = true;
      _devices.clear();
    });

    await _scanSubscription?.cancel();
    await _isScanningSubscription?.cancel();

    _scanSubscription = _bleService.scanForDevices().listen(
      (result) {
        if (!mounted) return;
        if (_devices.any(
          (item) => item.device.remoteId == result.device.remoteId,
        )) {
          return;
        }
        setState(() {
          _devices.add(result);
        });
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _scanning = false;
          });
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            _scanning = false;
          });
        }
      },
    );

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning && mounted) {
        setState(() {
          _scanning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _isScanningSubscription?.cancel();
    _bleService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar dispositivos BLE')),
      body: Column(
        children: [
          if (_scanning) const LinearProgressIndicator(),
          Expanded(
            child: _devices.isEmpty
                ? const Center(child: Text('No se encontraron dispositivos'))
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final result = _devices[index];
                      final deviceName = result.device.platformName.isNotEmpty
                          ? result.device.platformName
                          : result.device.remoteId.str;

                      return ListTile(
                        title: Text(deviceName),
                        subtitle: Text(result.device.remoteId.str),
                        trailing: const Icon(Icons.bluetooth),
                        onTap: () async {
                          await weatherProvider.readWearableData(
                            result.device.remoteId.str,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _scanning ? null : _startScan,
                    child: const Text('Escanear otra vez'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Text(weatherProvider.bleStatus),
                if (weatherProvider.bleLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
