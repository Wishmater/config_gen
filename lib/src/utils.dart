import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/ast/visitor.dart";
import "package:analyzer/dart/constant/value.dart";
import "package:analyzer/dart/element/element2.dart";
import "package:analyzer/dart/element/type.dart";

bool hasGetSchemaTablesMethod(MixinElement2 classElement) {
  final method = classElement.getMethod2("_getDynamicSchemaTables");
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

bool hasValidatorMethod(MixinElement2 classElement) {
  final method = classElement.getMethod2("_validator");
  if (method == null || !method.isStatic || method.formalParameters.length != 2) {
    return false;
  }
  if (!method.formalParameters[0].type.isDartCoreMap || !method.formalParameters[1].type.isDartCoreList) {
    return false;
  }
  return true;
}

String lowerFirst(String str) {
  if (str.isEmpty) return str;
  return str[0].toLowerCase() + str.substring(1);
}


(bool, T?) isFieldAnnotatedWith<T>(FieldElement2 field, String name, T Function(DartObject, FieldElement2) transform) {
  final index = field.metadata2.annotations.indexWhere((annot) => annot.element2?.displayName == name);
  final isAnnotated = index != -1;
  if (isAnnotated) {
    final object = field.metadata2.annotations[index].computeConstantValue()!;
    return (isAnnotated, transform(object, field));
  }
  return (isAnnotated, null);
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

String unprivate(String string) {
  while (string.startsWith("_")) {
    string = string.substring(1);
  }
  return string;
}


class FieldData {
  String name;
  bool nullable;
  String? defaultTo;
  DartType? resType;
  String? comment;
  FieldData({
    required this.name,
    required this.nullable,
    required this.defaultTo,
    required this.resType,
    required this.comment,
  });
  bool get isRequired => !nullable && defaultTo == null;
}

class SchemaTableGen {
  final String _name;

  String get fieldName => lowerFirst(_name);
  String get schemaName => _name;

  final bool required;

  final String type;

  final String? comment;

  SchemaTableGen(this._name, this.type, this.required, this.comment);

  factory SchemaTableGen.from(DartObject object, FieldElement2 field) {
    String? type = object.getField("type")?.toTypeValue()?.element3?.name3;
    if (type == null) {
      final initializer = field.constantInitializer!.toSource();
      // awful hack
      type = initializer.substring(0, initializer.indexOf("."));
    }
    return SchemaTableGen(
      unprivate(field.name3!),
      type,
      object.getField("required")!.toBoolValue()!,
      field.documentationComment,
    );
  }

  static void writeMapSchemas(StringBuffer buffer, List<SchemaTableGen> schemas, String baseClassName) {
    buffer.writeln("{");
    for (final schema in schemas) {
      buffer.write("'${schema._name}': ");
      buffer.writeln("$baseClassName._${schema._name},");
    }
    buffer.write("}");
  }

  static void writeCanBeMissingSchemas(StringBuffer buffer, List<SchemaTableGen> schemas) {
    buffer.writeln("{");
    for (final schema in schemas) {
      if (!schema.required) buffer.writeln("'${schema._name}',");
    }
    buffer.write("}");
  }
}
