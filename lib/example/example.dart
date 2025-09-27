import "dart:math";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:config_gen/example/example2.dart";

part "example.config.dart";

const sas = false;

@Config(ignoreNotInSchema: true)
mixin ExampleConfigBase on ExampleConfigI {
  /// documenation comment for fieldA
  static const _fieldA = StringField();

  /// documenation comment for fieldB
  static const _fieldB = DoubleNumberField();
  static const _fieldC = IntegerNumberField(defaultTo: null ?? (sas ? 1 : 2));
  static const _fieldD = BooleanField(nullable: true);
  static const _fieldE = StringField(defaultTo: "def", nullable: true);
  // TODO: 3 test custom values like EnumField

  num get testGetter => max(fieldB, fieldC);

  @SchemaFieldAnnot()
  /// Example 2 schema
  static const _example2 = Example2Config.staticSchema;

  @SchemaFieldAnnot(required: false)
  static const _example3 = Example2Config.staticSchema;

  /// Example 3 schema
  @SchemaFieldAnnot(required: false, allowMultiple: true)
  static const _Example4 = Example2Config.staticSchema;

  static void _validator(BlockData values, List<EvaluationError> errors) {}

  static Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> _getDynamicSchemaTables() => {
    "Example5": (schema: Example2Config.schema, from: Example2Config.fromBlock),
    "Example6": (schema: Example2Config.schema, from: Example2Config.fromBlock),
  };
}

@Config(requireStaticSchema: true)
mixin EmptyExampleConfigBase {
  static Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> _getDynamicSchemaTables() => {
    "Example5": (schema: Example2Config.staticSchema, from: Example2Config.fromBlock),
    "Example6": (schema: Example2Config.staticSchema, from: Example2Config.fromBlock),
  };
}
