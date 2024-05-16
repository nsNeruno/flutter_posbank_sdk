import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'flutter_posbank_sdk_platform_interface.dart';
import 'printer_device.dart';

/// An implementation of [FlutterPosbankSdkPlatform] that uses method channels.
class MethodChannelFlutterPosbankSdk extends FlutterPosbankSdkPlatform {

  MethodChannelFlutterPosbankSdk() {
    methodChannel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case 'onPrinterMessage':
            return _onPrinterMessage(call.arguments,);
        }
        return null;
      },
    );
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_posbank_sdk');

  @override
  Future<void> startDiscovery({
    Set<PrinterType> printerTypes = const {
      PrinterType.bluetooth,
      PrinterType.network,
      PrinterType.usb,
      PrinterType.serial,
    },
  }) async {
    if (_isDiscoveringPrinters) {
      return;
    }

    int options = 0;
    if (printerTypes.isEmpty ||
        (printerTypes.length == 1 && printerTypes.contains(PrinterType.unknown,))
    ) {
      const defaultOptions = <PrinterType>{
        PrinterType.bluetooth,
        PrinterType.network,
        PrinterType.usb,
        PrinterType.serial,
      };

      options = defaultOptions.fold(
        0, (_, type,) => _ | type.value,
      );
    } else {
      options = printerTypes.fold(
        0,
        (_, type,) => _ | type.value,
      );
    }
    
    await methodChannel.invokeMethod(
      'startDiscovery',
      {
        'options': options,
      },
    );
    final completer = Completer<void>();
    _discoveryCompleter = completer;
    return completer.future;
  }

  @override
  Future<List<PrinterDevice>?> getDevicesList() async {
    final mappedData = await methodChannel.invokeMapMethod('getDevicesList',);
    return mappedData?.values.where(
      (e) => e != null,
    ).map(
      (e) => PrinterDevice.fromMap(e,),
    ).toList();
  }

  @override
  Future<void> setSerialPorts(List<String> ports,) async {
    await methodChannel.invokeMethod(
      'setSerialPorts',
      {
        'ports': ports,
      },
    );
  }
  
  @override
  Future<List<SerialPortDevice>> getSerialPortDeviceList() async {
    final mappedData = await methodChannel.invokeMapMethod('getSerialPortDeviceList',);
    final serialDevices = mappedData?.values.where(
      (e) => e != null,
    ).map(
      (e) => SerialPortDevice.fromMap(e,),
    ).toList() ?? [];

    if (serialDevices.isNotEmpty) {
      _serialDevices.clear();
      _serialDevices.addAll(serialDevices,);
    }

    return serialDevices;
  }

  @override
  Future<PrinterDevice?> getDevice(String deviceName,) async {
    final result = await methodChannel.invokeMapMethod(
      'getDevice',
      {
        'deviceName': deviceName,
      },
    ).then((_) => _?.cast<String, dynamic>(),);
    if (result != null) {
      return PrinterDevice.fromMap(result,);
    }
    return null;
  }
  
  @override
  Future<void> connectToDevice(PrinterDevice device,) async {
    await methodChannel.invokeMapMethod(
      'connectDevice',
      {
        'deviceName': device.deviceName,
        'initialize': true,
      },
    );
  }

  @override
  Future<void> initializePrinter() async {
    await methodChannel.invokeMethod('initializePrinter',);
  }

  @override
  Future<void> disconnectPrinter() async {
    await methodChannel.invokeMethod('disconnectPrinter',);
  }

  @override
  Future<void> shutdownPrinter() async {
    await methodChannel.invokeMethod('shutdownPrinter',);
  }

  @override
  Future<PrinterStatus?> getPrinterStatus() async {
    if (_getStatusCompleter != null && !_getStatusCompleter!.isCompleted) {
      return _lastPrinterStatus;
    }
    final result = await methodChannel.invokeMethod('method',);
    if (result == null) {
      final completer = Completer<PrinterStatus>();
      _getStatusCompleter = completer;
      return completer.future;
    }
    return null;
  }

  @override
  Future<void> lineFeed(int lines,) async {
    await methodChannel.invokeMethod('lineFeed', { 'lines': lines, },);
  }

  @override
  Future<void> printText({
    required String text,
    PrinterAlignment textAlignment = PrinterAlignment.center,
    Set<PrinterTextAttribute> textAttribute = const {
      PrinterTextAttribute.fontA,
    },
    PrinterCharSizeVertical charSizeVertical = PrinterCharSizeVertical.vertical1,
    PrinterCharSizeHorizontal charSizeHorizontal = PrinterCharSizeHorizontal.horizontal1,
  }) async {
    await methodChannel.invokeMethod(
      'printText',
      {
        'text': text,
        'textAlignment': textAlignment.index,
        'textAttribute': textAttribute.fold(
          0x00,
          (_, attr,) => _ | attr.value,
        ),
        'textSize': charSizeVertical.index | charSizeHorizontal.value,
      },
    );
  }

  @override
  Future<void> print1dBarcode({
    required String data,
    required PrinterBarCodeSystem barCodeSystem,
    PrinterAlignment alignment = PrinterAlignment.center,
    required int width,
    required int height,
    PrinterHRICharacter charPosition = PrinterHRICharacter.belowBarCode,
  }) async {
    await methodChannel.invokeMethod(
      'print1dBarcode',
      {
        'data': data,
        'barCodeSystem': barCodeSystem.value,
        'alignment': alignment.index,
        'width': width,
        'height': height,
        'charPosition': charPosition.index,
      },
    );
  }

  @override
  Future<void> kickOutDrawer() async {
    try {
      await methodChannel.invokeMethod(
        'kickOutDrawer',
      );
    } catch (_) {
      try {
        await methodChannel.invokeMethod(
          'kickOutDrawer',
          { 'usePin5': true, },
        );
      } catch (_) {

      }
    }
  }

  @override
  Future<void> printSelfTest() async {
    await methodChannel.invokeMethod('printSelfTest',);
  }

  Future<dynamic> _onPrinterMessage(dynamic arguments,) async {
    if (arguments is Map) {
      final msg = arguments.cast<String, dynamic>();
      final int? what = msg['what'];
      final int? arg1 = msg['arg1'];
      final int? arg2 = msg['arg2'];

      final usb = msg['usb'];
      final serial = msg['serial'];
      final bluetooth = msg['bluetooth'];

      switch (what) {
        case PrinterMessage.discoveryStarted:
          _isDiscoveringPrinters = true;
          break;
        case PrinterMessage.discoveryFinished:
          _discoveryCompleter?.complete();
          _isDiscoveringPrinters = false;
          break;
        case PrinterMessage.dataReceived:
          switch (arg1) {
            case PrinterProcess.getStatus:
              for (final status in PrinterStatus.values) {
                if (arg2 == status.value) {
                  _getStatusCompleter?.complete(status,);
                  _lastPrinterStatus = status;
                  _getStatusCompleter = null;
                  break;
                }
              }
              break;
          }
          break;
      }

      if (usb is Map<String, dynamic>) {
        final usbDevice = UsbDevice.fromMap(usb,);
        if (_usbDevices.indexWhere((device) => device.deviceId == usbDevice.deviceId,) < 0) {
          _usbDevices.add(usbDevice,);
        }
      }

      if (serial is Map<String, dynamic>) {
        final serialDevice = SerialPortDevice.fromMap(serial,);
        if (_serialDevices.indexWhere((device) => device.deviceID == serialDevice.deviceID,) < 0) {
          _serialDevices.add(serialDevice,);
        }
      }

      if (bluetooth is Map<String, dynamic>) {
        final btDevice = BluetoothDevice.fromMap(bluetooth,);
        final uuids = btDevice.uuids.map((e) => e.toString(),);
        if (!_bluetoothDevices.any(
            (device) => device.uuids.any((uuid) => uuids.contains(uuid.toString(),),),
        )) {
          _bluetoothDevices.add(btDevice,);
        }
      }
    }
  }

  bool _isDiscoveringPrinters = false;
  bool get isDiscoveringPrinters => _isDiscoveringPrinters;

  PrinterStatus? _lastPrinterStatus;
  Completer<void>? _discoveryCompleter;
  Completer<PrinterStatus>? _getStatusCompleter;

  final _usbDevices = <UsbDevice>[];
  final _serialDevices = <SerialPortDevice>[];
  final _bluetoothDevices = <BluetoothDevice>[];

  @override
  List<UsbDevice> get usbDevices => _usbDevices.toList(growable: false,);

  @override
  List<SerialPortDevice> get serialPortDevices => _serialDevices.toList(
    growable: false,
  );

  @override
  List<BluetoothDevice> get bluetoothDevices => _bluetoothDevices.toList(
    growable: false,
  );
}
