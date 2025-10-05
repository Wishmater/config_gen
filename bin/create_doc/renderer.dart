import "package:config_gen/bin/create_doc/models.dart";

class MarkdownRenderer {
  final StringBuffer md;

  MarkdownRenderer() : md = StringBuffer();

  void clear() {
    md.clear();
  }

  void render(List<DocGenBlock> blocks) {
    for (final block in blocks) {
      md.writeln("## ${block.name}".mdSanitize());
      md.writeln(block.description.mdSanitize());

      md.writeln();
      md.writeln("|name|description|type|default|");
      md.writeln("|--|--|--|--|");

      for (final field in block.fields) {
        md.write("|${field.name}|${field.description.replaceAll('\n', '&#10')}".mdSanitize());
        md.writeln("|${stringFromType(field.type)}|${fromDefault(field.defaultTo, field.type.isNullable)}|".mdSanitize());
      }
      md.writeln();
    }
  }

  String fromDefault(String? defaultTo, bool isNullable) {
    if (defaultTo == null) {
      if (isNullable) {
        return "null";
      } else {
        return "";
      }
    }
    if (defaultTo == "") {
      return "<Empty String>";
    }
    return defaultTo;
  }

  String stringFromType(DocGenType type) {
    switch (type) {
      case DocGenTypeBlock():
        return "[${type.reference.name}](#${type.reference.name.replaceAll(' ', '-')})${type.isNullable ? '?' : ''}";
      case DocGenTypeString():
        return type.toString();
      case DocGenTypeBlockIcomplete():
        throw StateError("DocGenTypeBlockIcomplete is an invalid DocGenType when rendering");
    }
  }
}

extension on String {
  String mdSanitize() {
    return replaceAll("<", "\\<").replaceAll(">", "\\>");
  }
}
