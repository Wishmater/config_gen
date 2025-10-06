import "dart:io";

import "package:analyzer/dart/constant/value.dart";
import "package:args/args.dart";
import "package:logging/logging.dart";
import "package:analyzer/dart/analysis/analysis_context_collection.dart";
import "package:analyzer/dart/analysis/results.dart";
import "package:analyzer/dart/ast/ast.dart";
import "package:analyzer/dart/element/element2.dart";
import "./create_doc/renderer.dart";
import "./create_doc/models.dart";
import "./create_doc/resource_provider.dart";

Logger logger = Logger("CREATE_DOC");

void main(List<String> args) async {
  final argParser = ArgParser()..addFlag("verbose", abbr: "v");
  final argResult = argParser.parse(args);
  hierarchicalLoggingEnabled = true;
  logger.level = switch (argResult.flag("verbose")) {
    true => Level.ALL,
    false => Level.WARNING,
  };
  logger.onRecord.listen((record) {
    stderr.write(record);
    stderr.write("\n");
  });

  final projectRoot = Directory.current.path;
  logger.info("Project root $projectRoot");

  final resoureceLogger = Logger("RESOURCE")..level = logger.level;
  resoureceLogger.onRecord.listen((record) {
    stderr.write(record);
    stderr.write("\n");
  });
  final collection = AnalysisContextCollection(
    includedPaths: [projectRoot],
    resourceProvider: PhysicalResourceProvider(logger: resoureceLogger),
  );

  final mdContent = StringBuffer()
    ..writeln("# Configuration Classes")
    ..writeln()
    ..writeln("This document lists all configuration classes marked with `@Config()`.")
    ..writeln();

  // Find all Dart files
  final dartFiles = _findDartFiles(Directory(projectRoot));

  final blocks = <DocGenBlock>[];
  for (final file in dartFiles) {
    logger.fine("Search context for ${file.path}");
    final context = collection.contextFor(file.path);
    final resolved = await context.currentSession.getResolvedUnit(file.path);

    if (resolved is ResolvedUnitResult) {
      final mixins = _findConfigClasses(resolved.unit);
      for (final mixinDecl in mixins) {
        blocks.add(_generateClassDocumentation(mixinDecl));
      }
    }
  }
  for (final block in blocks) {
    for (final field in block.fields) {
      if (field.type is DocGenTypeBlockIcomplete) {
        field.type = (field.type as DocGenTypeBlockIcomplete).complete(blocks);
      }
    }
  }
  final reneder = MarkdownRenderer();
  reneder.render(blocks);
  mdContent.write(reneder.md.toString());

  // Write to markdown file
  File("CONFIGURATION.md").writeAsStringSync(mdContent.toString());
  print("✅ Generated CONFIGURATION.md");
}

DocGenBlock _generateClassDocumentation((ClassDeclaration, MixinDeclaration) decls) {
  final classDecl = decls.$1;
  final mixinDecl = decls.$2;
  // Add class documentation if available
  final description = _getDocumentationComment(mixinDecl);

  final fields = <DocGenField>[];
  for (final member in mixinDecl.members) {
    if (member is MethodDeclaration && member.isGetter) {
      final element = member.returnType?.type?.element3;
      DocGenType type;
      if (element is ClassElement2) {
        if (element.allSupertypes.any((e) => e.getDisplayString() == "ConfigBaseI")) {
          type = DocGenTypeBlockIcomplete(member.returnType!.toString());
        } else {
          type = DocGenTypeString(member.returnType!.toString());
        }
      } else {
        type = DocGenTypeString(member.returnType!.toString());
      }
      final defaultAnnotIdx = member.metadata.indexWhere((e) => e.name.name == "ConfigDocDefault");
      String? defaultTo;
      if (defaultAnnotIdx != -1) {
        final defaultsField = member.metadata[defaultAnnotIdx].elementAnnotation!.computeConstantValue()!.getField(
          "defaults",
        );
        try {
          defaultTo = valueOfDartObject(defaultsField!);
        } catch (_) {
          defaultTo = member.metadata[defaultAnnotIdx].arguments!.arguments[0].toSource();
        }
      }
      fields.add(
        DocGenField(
          name: member.name.toString(),
          type: type,
          description: getDoc(member.documentationComment),
          defaultTo: defaultTo,
        ),
      );
    }
  }
  final blockName = (classDecl.withClause!.mixinTypes.last.element2 as MixinElement2).metadata2.annotations[0]
      .computeConstantValue()!
      .getField("documentationName")!
      .toStringValue();
  return DocGenBlock(blockName ?? classDecl.name.toString(), classDecl.name.toString(), description, fields);
}

String _getDocumentationComment(MixinDeclaration mixinDecl) {
  final documentationComment = mixinDecl.documentationComment;
  if (documentationComment != null) {
    return documentationComment.tokens.map((token) => token.toString().replaceAll("///", "").trim()).join("\n").trim();
  }
  return "";
}

List<(ClassDeclaration, MixinDeclaration)> _findConfigClasses(CompilationUnit unit) {
  return unit.declarations
      .whereType<ClassDeclaration>()
      .where((classDecl) {
        return classDecl.extendsClause?.superclass.toString() == "ConfigBaseI";
      })
      .map((classDecl) {
        return (
          classDecl,
          unit.declarations
              .whereType<MixinDeclaration>()
              .where((mixin) => mixin.name.toString() == classDecl.withClause!.mixinTypes.first.name2.toString())
              .first,
        );
      })
      .toList();
}

List<File> _findDartFiles(Directory directory) {
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith(".config.dart"))
      .where((file) => !file.path.contains(".dart_tool"))
      .where((file) => !file.path.contains("packages"))
      .toList();
}

String getDoc(Comment? comment) {
  if (comment == null) {
    return "";
  }
  String commentStr = comment.tokens.map((e) => e.toString()).join("");
  commentStr = commentStr.trim();
  if (commentStr.startsWith("///")) {
    commentStr = commentStr.substring(3);
  }
  return commentStr.replaceAll("///", "\n");
}

String valueOfDartObject(DartObject object) {
  if (!object.hasKnownValue) {
    throw "invalid";
  }
  if (object.isNull) {
    return "null";
  }
  final map = <Object? Function(), dynamic>{
    object.toBoolValue: (bool v) => v ? "true" : "false",
    object.toDoubleValue: (double v) => v.toStringAsFixed(2),
    object.toIntValue: (int v) => v.toString(),
    object.toStringValue: (String v) => '"$v"',
    object.toSetValue: (Set<DartObject> v) {
      final buffer = StringBuffer();
      buffer.write("{ ");
      for (final e in v) {
        buffer.write(valueOfDartObject(e));
        if (e != v.last) {
          buffer.write(", ");
        } else {
          buffer.write(" ");
        }
      }
      buffer.write("}");
      return buffer.toString();
    },
    object.toListValue: (List<DartObject> v) {
      final buffer = StringBuffer();
      buffer.write("[ ");
      for (final e in v) {
        buffer.write(valueOfDartObject(e));
        if (e != v.last) {
          buffer.write(", ");
        } else {
          buffer.write(" ");
        }
      }
      buffer.write("]");
      return buffer.toString();
    },
    object.toMapValue: (Map<DartObject, DartObject> v) {
      final buffer = StringBuffer();
      buffer.write("{ ");
      for (final e in v.entries) {
        buffer.write(valueOfDartObject(e.key));
        buffer.write(": ");
        buffer.write(valueOfDartObject(e.value));
        buffer.write(", ");
      }
      buffer.write("}");
      return buffer.toString();
    },
    object.toRecordValue: (({Map<String, DartObject> named, List<DartObject> positional}) v) {
      final buffer = StringBuffer();
      buffer.write("( ");
      for (final e in v.positional) {
        buffer.write(valueOfDartObject(e));
        buffer.write(", ");
      }
      for (final e in v.named.entries) {
        buffer.write("${e.key}: ");
        buffer.write(valueOfDartObject(e.value));
        buffer.write(", ");
      }
      buffer.write(")");
      return buffer.toString();
    },
  };

  for (final e in map.entries) {
    final v = e.key();
    if (v == null) continue;
    return e.value(v);
  }
  throw "invalid";
}
