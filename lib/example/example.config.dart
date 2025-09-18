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

  /// Example 2 schema
  Example2Config get example2;
  Example2Config? get example3;
}

class ExampleConfig with ExampleConfigI, ExampleConfigBase {
  static const TableSchema staticSchema = TableSchema(
    ignoreNotInSchema: true,
    tables: {
      'example2': ExampleConfigBase._example2,
      'example3': ExampleConfigBase._example3,
    },
    canBeMissingSchemas: {'example3'},
    validator: ExampleConfigBase._validator,
    fields: {
      'fieldA': ExampleConfigBase._fieldA,
      'fieldB': ExampleConfigBase._fieldB,
      'fieldC': ExampleConfigBase._fieldC,
      'fieldD': ExampleConfigBase._fieldD,
      'fieldE': ExampleConfigBase._fieldE,
    },
  );

  static TableSchema get schema => TableSchema(
    tables: {
      ...staticSchema.tables,
      ...ExampleConfigBase._getDynamicSchemaTables(),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: staticSchema.canBeMissingSchemas,
  );

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

  @override
  final Example2Config example2;
  @override
  final Example2Config? example3;

  ExampleConfig({
    required this.fieldA,
    required this.fieldB,
    int? fieldC,
    this.fieldD,
    String? fieldE,
    required this.example2,
    this.example3,
  }) : fieldC = fieldC ?? 1,
       fieldE = fieldE ?? "def";

  factory ExampleConfig.fromMap(Map<String, dynamic> map) {
    return ExampleConfig(
      fieldA: map['fieldA'],
      fieldB: map['fieldB'],
      fieldC: map['fieldC'],
      fieldD: map['fieldD'],
      fieldE: map['fieldE'],
      example2: Example2Config.fromMap(map['example2']),
      example3: Example2Config.fromMap(map['example3']),
    );
  }

  @override
  String toString() {
    return 'ExampleConfig(fieldA = $fieldA, fieldB = $fieldB, fieldC = $fieldC, fieldD = $fieldD, fieldE = $fieldE, example2 = $example2, example3 = $example3)';
  }

  @override
  bool operator ==(covariant ExampleConfig other) {
    return fieldA == other.fieldA &&
        fieldB == other.fieldB &&
        fieldC == other.fieldC &&
        fieldD == other.fieldD &&
        fieldE == other.fieldE &&
        example2 == other.example2 &&
        example3 == other.example3;
  }

  @override
  int get hashCode => Object.hashAll([
    fieldA,
    fieldB,
    fieldC,
    fieldD,
    fieldE,
    example2,
    example3,
  ]);
}
