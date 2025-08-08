import "package:build/build.dart";
import "package:config_gen/src/annotations.dart";
import "package:source_gen/source_gen.dart";
import "package:analyzer/dart/element/element2.dart";
import "package:analyzer/dart/element/type.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";

class ConfigGenerator extends GeneratorForAnnotation<Config> {
  @override
  String generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! MixinElement2) {
      throw InvalidGenerationSourceError(
        "Config annotation can only be applied to a mixin.",
        element: element,
      );
    }

    final baseClassName = element.name3;
    if (baseClassName == null) {
      throw InvalidGenerationSourceError(
        "Invalid name for mixin: null",
        element: element,
      );
    }
    if (!baseClassName.endsWith("Base")) {
      throw InvalidGenerationSourceError(
        "Invalid name for mixin: null",
        element: element,
      );
    }
    final className = baseClassName.substring(0, baseClassName.length - 4);

    final fields = <FieldData>[];
    // traverse fields and parse data needed to generate valid fields
    for (final e in element.fields2) {
      final resType = getResType(e.type);
      if (resType == null) {
        continue;
      }
      if (!e.isStatic) {
        throw InvalidGenerationSourceError(
          "Field declarations must be static",
          element: element,
        );
      }
      if (!e.isConst) {
        throw InvalidGenerationSourceError(
          "Field declarations must be const",
          element: element,
        );
      }
      if (!e.hasInitializer) {
        throw InvalidGenerationSourceError(
          "Field declarations must have initializers",
          element: element,
        );
      }
      final constant = e.computeConstantValue();
      final constantReader = ConstantReader(constant);
      // final defaultTo = constantReader.peek("defaultTo")?.objectValue;
      final defaultTo = getDefaultToSource(e);
      final nullable = constantReader.peek("nullable")?.boolValue;
      final originalName = e.name3!;
      if (!originalName.startsWith("_")) {
        throw InvalidGenerationSourceError(
          "Field declarations must be private",
          element: element,
        );
      }
      final name = originalName.substring(1);
      fields.add(
        FieldData(
          name: name,
          nullable: nullable ?? false,
          defaultTo: defaultTo,
          resType: resType,
        ),
      );
    }

    final buffer = StringBuffer();
    // buffer.writeln("@immutable");
    buffer.writeln("class $className with $baseClassName {");

    // add field declarations
    for (final e in fields) {
      buffer.writeln("  final ${e.resType}${e.nullable ? '?' : ''} ${e.name};");
    }

    // add constructor
    buffer.writeln("");
    buffer.writeln("  const $className({");
    for (final e in fields) {
      buffer.writeln(
        "    ${e.isRequired ? "required " : ""}this.${e.name}${e.defaultTo != null ? " = ${e.defaultTo}" : ""},",
      );
    }
    buffer.writeln("  });");

    // add fromMap
    buffer.writeln("");
    buffer.writeln("  factory $className.fromMap(Map<String, dynamic> map) {");
    buffer.writeln("    return $className(");
    for (final e in fields) {
      buffer.writeln("      ${e.name}: map['${e.name}'],");
    }
    buffer.writeln("    );");
    buffer.writeln("  }");

    // add Schema
    buffer.writeln("");
    buffer.writeln("  static const schema = TableSchema(");
    buffer.writeln("    fields: {");
    for (final e in fields) {
      buffer.writeln("    '${e.name}': $baseClassName._${e.name},");
    }
    buffer.writeln("    },");
    buffer.writeln("  );");

    buffer.writeln("}");
    return buffer.toString();
  }

  // Extract Res type parameter from Field<Rec, Res>
  DartType? getResType(DartType type) {
    if (type is! InterfaceType) {
      return null;
    }
    // Check type and its supertypes for Field<Rec, Res>
    InterfaceType? fieldType;
    if (type.element3.name3 == "Field" && type.typeArguments.length == 2) {
      fieldType = type;
    } else {
      for (var supertype in type.element3.allSupertypes) {
        if (supertype.element3.name3 == "Field" && supertype.typeArguments.length == 2) {
          fieldType = type.asInstanceOf2(supertype.element3);
          break;
        }
      }
    }
    if (fieldType == null) {
      return null;
    }
    // Return Res (second type argument)
    return fieldType.typeArguments[1];
  }

  // Extract the source of the defaultTo argument using AST
  String? getDefaultToSource(FieldElement2 field) {
    try {
      // Get the compilation unit and parse the initializer
      final visitor = DefaultToVisitor();
      field.constantInitializer!.accept(visitor);
      if (visitor.defaultToSource == null) {
        // log.warning('No defaultTo argument found in initializer for field ${field.name3}');
        return null;
      }
      return visitor.defaultToSource;
    } catch (e) {
      // log.warning('Error extracting defaultTo source for field ${field.name3}: $e');
      return null;
    }
  }
}

// Visitor to find the defaultTo argument
class DefaultToVisitor extends SimpleAstVisitor<void> {
  String? defaultToSource;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Check the argument list for named arguments
    for (var argument in node.argumentList.arguments) {
      if (argument is NamedExpression && argument.name.label.name == "defaultTo") {
        defaultToSource = argument.expression.toSource();
        break;
      }
    }
  }
}

class FieldData {
  String name;
  bool nullable;
  String? defaultTo;
  DartType? resType;
  FieldData({
    required this.name,
    required this.nullable,
    required this.defaultTo,
    required this.resType,
  });
  bool get isRequired => !nullable && defaultTo == null;
}

Builder configBuilder(BuilderOptions options) => PartBuilder([ConfigGenerator()], ".g.dart");
