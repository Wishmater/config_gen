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
