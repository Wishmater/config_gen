// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=info, type=warning

part of 'example.dart';

// **************************************************************************
// ConfigGenerator
// **************************************************************************

mixin ExampleConfigI {
  /// documenation comment for fieldA
  String get fieldA;

  /// documenation comment for fieldB
  double get fieldB;

  @ConfigDocDefault<int>(null ?? (sas ? 1 : 2))
  int get fieldC;

  bool? get fieldD;

  @ConfigDocDefault<String>("def")
  String? get fieldE;

  /// Example 2 schema
  Example2Config get example2;
  Example2Config? get example3;

  /// Example 3 schema
  List<Example2Config>? get example4;
  List<(String, Object)> get dynamicSchemas;
}

class ExampleConfig extends ConfigBaseI with ExampleConfigI, ExampleConfigBase {
  static const BlockSchema staticSchema = BlockSchema(
    ignoreNotInSchema: true,
    blocks: {
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

  static BlockSchema get schema => BlockSchema(
    blocks: {
      ...staticSchema.blocks,
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
  final List<(String, Object)> dynamicSchemas;

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
  }) : fieldC = fieldC ?? null ?? (sas ? 1 : 2),
       fieldE = fieldE ?? "def";

  factory ExampleConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;

    final dynamicSchemas = <(String, Object)>[];
    final schemas = ExampleConfigBase._getDynamicSchemaTables();

    for (final block in data.blocks) {
      final key = block.$1;
      if (!schemas.containsKey(key)) {
        continue;
      }
      dynamicSchemas.add((key, schemas[key]!.from(block.$2)));
    }

    return ExampleConfig(
      dynamicSchemas: dynamicSchemas,
      fieldA: fields['fieldA'],
      fieldB: fields['fieldB'],
      fieldC: fields['fieldC'],
      fieldD: fields['fieldD'],
      fieldE: fields['fieldE'],
      example2: Example2Config.fromBlock(data.firstBlockWith('example2')!),
      example3: data.blockContainsKey('example3')
          ? Example2Config.fromBlock(data.firstBlockWith('example3')!)
          : null,
      example4: data.blockContainsKey('Example4')
          ? List<Example2Config>.of(
              data.blocksWith('Example4').map(Example2Config.fromBlock),
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
        configListEqual(dynamicSchemas, other.dynamicSchemas);
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
  List<(String, Object)> get dynamicSchemas;
}

class EmptyExampleConfig extends ConfigBaseI
    with EmptyExampleConfigI, EmptyExampleConfigBase {
  static const BlockSchema staticSchema = BlockSchema(fields: {});

  static BlockSchema get schema => BlockSchema(
    blocks: {
      ...staticSchema.blocks,
      ...EmptyExampleConfigBase._getDynamicSchemaTables().map(
        (k, v) => MapEntry(k, v.schema),
      ),
    },
    fields: staticSchema.fields,
    validator: staticSchema.validator,
    ignoreNotInSchema: staticSchema.ignoreNotInSchema,
    canBeMissingSchemas: staticSchema.canBeMissingSchemas,
  );

  @override
  final List<(String, Object)> dynamicSchemas;

  EmptyExampleConfig({required this.dynamicSchemas});

  factory EmptyExampleConfig.fromBlock(BlockData data) {
    Map<String, dynamic> fields = data.fields;

    final dynamicSchemas = <(String, Object)>[];
    final schemas = EmptyExampleConfigBase._getDynamicSchemaTables();

    for (final block in data.blocks) {
      final key = block.$1;
      if (!schemas.containsKey(key)) {
        continue;
      }
      dynamicSchemas.add((key, schemas[key]!.from(block.$2)));
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
    return configListEqual(dynamicSchemas, other.dynamicSchemas);
  }

  @override
  int get hashCode => Object.hashAll([dynamicSchemas]);
}
