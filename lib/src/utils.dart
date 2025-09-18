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
