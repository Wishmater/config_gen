import "dart:io";

import "package:config/config.dart";
import "package:config_gen/example/example.dart";
import "package:config_gen/example/example2.dart";
import 'package:test/test.dart';

void main() {
  test("test example", () {
    final content = File("lib/example/configuration").readAsStringSync();

    final result = ConfigurationParser().parseFromString(
      content,
      schema: ExampleConfig.schema,
    );

    switch (result) {
      case EvaluationParseError():
        fail("$result");
      case EvaluationValidationError():
        fail("$result");
      case EvaluationSuccess():
        final actual = ExampleConfig.fromMap(result.values);
        final expected = ExampleConfig(
          fieldA: "Lore Ipsum",
          fieldB: 2,
          fieldE: "Lore Ipsum but with more",
          example2: Example2Config(
            fieldA: "Some other Lore",
            fieldB: 2.5,
          ),
          example3: Example2Config(
            fieldA: "Some other Lore",
            fieldB: 2.5,
          ),
          example4: [
            Example2Config(
              fieldA: "Some other Lore",
              fieldB: 2.5,
            ),
            Example2Config(
              fieldA: "Some other Lore2",
              fieldB: 2.5,
            ),
          ],
        );
        expect(
          actual,
          equals(
            expected,
          ),
        );
    }
  });
}
