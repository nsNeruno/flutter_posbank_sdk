import 'package:flutter_posbank_sdk/src/devices/device_context.dart';
import 'package:flutter_posbank_sdk/src/utils.dart';

import 'constants.dart';

export 'devices/bluetooth_device.dart';
export 'devices/device_context.dart';
export 'devices/serial_port_device.dart';
export 'devices/usb_device.dart';

class PrinterDevice {

  const PrinterDevice(
    this._deviceType,
    this.deviceName,
    this.manufacturer,
    this.productID,
    this.model,
    this.modelSimpleName,
    this.deviceContext,
  );

  PrinterDevice.fromMap(Map<String, dynamic> data,)
      : _deviceType = data['deviceType'],
        deviceName = data['deviceName'],
        manufacturer = data['manufacturer'],
        productID = data['productID'],
        model = data['model'],
        modelSimpleName = data['modelSimpleName'],
        deviceContext = PrinterDeviceContext.fromMap(
          asMap(data['deviceContext'],) ?? {},
        );

  Map<String, dynamic> toMap() => {
    'deviceType': _deviceType,
    'deviceName': deviceName,
    'manufacturer': manufacturer,
    'productID': productID,
    'model': model,
    'modelSimpleName': modelSimpleName,
    'deviceContext': deviceContext?.toMap(),
  };

  final int _deviceType;
  final String deviceName;
  final String manufacturer;
  final String productID;
  final String model;
  final String modelSimpleName;
  final PrinterDeviceContext? deviceContext;

  PrinterType get deviceType {
    final lookup = Map.fromEntries(
      PrinterType.values.map(
        (e) => MapEntry(e.value, e,),
      ),
    );
    return lookup[_deviceType] ?? PrinterType.unknown;
  }

  @override
  bool operator ==(Object other) {
    if (other is PrinterDevice) {
      return _deviceType == other._deviceType &&
          deviceName == other.deviceName &&
          manufacturer == other.manufacturer &&
          productID == other.productID &&
          model == other.model &&
          modelSimpleName == other.modelSimpleName;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(
    _deviceType, deviceName, manufacturer, productID, model, modelSimpleName,
  );
}