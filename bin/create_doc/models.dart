class DocGenBlock {
  final String name;
  final String className;
  final String description;
  final List<DocGenField> fields;

  const DocGenBlock(this.name, this.className, this.description, this.fields);

  @override
  String toString() {
    return name;
  }
}

class DocGenField {
  String name;
  String description;
  DocGenType type;
  String? defaultTo;

  DocGenField({required this.name, required this.description, required this.type, required this.defaultTo});
}

sealed class DocGenType {
  bool get isNullable;
}

class DocGenTypeBlock extends DocGenType {
  final DocGenBlock reference;
  @override
  final bool isNullable;

  DocGenTypeBlock(this.reference, this.isNullable);
}

class DocGenTypeBlockIcomplete extends DocGenType {
  late final String className;
  @override
  late final bool isNullable;

  DocGenTypeBlockIcomplete(String className) {
    if (className.endsWith("?")) {
      this.className = className.substring(0, className.length - 1);
      isNullable = true;
    } else {
      this.className = className;
      isNullable = false;
    }
  }

  DocGenTypeBlock complete(List<DocGenBlock> blocks) {
    for (final block in blocks) {
      if (block.className == className) {
        return DocGenTypeBlock(block, isNullable);
      }
    }
    throw StateError("block $className not found in ${blocks.join('\t')}");
  }
}

class DocGenTypeString extends DocGenType {
  final String type;
  DocGenTypeString(this.type);

  @override
  bool get isNullable => type.endsWith("?");

  @override
  String toString() {
    return type;
  }
}
