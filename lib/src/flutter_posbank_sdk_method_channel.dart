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
  Future<void> startDiscovery() async {
    if (_isDiscoveringPrinters) {
      return;
    }
    await methodChannel.invokeMethod('startDiscovery',);
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
      int? what = msg['what'];
      int? arg1 = msg['arg1'];
      int? arg2 = msg['arg2'];
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
    }
  }

  bool _isDiscoveringPrinters = false;
  bool get isDiscoveringPrinters => _isDiscoveringPrinters;

  PrinterStatus? _lastPrinterStatus;
  Completer<void>? _discoveryCompleter;
  Completer<PrinterStatus>? _getStatusCompleter;
}
