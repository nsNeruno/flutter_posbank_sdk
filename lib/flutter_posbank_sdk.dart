import 'src/constants.dart';
import 'src/flutter_posbank_sdk_platform_interface.dart';
import 'src/printer_device.dart';

export 'src/constants.dart';
export 'src/flutter_posbank_sdk_platform_interface.dart';
export 'src/printer_device.dart';

class FlutterPosbankSdk {

  FlutterPosbankSdk._();

  factory FlutterPosbankSdk() => _instance;

  static final FlutterPosbankSdk _instance = FlutterPosbankSdk._();

  Future<List<PrinterDevice>?> getPrinterDevices() async {
    await FlutterPosbankSdkPlatform.instance.startDiscovery();
    return FlutterPosbankSdkPlatform.instance.getDevicesList();
  }

  Future<void> connectToDevice(PrinterDevice device,) async {
    await FlutterPosbankSdkPlatform.instance.connectToDevice(device,);
  }

  Future<void> disconnectPrinter() async {
    await FlutterPosbankSdkPlatform.instance.disconnectPrinter();
  }

  Future<void> printText({
    required String text,
    PrinterAlignment textAlignment = PrinterAlignment.center,
    Set<PrinterTextAttribute> textAttribute = const {
      PrinterTextAttribute.fontA,
    },
    PrinterCharSizeVertical charSizeVertical = PrinterCharSizeVertical.vertical1,
    PrinterCharSizeHorizontal charSizeHorizontal = PrinterCharSizeHorizontal.horizontal1,
  }) async {
    await FlutterPosbankSdkPlatform.instance.printText(
      text: text,
      textAlignment: textAlignment,
      textAttribute: textAttribute,
      charSizeVertical: charSizeVertical,
      charSizeHorizontal: charSizeHorizontal,
    );
  }

  Future<void> printSelfTest() async {
    await FlutterPosbankSdkPlatform.instance.printSelfTest();
  }

  Future<void> cutPaper({int? feeds,}) async {
    await FlutterPosbankSdkPlatform.instance.cutPaper(feeds: feeds,);
  }

  set debugMode(bool value) => FlutterPosbankSdkPlatform.instance.debugMode = value;
  bool get debugMode => FlutterPosbankSdkPlatform.instance.debugMode;
}
