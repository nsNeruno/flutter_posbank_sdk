import 'package:flutter_posbank_sdk/src/devices/device_context.dart';
import 'package:flutter_posbank_sdk/src/serializable.dart';
import 'package:flutter_posbank_sdk/src/utils.dart';

class UsbDevice extends PrinterDeviceContext {

  UsbDevice.fromMap(Map<String, dynamic> data,)
      : manufacturerName = data['manufacturerName'],
        productName = data['productName'],
        version = data['version'],
        serialNumber = data['serialNumber'],
        deviceId = data['deviceId'],
        vendorId = data['vendorId'],
        productId = data['productId'],
        deviceClass = _parseDeviceClass(data['deviceClass'],),
        deviceSubclass = data['deviceSubclass'],
        deviceProtocol = data['deviceProtocol'],
        configurationCount = data['configurationCount'] ?? 0,
        interfaces = asList(
          data['interfaces'],
        )?.whereType<Map<String, dynamic>>().map(
          (e) => UsbInterface._(e,),
        ).toList(growable: false,) ?? [],
        super(name: data['deviceName'],);

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'manufacturerName': manufacturerName,
    'productName': productName,
    'version': version,
    'serialNumber': serialNumber,
    'deviceId': deviceId,
    'vendorId': vendorId,
    'productId': productId,
    'deviceClass': deviceClass.value,
    'deviceSubclass': deviceSubclass,
    'deviceProtocol': deviceProtocol,
    'configurationCount': configurationCount,
    'interfaces': interfaces.map((e) => e.toMap(),).toList(growable: false,),
  };

  final String? manufacturerName;
  final String? productName;
  final String version;
  final String? serialNumber;
  final int deviceId;
  final int vendorId;
  final int productId;
  final UsbDeviceClass deviceClass;
  final int? deviceSubclass;
  final int? deviceProtocol;
  final int configurationCount;
  final List<UsbInterface> interfaces;

  static UsbDeviceClass _parseDeviceClass(dynamic data,) {
    final lookup = Map.fromEntries(
      UsbDeviceClass.values.map((e) => MapEntry(e.value, e,),),
    );

    return lookup[int.tryParse('$data',)] ?? (throw UnsupportedError('Unknown value: $data',));
  }

  // "deviceName" to deviceName,
  //         "manufacturerName" to manufacturerName,
  //         "productName" to productName,
  //         "version" to version,
  //         "serialNumber" to serialNumber,
  //         "deviceId" to deviceId,
  //         "vendorId" to vendorId,
  //         "productId" to productId,
  //         "deviceClass" to deviceClass,
  //         "deviceSubclass" to deviceSubclass,
  //         "deviceProtocol" to deviceProtocol,
  //         "configurationCount" to configurationCount,
  //         "interfaces" to interfaceData.toList(),
  //         "hasPermission" to hasPermission
}

enum UsbDeviceClass {
  perInterface._(0,),
  audio._(1,),
  /// Communication Devices
  comm._(2,),
  /// Human Interface Device (mice, keyboards, etc)
  hid._(3,),
  physical._(5,),
  /// Image devices (digital cameras)
  stillImage._(6,),
  printer._(7,),
  massStorage._(8,),
  /// USB Hubs
  hub._(9,),
  // CDC Devices (communications device class)
  cdcData._(0x0a,),
  /// Content Smart Card Devices
  cscid._(0x0b,),
  /// Content Security Devices
  contentSec._(0x0d,),
  video._(0x0e,),
  wirelessController._(0xe0,),
  misc._(0xef,),
  /// Application Specific
  appSpec._(0xfe,),
  /// Vendor Specific
  vendorSpec._(0xff,);

  const UsbDeviceClass._(this.value,);

  final int value;
}

class UsbInterface extends Serializable {

  UsbInterface._(Map<String, dynamic> data,)
      : id = data['id'],
        alternateSetting = data['alternateSetting'],
        name = data['name'],
        interfaceClass = UsbDevice._parseDeviceClass(data['interfaceClass'],),
        interfaceSubclass = data['interfaceSubclass'],
        interfaceProtocol = data['interfaceProtocol'],
        endpoints = asList(
          data['endpoints'],
        )?.whereType<Map<String, dynamic>>().map(
          (e) => UsbEndpoint._(e,),
        ).toList(growable: false,) ?? [];

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'alternateSetting': alternateSetting,
    'name': name,
    'interfaceClass': interfaceClass.value,
    'interfaceSubclass': interfaceClass,
    'interfaceProtocol': interfaceProtocol,
    'endpoints': endpoints.map((e) => e.toMap(),).toList(growable: false,),
  };

  final int id;
  final int? alternateSetting;
  final String name;
  final UsbDeviceClass interfaceClass;
  final int? interfaceSubclass;
  final int? interfaceProtocol;
  final List<UsbEndpoint> endpoints;
}

class UsbEndpoint extends Serializable {

  UsbEndpoint._(Map<String, dynamic> data,)
      : address = data['address'],
        endpointNumber = data['endpointNumber'],
        direction = _parseDirection(data['direction'],),
        attributes = data['attributes'],
        type = _parseType(data['type'],),
        maxPacketSize = data['maxPacketSize'],
        interval = data['interval'] ?? 0;

  @override
  Map<String, dynamic> toMap() => {
    'address': address,
    'endpointNumber': endpointNumber,
    'direction': direction.value,
    'attributes': attributes,
    'type': type.index,
    'maxPacketSize': maxPacketSize,
    'interval': interval,
  };

  final int address;
  final int endpointNumber;
  final UsbDirection direction;
  final int? attributes;
  final UsbEndpointType type;
  final int? maxPacketSize;
  final int interval;

  static UsbDirection _parseDirection(dynamic data,) {
    final lookup = Map.fromEntries(
      UsbDirection.values.map((e) => MapEntry(e.value, e,),),
    );
    return lookup[int.tryParse('$data',)] ?? (throw UnsupportedError('Unknown value: $data',));
  }

  static UsbEndpointType _parseType(dynamic data,) {
    final lookup = Map.fromEntries(
      UsbEndpointType.values.map((e) => MapEntry(e.index, e,),),
    );
    return lookup[int.tryParse('$data',)] ?? (throw UnsupportedError('Unknown value: $data',));
  }
}

enum UsbDirection {
  dirOut._(0,),
  dirIn._(0x80,);

  const UsbDirection._(this.value,);

  final int value;
}

enum UsbEndpointType {
  xferControl,
  xferIsoc,
  xferBulk,
  xferInt,
}