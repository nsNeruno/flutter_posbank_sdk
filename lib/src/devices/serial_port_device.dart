import 'package:flutter_posbank_sdk/src/devices/device_context.dart';
import 'package:flutter_posbank_sdk/src/utils.dart';

class SerialPortDevice extends PrinterDeviceContext {

  SerialPortDevice.fromMap(Map<String, dynamic> data,)
      : windowName = data['windowName'],
        description = data['description'],
        deviceID = data['deviceID'],
        baudrate = data['baudrate'],
        dataBits = data['dataBits'],
        stopBits = data['stopBits'],
        parityBits = _parseParity(data['parityBits'],),
        flowControl = _parseFlowControl(data['flowControl'],),
        timeout = asMapAndCast(
          data['timeout'], (data) => SerialPortTimeout._fromMap(data,),
        ),
        super(name: data['deviceName'] ?? '',);

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'windowName': windowName,
    'description': description,
    'deviceID': deviceID,
    'baudrate': baudrate,
    'dataBits': dataBits,
    'stopBits': stopBits,
    'parityBits': parityBits.index,
    'flowControl': flowControl.index,
    'timeout': timeout?.toMap(),
  };

  final String? windowName;
  final String? description;
  final String deviceID;
  final int baudrate;
  final int? dataBits;
  final int? stopBits;
  final SerialPortParity parityBits;
  final SerialPortControl flowControl;
  final SerialPortTimeout? timeout;

  static SerialPortParity _parseParity(dynamic data,) {
    final lookup = Map.fromEntries(
      SerialPortParity.values.map((e) => MapEntry(e.index, e,),),
    );

    return lookup[int.tryParse('$data',)] ?? SerialPortParity.none;
  }

  static SerialPortControl _parseFlowControl(dynamic data,) {
    final lookup = Map.fromEntries(
      SerialPortControl.values.map((e) => MapEntry(e.index, e,),),
    );

    return lookup[int.tryParse('$data',)] ?? SerialPortControl.none;
  }

  @override
  bool operator ==(Object other) {
    if (other is SerialPortDevice) {
      return deviceID == other.deviceID && baudrate == other.baudrate;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(deviceID, baudrate,);
}

enum SerialPortParity {
  none,
  odd,
  even,
  mark,
  space,
}

enum SerialPortControl {
  none,
  software,
  hardware,
}

class SerialPortTimeout {

  SerialPortTimeout._fromMap(Map<String, dynamic> data,)
      : interByteTimeout = data['inter_byte_timeout'],
        readTimeoutConstant = data['read_timeout_constant'],
        readTimeoutMultiplier = data['read_timeout_multiplier'],
        writeTimeoutConstant = data['write_timeout_constant'],
        writeTimeoutMultiplier = data['write_timeout_multiplier'];

  Map<String, dynamic> toMap() => {
    'inter_byte_timeout': interByteTimeout,
    'read_timeout_constant': readTimeoutConstant,
    'read_timeout_multiplier': readTimeoutMultiplier,
    'write_timeout_constant': writeTimeoutConstant,
    'write_timeout_multiplier': writeTimeoutMultiplier,
  };

  final int interByteTimeout;
  final int readTimeoutConstant;
  final int readTimeoutMultiplier;
  final int writeTimeoutConstant;
  final int writeTimeoutMultiplier;
}

class PosbankSerialPort {

}