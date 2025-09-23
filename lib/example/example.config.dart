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

  /// Example 3 schema
  List<Example2Config>? get example4;
  Map<String, List<Object>> get dynamicSchemas;
}

class ExampleConfig extends ConfigBaseI with ExampleConfigI, ExampleConfigBase {
  static const TableSchema staticSchema = TableSchema(
    ignoreNotInSchema: true,
    tables: {
      'example2': ExampleConfigBase._example2,
      'example3': ExampleConfigBase._example3,
      'Example4': ExampleConfigBase._Example4,
    },
    canBeMissingSchemas: {'example3', 'Example4'},
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
      ...ExampleConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...ExampleConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final Map<String, List<Object>> dynamicSchemas;

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
  @override
  final List<Example2Config>? example4;

  ExampleConfig({
    required this.fieldA,
    required this.fieldB,
    int? fieldC,
    this.fieldD,
    String? fieldE,
    required this.example2,
    this.example3,
    this.example4,
    required this.dynamicSchemas,
  }) : fieldC = fieldC ?? 1,
       fieldE = fieldE ?? "def";

  factory ExampleConfig.fromMap(Map<String, dynamic> map) {
    final dynamicSchemas = <String, List<Object>>{};
    final schemas = ExampleConfigBase._getDynamicSchemaTables();
    for (final entry in schemas.entries) {
      if (map[entry.key] == null) continue;
      for (final e in map[entry.key]) {
        if (dynamicSchemas[entry.key] == null) {
          dynamicSchemas[entry.key] = [];
        }
        dynamicSchemas[entry.key]!.add(entry.value.from(e));
      }
    }

    return ExampleConfig(
      dynamicSchemas: dynamicSchemas,
      fieldA: map['fieldA'],
      fieldB: map['fieldB'],
      fieldC: map['fieldC'],
      fieldD: map['fieldD'],
      fieldE: map['fieldE'],
      example2: Example2Config.fromMap(map['example2'][0]),
      example3: map['example3'] != null
          ? Example2Config.fromMap(map['example3'][0])
          : null,
      example4: map['Example4'] != null
          ? List<Example2Config>.of(
              (map['Example4'] as List<Map<String, dynamic>>).map(
                Example2Config.fromMap,
              ),
            )
          : null,
    );
  }

  @override
  String toString() {
    return '''ExampleConfig(
	fieldA = $fieldA,
	fieldB = $fieldB,
	fieldC = $fieldC,
	fieldD = $fieldD,
	fieldE = $fieldE,
	example2 = ${example2.toString().split("\n").join("\n\t")},
	example3 = ${example3.toString().split("\n").join("\n\t")},
	example4 = ${example4.toString().split("\n").join("\n\t")},
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant ExampleConfig other) {
    return fieldA == other.fieldA &&
        fieldB == other.fieldB &&
        fieldC == other.fieldC &&
        fieldD == other.fieldD &&
        fieldE == other.fieldE &&
        example2 == other.example2 &&
        example3 == other.example3 &&
        configListEqual(example4, other.example4) &&
        configMapEqual(dynamicSchemas, other.dynamicSchemas);
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
    example4,
    dynamicSchemas,
  ]);
}

mixin EmptyExampleConfigI {
  Map<String, List<Object>> get dynamicSchemas;
}

class EmptyExampleConfig extends ConfigBaseI
    with EmptyExampleConfigI, EmptyExampleConfigBase {
  static const TableSchema staticSchema = TableSchema(fields: {});

  static TableSchema get schema => TableSchema(
    tables: {
      ...staticSchema.tables,
      ...EmptyExampleConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: <String>{
      ...staticSchema.canBeMissingSchemas,
      ...ExampleConfigBase._getDynamicSchemaTables().keys,
    },
  );

  @override
  final Map<String, List<Object>> dynamicSchemas;

  EmptyExampleConfig({required this.dynamicSchemas});

  factory EmptyExampleConfig.fromMap(Map<String, dynamic> map) {
    final dynamicSchemas = <String, List<Object>>{};
    final schemas = ExampleConfigBase._getDynamicSchemaTables();
    for (final entry in schemas.entries) {
      if (map[entry.key] == null) continue;
      for (final e in map[entry.key]) {
        if (dynamicSchemas[entry.key] == null) {
          dynamicSchemas[entry.key] = [];
        }
        dynamicSchemas[entry.key]!.add(entry.value.from(e));
      }
    }

    return EmptyExampleConfig(dynamicSchemas: dynamicSchemas);
  }

  @override
  String toString() {
    return '''EmptyExampleConfig(
	dynamicSchemas = ${dynamicSchemas.toString().split("\n").join("\n\t")}
)''';
  }

  @override
  bool operator ==(covariant EmptyExampleConfig other) {
    return configMapEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([dynamicSchemas]);
}
