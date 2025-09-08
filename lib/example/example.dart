import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "example.config.dart";

@Config()
mixin ExampleConfigBase on ExampleConfigI {
  static const _fieldA = StringField();
  static const _fieldB = DoubleNumberField();
  static const _fieldC = IntegerNumberField(defaultTo: 1);
  static const _fieldD = BooleanField(nullable: true);
  static const _fieldE = StringField(defaultTo: "def", nullable: true);
  // TODO: 3 test custom values like EnumField

  num get testGetter => fieldB + fieldC;
}

// // this is what should be generated
//
// mixin ExampleConfigI {
//   String get fieldA;
//   double get fieldB;
//   int get fieldC;
//   bool? get fieldD;
//   String? get fieldE;
// }
//
// @immutable
// class ExampleConfig with ExampleConfigBase {
//   final String fieldA;
//   final double fieldB;
//   final int fieldC;
//   final bool? fieldD;
//   final String? fieldE;
//
//   const ExampleConfig({
//     required this.fieldA,
//     required this.fieldB,
//     this.fieldC = 1,
//     required this.fieldD,
//     this.fieldE = "def",
//   });
//
//   factory ExampleConfig.fromMap(Map<String, dynamic> map) {
//     return ExampleConfig(
//       fieldA: map["fieldA"],
//       fieldB: map["fieldB"],
//       fieldC: map["fieldC"],
//       fieldD: map["fieldD"],
//       fieldE: map["fieldE"],
//     );
//   }
//
//   static const schema = TableSchema(
//     fields: {
//       "fieldA": ExampleConfigBase._fieldA,
//       "fieldB": ExampleConfigBase._fieldB,
//       "fieldC": ExampleConfigBase._fieldC,
//       "fieldD": ExampleConfigBase._fieldD,
//       "fieldE": ExampleConfigBase._fieldE,
//     },
//   );
// }
