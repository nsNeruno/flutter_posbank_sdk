import 'package:flutter_posbank_sdk/src/devices/device_context.dart';
import 'package:flutter_posbank_sdk/src/serializable.dart';
import 'package:flutter_posbank_sdk/src/utils.dart';

class BluetoothDevice extends PrinterDeviceContext {

  const BluetoothDevice({
    super.name,
    this.type = BluetoothType.unknown,
    this.alias,
    required this.bluetoothClass,
    this.uuids = const [],
    this.bondState = BluetoothBondState.none,
  });

  BluetoothDevice.fromMap(Map<String, dynamic> data,)
      : type = _parseType(data['type'],),
        alias = data['alias'],
        bluetoothClass = asMapAndCast(
          data['bluetoothClass'], (data) => BluetoothClass._fromMap(data,),
        ) ?? (throw (ArgumentError('Missing bluetooth class',))),
        uuids = asList(data['uuids'],)?.whereType<Map>().map(
          (e) => BluetoothUuid._fromMap(asMap(e,) ?? {},),
        ).toList() ?? [],
        bondState = _parseBondState(data['bondState'],),
        super(name: data['name'],);

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'type': type.index,
    'alias': alias,
    'bluetoothClass': bluetoothClass.toMap(),
    'uuids': uuids.map((e) => e.toMap(),).toList(growable: false,),
    'bondState': bondState.value,
  };

  final BluetoothType type;
  final String? alias;
  final BluetoothClass bluetoothClass;
  final List<BluetoothUuid> uuids;
  final BluetoothBondState bondState;

  static BluetoothType _parseType(dynamic data,) {
    final lookup = Map.fromEntries(
      BluetoothType.values.map((e) => MapEntry(e.index, e,),),
    );
    return lookup[int.tryParse('$data',)] ?? BluetoothType.unknown;
  }

  static BluetoothBondState _parseBondState(dynamic data,) {
    final lookup = Map.fromEntries(
      BluetoothBondState.values.map((e) => MapEntry(e.value, e,),),
    );
    return lookup[int.tryParse('$data',)] ?? BluetoothBondState.none;
  }
}

enum BluetoothType {
  unknown,
  classic,
  lowEnergy,
  dual,
}

class BluetoothClass extends Serializable {

  const BluetoothClass._({
    required this.deviceClass,
    required this.majorDeviceClass,
  });

  BluetoothClass._fromMap(Map<String, dynamic> data,)
      : deviceClass = data['deviceClass'],
        majorDeviceClass = data['majorDeviceClass'];

  @override
  Map<String, dynamic> toMap() => {
    'deviceClass': deviceClass,
    'majorDeviceClass': majorDeviceClass,
  };

  final int deviceClass;
  final int majorDeviceClass;
}

class BluetoothUuid extends Serializable {

  BluetoothUuid._fromMap(Map<String, dynamic> data,)
      : leastSignificantBits = data['leastSignificantBits'],
        mostSignificantBits = data['mostSignificantBits'],
        version = data['version'],
        variant = data['variant'],
        timestamp = data['timestamp'],
        clockSequence = data['clockSequence'],
        node = data['node'],
        _uuid = data['string'];

  @override
  Map<String, dynamic> toMap() => {
    'leastSignificantBits': leastSignificantBits,
    'mostSignificantBits': mostSignificantBits,
    'version': version,
    'variant': variant,
    'timestamp': timestamp,
    'clockSequence': clockSequence,
    'node': node,
  };

  final int leastSignificantBits;
  final int mostSignificantBits;
  final int version;
  final int variant;
  final int? timestamp;
  final int? clockSequence;
  final int? node;

  final String _uuid;

  @override
  String toString() => _uuid;
}

enum BluetoothBondState {
  none._(10,),
  bonding._(11,),
  bonded._(12,);

  const BluetoothBondState._(this.value,);

  final int value;
}