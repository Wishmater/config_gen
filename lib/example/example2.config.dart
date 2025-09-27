// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example2.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin Example2ConfigI {
  /// documenation comment for fieldA
  String get fieldA;

  /// documenation comment for fieldB
  double get fieldB;
  int get fieldC;
  bool? get fieldD;
  String? get fieldE;
}

class Example2Config extends ConfigBaseI
    with Example2ConfigI, Example2ConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    fields: {
      'fieldA': Example2ConfigBase._fieldA,
      'fieldB': Example2ConfigBase._fieldB,
      'fieldC': Example2ConfigBase._fieldC,
      'fieldD': Example2ConfigBase._fieldD,
      'fieldE': Example2ConfigBase._fieldE,
    },
  );

  static BlockSchema get schema => staticSchema;

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

  Example2Config({
    required this.fieldA,
    required this.fieldB,
    int? fieldC,
    this.fieldD,
    String? fieldE,
  }) : fieldC = fieldC ?? 1,
       fieldE = fieldE ?? "def";

  factory Example2Config.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;
    return Example2Config(
      fieldA: fields['fieldA'],
      fieldB: fields['fieldB'],
      fieldC: fields['fieldC'],
      fieldD: fields['fieldD'],
      fieldE: fields['fieldE'],
    );
  }

  @override
  String toString() {
    return '''Example2Config(
	fieldA = $fieldA,
	fieldB = $fieldB,
	fieldC = $fieldC,
	fieldD = $fieldD,
	fieldE = $fieldE
)''';
  }

  @override
  bool operator ==(covariant Example2Config other) {
    return fieldA == other.fieldA &&
        fieldB == other.fieldB &&
        fieldC == other.fieldC &&
        fieldD == other.fieldD &&
        fieldE == other.fieldE;
  }

  @override
  int get hashCode => Object.hashAll([fieldA, fieldB, fieldC, fieldD, fieldE]);
}
