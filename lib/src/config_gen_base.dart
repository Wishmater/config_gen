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
        "Invalid name for mixin, must end with Base: $baseClassName",
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

    // generate abstract interface, to facilitate adding getters to user mixin
    buffer.writeln("mixin ${className}I {");
    for (final e in fields) {
      buffer.writeln("  ${e.resType}${e.nullable ? '?' : ''} get ${e.name};");
    }
    buffer.writeln("}");

    // generate concrete class
    buffer.writeln();
    // buffer.writeln("@immutable");
    buffer.writeln("class $className with ${className}I, $baseClassName {");

    // add field declarations
    for (final e in fields) {
      buffer.writeln("  final ${e.resType}${e.nullable ? '?' : ''} ${e.name};");
    }

    // add constructor
    buffer.writeln("");
    // TODO: 3 maybe add an option to make class const
    // generated class can't be const by default because it breaks most defaultTo declarations
    // buffer.writeln("  const $className({");
    buffer.writeln("  $className({");
    bool hasDefaultTos = false;
    for (final e in fields) {
      if (e.defaultTo == null && !e.name.startsWith("_")) {
        buffer.writeln(
          "    ${e.isRequired ? "required " : ""}this.${e.name},",
        );
      } else {
        hasDefaultTos = true;
        buffer.writeln("    ${e.isRequired ? "required " : ""}${e.resType}? ${unprivate(e.name)},");
      }
    }
    if (hasDefaultTos) {
      // This hack is needed because default values in constructors must be const, which causes issues with custom
      // objects like Duration. Initializing it here is more robust.
      buffer.write("  }) : ");
      bool addedAny = false;
      for (final e in fields) {
        if (e.defaultTo == null && !e.name.startsWith("_")) {
          continue;
        }
        if (addedAny) {
          buffer.writeln(",");
        }
        addedAny = true;
        buffer.write("       ${e.name} = ${unprivate(e.name)}");
        if (e.defaultTo != null) {
          buffer.write(" ?? ${e.defaultTo}");
        }
      }
      buffer.writeln(";");
    } else {
      buffer.writeln("  });");
    }

    // add fromMap
    buffer.writeln("");
    buffer.writeln("  factory $className.fromMap(Map<String, dynamic> map) {");
    buffer.writeln("    return $className(");
    for (final e in fields) {
      buffer.writeln("      ${unprivate(e.name)}: map['${unprivate(e.name)}'],");
    }
    buffer.writeln("    );");
    buffer.writeln("  }");

    // add Schema
    buffer.writeln("");
    buffer.writeln("  static TableSchema get schema => TableSchema(");
    if (hasGetSchemaTablesMethod(element)) {
      buffer.writeln("    tables: $baseClassName._getSchemaTables(),");
    }
    buffer.writeln("    fields: {");
    for (final e in fields) {
      buffer.writeln("    '${unprivate(e.name)}': $baseClassName._${e.name},");
    }
    buffer.writeln("    },");
    buffer.writeln("  );");
    buffer.writeln("");

    // write toString method
    buffer.writeln("  @override");
    buffer.writeln("  String toString() {");
    buffer.write("    return '$className");
    buffer.write(fields.map((field) => "${field.name} = \$${field.name}").join(", "));
    buffer.writeln("';");
    buffer.writeln("  }");

    // write equality operator
    buffer.writeln("  @override");
    buffer.writeln("  bool operator==(covariant $className other) {");
    buffer.write("    return ");
    buffer.write(fields.map((field) => "${field.name} == other.${field.name}").join(" && "));
    buffer.writeln(";");
    buffer.writeln("  }");

    // write hashMethod
    buffer.writeln("  @override");
    buffer.writeln("  int get hashCode => Object.hashAll([${fields.map((field) => field.name).join(', ')}]);");

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
        // log.warning(type.asInstanceOf2(supertype.element3));
        if (supertype.element3.name3 == "Field" && supertype.typeArguments.length == 2) {
          fieldType = type.asInstanceOf2(supertype.element3);
          break;
        }
      }
    }
    if (fieldType == null) {
      return null;
    }
    // log.warning("${type} ${fieldType} ${fieldType.typeArguments} ${fieldType.element3}");
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

  bool hasGetSchemaTablesMethod(MixinElement2 classElement) {
    final method = classElement.getMethod2("_getSchemaTables");
    if (method == null || !method.isStatic || method.formalParameters.isNotEmpty) {
      return false;
    }
    final returnType = method.returnType;
    if (returnType is! InterfaceType || returnType.element3.name3 != "Map") {
      return false;
    }
    final typeArgs = returnType.typeArguments;
    if (typeArgs.length != 2 ||
        typeArgs[0].getDisplayString() != "String" ||
        (typeArgs[1].getDisplayString() != "TableSchema" && typeArgs[1].getDisplayString() != "Schema")) {
      return false;
    }
    return true;
  }

  String unprivate(String string) {
    while (string.startsWith("_")) {
      string = string.substring(1);
    }
    return string;
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
