import "dart:math";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:config_gen/example/example2.dart";

part "example.config.dart";

@Config(ignoreNotInSchema: true)
mixin ExampleConfigBase on ExampleConfigI {
  /// documenation comment for fieldA
  static const _fieldA = StringField();

  /// documenation comment for fieldB
  static const _fieldB = DoubleNumberField();
  static const _fieldC = IntegerNumberField(defaultTo: 1);
  static const _fieldD = BooleanField(nullable: true);
  static const _fieldE = StringField(defaultTo: "def", nullable: true);
  // TODO: 3 test custom values like EnumField

  num get testGetter => max(fieldB, fieldC);

  @SchemaTable()
  /// Example 2 schema
  static const _example2 = Example2Config.staticSchema;

  @SchemaTable(required: false)
  static const _example3 = Example2Config.staticSchema;

  static void _validator(Map<String, dynamic> values, List<EvaluationError> errors) {}

  static Map<String, TableSchema> _getDynamicSchemaTables() => {

  };
}
