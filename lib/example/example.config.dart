// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ExampleConfigI {
  /// documenation comment for fieldA
  String get fieldA;

  /// documenation comment for fieldB
  double get fieldB;
  int get fieldC;
  bool? get fieldD;
  String? get fieldE;
}

class ExampleConfig with ExampleConfigI, ExampleConfigBase {
  static const TableSchema staticSchema = TableSchema(
    fields: {
      'fieldA': ExampleConfigBase._fieldA,
      'fieldB': ExampleConfigBase._fieldB,
      'fieldC': ExampleConfigBase._fieldC,
      'fieldD': ExampleConfigBase._fieldD,
      'fieldE': ExampleConfigBase._fieldE,
    },
  );

  static TableSchema get schema => staticSchema;

  @override
  final String fieldA;
  @override
  final double fieldB;
  @override
  final int fieldC;
  @override
  final bool? fieldD;
  @override
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

  @override
  String toString() {
    return 'ExampleConfig(fieldA = $fieldA, fieldB = $fieldB, fieldC = $fieldC, fieldD = $fieldD, fieldE = $fieldE)';
  }

  @override
  bool operator ==(covariant ExampleConfig other) {
    return fieldA == other.fieldA &&
        fieldB == other.fieldB &&
        fieldC == other.fieldC &&
        fieldD == other.fieldD &&
        fieldE == other.fieldE;
  }

  @override
  int get hashCode => Object.hashAll([fieldA, fieldB, fieldC, fieldD, fieldE]);
}
