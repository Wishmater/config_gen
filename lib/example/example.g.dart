// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ExampleConfigI {
  String get fieldA;
  double get fieldB;
  int get fieldC;
  bool? get fieldD;
  String? get fieldE;
}

class ExampleConfig with ExampleConfigI, ExampleConfigBase {
  final String fieldA;
  final double fieldB;
  final int fieldC;
  final bool? fieldD;
  final String? fieldE;

  ExampleConfig({
    required this.fieldA,
    required this.fieldB,
    int? fieldC,
    this.fieldD,
    String? fieldE,
  }) : fieldC = fieldC ?? 1,
       fieldE = fieldE ?? "def";

  factory ExampleConfig.fromMap(Map<String, dynamic> map) {
    return ExampleConfig(
      fieldA: map['fieldA'],
      fieldB: map['fieldB'],
      fieldC: map['fieldC'],
      fieldD: map['fieldD'],
      fieldE: map['fieldE'],
    );
  }

  static const schema = TableSchema(
    fields: {
      'fieldA': ExampleConfigBase._fieldA,
      'fieldB': ExampleConfigBase._fieldB,
      'fieldC': ExampleConfigBase._fieldC,
      'fieldD': ExampleConfigBase._fieldD,
      'fieldE': ExampleConfigBase._fieldE,
    },
  );
}
