import "package:analyzer/dart/constant/value.dart";
import "package:build/build.dart";
import "package:config_gen/src/annotations.dart";
import "package:config_gen/src/utils.dart";
import "package:source_gen/source_gen.dart";
import "package:analyzer/dart/element/element2.dart";
import "package:analyzer/dart/element/type.dart";

class _FieldData {
  String name;
  bool nullable;
  String? defaultTo;
  DartType? resType;
  String? comment;
  _FieldData({
    required this.name,
    required this.nullable,
    required this.defaultTo,
    required this.resType,
    required this.comment,
  });
  bool get isRequired => !nullable && defaultTo == null;
}

class _SchemaTableGen {
  final String name;

  final bool required;

  final String type;

  final String? comment;

  _SchemaTableGen(this.name, this.type, this.required, this.comment);

  factory _SchemaTableGen.from(DartObject object, FieldElement2 field) {
    String? type = object.getField("type")?.toTypeValue()?.element3?.name3;
    if (type == null) {
      final initializer = field.constantInitializer!.toSource();
      // awful hack
      type = initializer.substring(0, initializer.indexOf("."));
    }
    return _SchemaTableGen(
      unprivate(field.name3!),
      type,
      object.getField("required")!.toBoolValue()!,
      field.documentationComment,
    );
  }

  static void writeMapSchemas(StringBuffer buffer, List<_SchemaTableGen> schemas, String baseClassName) {
    buffer.writeln("{");
    for (final schema in schemas) {
      buffer.write("'${schema.name}': ");
      buffer.writeln("$baseClassName._${schema.name},");
    }
    buffer.write("}");
  }

  static void writeCanBeMissingSchemas(StringBuffer buffer, List<_SchemaTableGen> schemas) {
    buffer.writeln("{");
    for (final schema in schemas) {
      if (!schema.required) buffer.writeln("'${schema.name}',");
    }
    buffer.write("}");
  }
}

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

    final fields = <_FieldData>[];
    final schemas = <_SchemaTableGen>[];
    // traverse fields and parse data needed to generate valid fields
    for (final e in element.fields2) {
      final (isSchema, annotation) = isFieldAnnotatedWith(e, "$SchemaTable", _SchemaTableGen.from);

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
        _FieldData(
          name: name,
          nullable: nullable ?? false,
          defaultTo: defaultTo,
          resType: resType,
          comment: comment,
        ),
      );
    }

    final buffer = StringBuffer();

    // generate abstract interface, to facilitate adding getters to user mixin
    buffer.writeln("mixin ${className}I {");
    for (final e in fields) {
      if (e.comment != null) buffer.writeln("  ${e.comment}");
      buffer.writeln("  ${e.resType}${e.nullable ? '?' : ''} get ${e.name};");
    }
    for (final e in schemas) {
      if (e.comment != null) buffer.writeln("  ${e.comment}");
      buffer.writeln("  ${e.type}${e.required ? '' : '?'} get ${e.name};");
    }
    buffer.writeln("}");

    // generate concrete class
    buffer.writeln();
    // buffer.writeln("@immutable");
    buffer.writeln("class $className with ${className}I, $baseClassName {");

    // add static Schema
    buffer.writeln("");
    buffer.writeln("  static const TableSchema staticSchema = TableSchema(");
    if (annotation.read("ignoreNotInSchema").boolValue) {
      buffer.writeln("    ignoreNotInSchema: true,");
    }
    if (schemas.isNotEmpty) {
      buffer.write("    tables: ");
      _SchemaTableGen.writeMapSchemas(buffer, schemas, baseClassName);
      buffer.writeln(",");
      buffer.write("    canBeMissingSchemas: ");
      _SchemaTableGen.writeCanBeMissingSchemas(buffer, schemas);
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
    if (hasGetSchemaTablesMethod(element)) {
      buffer.writeln("  static TableSchema get schema => TableSchema(");
      buffer.writeln("    tables: {");
      buffer.writeln("      ...staticSchema.tables,");
      buffer.writeln("      ...$baseClassName._getDynamicSchemaTables(),");
      buffer.writeln("    },");
      buffer.writeln("    fields: staticSchema.fields,");
      buffer.writeln("    validator: staticSchema.validator,");
      buffer.writeln("    ignoreNotInSchema: staticSchema.ignoreNotInSchema,");
      buffer.writeln("    canBeMissingSchemas: staticSchema.canBeMissingSchemas,");
      buffer.writeln("  );");
      buffer.writeln("");
    } else {
      buffer.writeln("  static TableSchema get schema => staticSchema;");
    }

    // add field declarations
    buffer.writeln("");
    for (final e in fields) {
      buffer.writeln("  @override");
      buffer.writeln("  final ${e.resType}${e.nullable ? '?' : ''} ${e.name};");
    }

    // add static schema tables as independent variables
    final constructorExtra = StringBuffer();
    final fromMapExtra = StringBuffer();
    if (schemas.isNotEmpty) {
      // TODO: 2 this assumes the resultType is autogenerated with config_gen as well.
      // If it isn't it will have a lot of issues. Maybe we could do some checks to
      // at least fail gracefully ot omit tables not generated with config_gen.
      buffer.writeln("");
      for (final entry in schemas) {
        final name = lowerFirst(entry.name);
        final type = entry.required ? entry.type : "${entry.type}?";
        buffer.writeln("  @override");
        buffer.writeln("  final $type $name;");
        constructorExtra.writeln("    ${entry.required ? 'required' : ''} this.$name,");
        fromMapExtra.writeln("      $name: ${entry.type}.fromMap(map['${entry.name}']),");
      }
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
    if (constructorExtra.isNotEmpty) {
      buffer.writeln(constructorExtra);
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
    if (fromMapExtra.isNotEmpty) {
      buffer.writeln(fromMapExtra);
    }
    buffer.writeln("    );");
    buffer.writeln("  }");

    // write toString method
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.writeln("  String toString() {");
    buffer.write("    return '$className(");
    buffer.write(
      [...fields.map((e) => e.name), ...schemas.map((e) => e.name)].map((name) => "$name = \$$name").join(", "),
    );
    buffer.writeln(")';");
    buffer.writeln("  }");

    // write equality operator
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.writeln("  bool operator==(covariant $className other) {");
    buffer.write("    return ");
    buffer.write(
      [...fields.map((e) => e.name), ...schemas.map((e) => e.name)].map((name) => "$name == other.$name").join(" && "),
    );
    buffer.writeln(";");
    buffer.writeln("  }");

    // write hashMethod
    buffer.writeln("");
    buffer.writeln("  @override");
    buffer.writeln(
      "  int get hashCode => Object.hashAll([${[...fields.map((e) => e.name), ...schemas.map((e) => e.name)].join(', ')}]);",
    );

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
