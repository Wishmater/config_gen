import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "example2.config.dart";

@Config()
mixin Example2ConfigBase on Example2ConfigI {
  /// documenation comment for fieldA
  static const _fieldA = StringField();
  /// documenation comment for fieldB
  static const _fieldB = DoubleNumberField();
  static const _fieldC = IntegerNumberField(defaultTo: 1);
  static const _fieldD = BooleanField(nullable: true);
  static const _fieldE = StringField(defaultTo: "def", nullable: true);
}
