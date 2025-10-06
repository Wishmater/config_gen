import "package:build/build.dart";
import "package:config_gen/src/annotations.dart";
import "package:config_gen/src/utils.dart";
import "package:source_gen/source_gen.dart";
import "package:analyzer/dart/element/element2.dart";
import "package:analyzer/dart/element/type.dart";

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
    final schemas = <SchemaTableGen>[];
    // traverse fields and parse data needed to generate valid fields
    for (final e in element.fields2) {
      final (isSchema, annotation) = isFieldAnnotatedWith(e, "$SchemaFieldAnnot", SchemaTableGen.from);

      final resType = getResType(e.type);
      if (resType == null && !isSchema) {
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
      final originalName = e.name3!;
      if (!originalName.startsWith("_")) {
        throw InvalidGenerationSourceError(
          "Field declarations must be private",
          element: element,
        );
      }
      final name = originalName.substring(1);

      if (isSchema) {
        schemas.add(annotation!);
        continue;
      }

      final constant = e.computeConstantValue();
      final constantReader = ConstantReader(constant);
      // final defaultTo = constantReader.peek("defaultTo")?.objectValue;
      final defaultTo = getDefaultToSource(e);
      final nullable = constantReader.peek("nullable")?.boolValue;
      final comment = e.documentationComment;
      fields.add(
        FieldData(
          name: name,
          nullable: nullable ?? false,
          defaultTo: defaultTo,
          resType: resType,
          comment: comment,
        ),
      );
    }

    final hasDynamicSchema = hasGetSchemaTablesMethod(element);

    final buffer = StringBuffer();

    // generate abstract interface, to facilitate adding getters to user mixin
    buffer.write("mixin ${className}I {");
    for (final e in fields) {
      buffer.writeln("");
      if (e.defaultTo != null) buffer.writeln("  @ConfigDocDefault<${e.resType}>(${e.defaultTo})");
      if (e.comment != null) buffer.writeln("  ${e.comment}");
      buffer.writeln("  ${e.resType}${e.nullable ? '?' : ''} get ${e.name};");
    }
    SchemaTableGen.writeGetterSchemas(buffer, schemas);
    if (hasDynamicSchema) {
      buffer.writeln("List<(String, Object)> get dynamicSchemas;");
    }
    buffer.writeln("}");

    // generate concrete class
    buffer.writeln();
    // buffer.writeln("@immutable");
    buffer.writeln("class $className extends ConfigBaseI with ${className}I, $baseClassName {");

    // add static Schema
    buffer.writeln("");
    buffer.writeln("  static const BlockSchema staticSchema = BlockSchema(");
    if (annotation.read("ignoreNotInSchema").boolValue) {
      buffer.writeln("    ignoreNotInSchema: true,");
    }
    if (schemas.isNotEmpty) {
      buffer.write("    blocks: ");
      SchemaTableGen.writeMapSchemas(buffer, schemas, baseClassName);
      buffer.writeln(",");
      buffer.write("    canBeMissingSchemas: ");
      SchemaTableGen.writeCanBeMissingSchemas(buffer, schemas);
      buffer.writeln(",");
    }
    if (hasValidatorMethod(element)) {
      buffer.writeln("    validator: $baseClassName._validator,");
    }
    buffer.writeln("    fields: {");
    for (final e in fields) {
      buffer.writeln("    '${unprivate(e.name)}': $baseClassName._${e.name},");
    }
    buffer.writeln("    },");
    buffer.writeln("  );");
    buffer.writeln("");

    // add schema
    buffer.writeln("");
    if (hasDynamicSchema) {
      buffer.writeln("  static BlockSchema get schema => LazySchema(");
      buffer.writeln("    blocksGetter: () => {");
      buffer.writeln("      ...staticSchema.blocks,");
      buffer.writeln("      ...$baseClassName._getDynamicSchemaTables().map((k, v) => MapEntry(k, v.schema)),");
      buffer.writeln("    },");
      buffer.writeln("    fields: staticSchema.fields,");
      buffer.writeln("    validator: staticSchema.validator,");
      buffer.writeln("    ignoreNotInSchema: staticSchema.ignoreNotInSchema,");
      if (!annotation.read("requireStaticSchema").boolValue) {
        buffer.writeln(
          "    canBeMissingSchemasGetter: () => <String>{...staticSchema.canBeMissingSchemas, ...$baseClassName._getDynamicSchemaTables().keys},",
        );
      } else {
        buffer.writeln("    canBeMissingSchemasGetter: () => staticSchema.canBeMissingSchemas,");
      }
      buffer.writeln("  );");
      buffer.writeln("");

      buffer.writeln("@override");
      buffer.writeln("final List<(String, Object)> dynamicSchemas;");
    } else {
      buffer.writeln("  static BlockSchema get schema => staticSchema;");
    }

    // add field declarations
    buffer.writeln("");
    for (final e in fields) {
      buffer.writeln("  @override");
      buffer.writeln("  final ${e.resType}${e.nullable ? '?' : ''} ${e.name};");
    }

    // add static schema tables as independent variables
    if (schemas.isNotEmpty) {
      // TODO: 2 this assumes the resultType is autogenerated with config_gen as well.
      // If it isn't it will have a lot of issues. Maybe we could do some checks to
      // at least fail gracefully ot omit tables not generated with config_gen.
      buffer.writeln("");
      SchemaTableGen.writeFieldsSchemas(buffer, schemas);
    }

    // add constructor
    buffer.writeln("");
    // TODO: 3 maybe add an option to make class const
    // generated class can't be const by default because it breaks most defaultTo declarations
    // buffer.writeln("  const $className({");
    buffer.write("  $className(");
    bool hasDefaultTos = false;
    if (fields.isNotEmpty || schemas.isNotEmpty || hasDynamicSchema) {
      buffer.writeln("{");
    }
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
    SchemaTableGen.writeConstructorParameterSchemas(buffer, schemas);
    if (hasDynamicSchema) {
      buffer.writeln("required this.dynamicSchemas,");
    }
    if (fields.isNotEmpty || schemas.isNotEmpty || hasDynamicSchema) {
      buffer.write("})");
    } else {
      buffer.write(")");
    }

    if (hasDefaultTos) {
      // This hack is needed because default values in constructors must be const, which causes issues with custom
      // objects like Duration. Initializing it here is more robust.
      buffer.write(" : ");
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
      buffer.writeln(";");
    }

    // add fromBlock
    buffer.writeln("");
    buffer.writeln("  factory $className.fromBlock(BlockData data) {");
    buffer.writeln("    Map<String, dynamic> fields = data.fields;");
    if (hasDynamicSchema) {
      buffer.writeln("""

        final dynamicSchemas = <(String, Object)>[];
        final schemas = $baseClassName._getDynamicSchemaTables();

        for (final block in data.blocks) {
          final key = block.\$1;
          if (!schemas.containsKey(key)) {
            continue;
          }
          dynamicSchemas.add((key, schemas[key]!.from(block.\$2)));
        }
        """);
    }
    buffer.writeln("    return $className(");
    if (hasDynamicSchema) {
      buffer.writeln("      dynamicSchemas: dynamicSchemas,");
    }
    for (final e in fields) {
      buffer.writeln("      ${unprivate(e.name)}: fields['${unprivate(e.name)}'],");
    }
    SchemaTableGen.writeFromBlockParameterSchemas(buffer, schemas);
    buffer.writeln("    );");
    buffer.writeln("  }");

    // write toString method
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.writeln("  String toString() {");
    buffer.write("    return '''$className(\n\t");
    buffer.write(
      [
        ...fields.map((e) => "${e.name} = \$${e.name}"),
        ...schemas.map((e) => "${e.fieldName} = \${${e.fieldName}.toString().split(\"\\n\").join(\"\\n\\t\")}"),
        if (hasDynamicSchema) "dynamicSchemas = \${dynamicSchemas.toString().split(\"\\n\").join(\"\\n\\t\")}",
      ].join(",\n\t"),
    );
    buffer.writeln("");
    buffer.writeln(")''';");
    buffer.writeln("  }");

    // write equality operator
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.writeln("  bool operator==(covariant $className other) {");
    buffer.write("    return ");
    var compareFields = [
      ...fields.map((e) => e.name).map((name) => "$name == other.$name"),
      ...schemas.where((e) => !e.multiple).map((e) => e.fieldName).map((name) => "$name == other.$name"),
      ...schemas.where((e) => e.multiple).map((e) => e.fieldName).map((name) => "configListEqual($name, other.$name)"),
      if (hasDynamicSchema) "configListEqual(dynamicSchemas, other.dynamicSchemas)",
    ];
    if (compareFields.isEmpty) {
      compareFields = ["true"];
    }
    buffer.write(
      compareFields.join(" && "),
    );
    buffer.writeln(";");
    buffer.writeln("  }");

    // write hashMethod
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.write("  int get hashCode => Object.hashAll([");
    buffer.write(
      [
        ...fields.map((e) => e.name),
        ...schemas.map((e) => e.fieldName),
        if (hasDynamicSchema) "dynamicSchemas",
      ].join(", "),
    );
    buffer.writeln("]);");

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
      for (final supertype in type.element3.allSupertypes) {
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
}

Builder configBuilder(BuilderOptions options) => PartBuilder([ConfigGenerator()], ".config.dart");
