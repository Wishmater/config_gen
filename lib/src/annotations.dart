/// Mark classes that wants config code generation
class Config {
  /// If this is true then KeyNotInSchemaError will not be emited
  final bool ignoreNotInSchema;

  const Config({this.ignoreNotInSchema = false});
}

/// Mark field to be generated as a nested schema instead of a field
class SchemaFieldAnnot {
  final bool required;

  final bool allowMultiple;

  /// use this if the declaration is not in the form of XXXConfig.staticSchema
  final Type? type;

  const SchemaFieldAnnot({this.type, this.required = true, this.allowMultiple = false});
}

bool configListEqual<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;

  if (a.length !=  b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
