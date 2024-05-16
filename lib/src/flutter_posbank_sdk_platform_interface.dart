import 'package:flutter_posbank_sdk/src/printer_device.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'constants.dart';
import 'flutter_posbank_sdk_method_channel.dart';

abstract class FlutterPosbankSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterPosbankSdkPlatform.
  FlutterPosbankSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterPosbankSdkPlatform _instance = MethodChannelFlutterPosbankSdk();

  /// The default instance of [FlutterPosbankSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterPosbankSdk].
  static FlutterPosbankSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterPosbankSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterPosbankSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> startDiscovery({
    Set<PrinterType> printerTypes = const {
      PrinterType.bluetooth,
      PrinterType.network,
      PrinterType.usb,
      PrinterType.serial,
    },
  }) {
    throw UnimplementedError();
  }

  Future<List<PrinterDevice>?> getDevicesList() {
    throw UnimplementedError();
  }

  Future<void> setSerialPorts(List<String> ports,) {
    throw UnimplementedError();
  }

  Future<List<SerialPortDevice>> getSerialPortDeviceList() {
    throw UnimplementedError();
  }

  Future<PrinterDevice?> getDevice(String deviceName,) {
    throw UnimplementedError();
  }

  Future<void> connectToDevice(PrinterDevice device,) {
    throw UnimplementedError();
  }

  Future<void> initializePrinter() {
    throw UnimplementedError();
  }

  Future<void> disconnectPrinter() {
    throw UnimplementedError();
  }

  Future<void> shutdownPrinter() {
    throw UnimplementedError();
  }

  Future<PrinterStatus?> getPrinterStatus() {
    throw UnimplementedError();
  }

  Future<void> lineFeed(int lines,) {
    throw UnimplementedError();
  }

  Future<void> printText({
    required String text,
    PrinterAlignment textAlignment = PrinterAlignment.center,
    Set<PrinterTextAttribute> textAttribute = const {
      PrinterTextAttribute.fontA,
    },
    PrinterCharSizeVertical charSizeVertical = PrinterCharSizeVertical.vertical1,
    PrinterCharSizeHorizontal charSizeHorizontal = PrinterCharSizeHorizontal.horizontal1,
  }) {
    throw UnimplementedError();
  }

  Future<void> print1dBarcode({
    required String data,
    required PrinterBarCodeSystem barCodeSystem,
    PrinterAlignment alignment = PrinterAlignment.center,
    required int width,
    required int height,
    PrinterHRICharacter charPosition = PrinterHRICharacter.belowBarCode,
  }) {
    throw UnimplementedError();
  }

  Future<void> kickOutDrawer() {
    throw UnimplementedError();
  }

  Future<void> printSelfTest() {
    throw UnimplementedError();
  }

  List<UsbDevice> get usbDevices => throw UnimplementedError();
  List<SerialPortDevice> get serialPortDevices => throw UnimplementedError();
  List<BluetoothDevice> get bluetoothDevices => throw UnimplementedError();
}
