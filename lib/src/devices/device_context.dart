import 'package:flutter_posbank_sdk/src/devices/bluetooth_device.dart';
import 'package:flutter_posbank_sdk/src/devices/serial_port_device.dart';
import 'package:flutter_posbank_sdk/src/devices/usb_device.dart';
import 'package:flutter_posbank_sdk/src/serializable.dart';

abstract class PrinterDeviceContext extends Serializable {

  const PrinterDeviceContext({
    this.name,
  });

  static PrinterDeviceContext? fromMap(Map<String, dynamic> data,) {
    if (data.containsKey('interfaces',)) {
      return UsbDevice.fromMap(data,);
    }
    if (data.containsKey('baudrate',)) {
      return SerialPortDevice.fromMap(data,);
    }
    if (data.containsKey('bluetoothClass',)) {
      return BluetoothDevice.fromMap(data,);
    }
    return null;
  }

  final String? name;

  @override
  Map<String, dynamic> toMap() => { 'name': name, };
}