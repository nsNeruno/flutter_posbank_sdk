import 'dart:convert';

abstract class Serializable {

  const Serializable();

  Map<String, dynamic> toMap();

  @override
  String toString() => const JsonEncoder.withIndent('\t',).convert(toMap(),);
}