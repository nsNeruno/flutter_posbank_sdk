import 'constants.dart';

class PrinterDevice {

  const PrinterDevice(
    this._deviceType,
    this.deviceName,
    this.manufacturer,
    this.productID,
    this.model,
    this.modelSimpleName,
  );

  PrinterDevice.fromMap(Map<String, dynamic> data,)
      : _deviceType = data['deviceType'],
        deviceName = data['deviceName'],
        manufacturer = data['manufacturer'],
        productID = data['productID'],
        model = data['model'],
        modelSimpleName = data['modelSimpleName'];

  final int _deviceType;
  final String deviceName;
  final String manufacturer;
  final String productID;
  final String model;
  final String modelSimpleName;

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