import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_posbank_sdk/flutter_posbank_sdk.dart';
import 'package:flutter_posbank_sdk/src/flutter_posbank_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPosbankSdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterPosbankSdkPlatform {

  @override
  Future<void> startDiscovery({
    Set<PrinterType> printerTypes = const {
      PrinterType.bluetooth,
      PrinterType.network,
      PrinterType.usb,
      PrinterType.serial,
    },
  }) {
    // TODO: implement startDiscovery
    throw UnimplementedError();
  }

  @override
  Future<List<PrinterDevice>?> getDevicesList() {
    // TODO: implement getDevicesList
    throw UnimplementedError();
  }

  @override
  Future<void> setSerialPorts(List<String> ports,) {
    throw UnimplementedError();
  }

  @override
  Future<List<SerialPortDevice>> getSerialPortDeviceList() {
    // TODO: implement getSerialPortDeviceList
    throw UnimplementedError();
  }

  @override
  Future<PrinterDevice?> getDevice(String deviceName) {
    // TODO: implement getDevice
    throw UnimplementedError();
  }

  @override
  Future<void> connectToDevice(PrinterDevice device) {
    // TODO: implement connectToDevice
    throw UnimplementedError();
  }

  @override
  Future<void> initializePrinter() {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnectPrinter() {
    throw UnimplementedError();
  }

  @override
  Future<void> shutdownPrinter() {
    throw UnimplementedError();
  }

  @override
  Future<PrinterStatus?> getPrinterStatus() {
    throw UnimplementedError();
  }

  @override
  Future<void> lineFeed(int lines,) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }

  @override
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

  @override
  Future<void> kickOutDrawer() {
    throw UnimplementedError();
  }

  @override
  Future<void> printSelfTest() {
    throw UnimplementedError();
  }

  @override
  List<UsbDevice> get usbDevices => throw UnimplementedError();

  @override
  List<BluetoothDevice> get bluetoothDevices => throw UnimplementedError();

  @override
  List<SerialPortDevice> get serialPortDevices => throw UnimplementedError();
}

void main() {
  final FlutterPosbankSdkPlatform initialPlatform = FlutterPosbankSdkPlatform.instance;

  test('$MethodChannelFlutterPosbankSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPosbankSdk>());
  });

  // test('getPlatformVersion', () async {
  //   FlutterPosbankSdk flutterPosbankSdkPlugin = FlutterPosbankSdk();
  //   MockFlutterPosbankSdkPlatform fakePlatform = MockFlutterPosbankSdkPlatform();
  //   FlutterPosbankSdkPlatform.instance = fakePlatform;
  //
  // });
}
