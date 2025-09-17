/// Mark classes that wants config code generation
class Config {
  /// If this is true then KeyNotInSchemaError will not be emited
  final bool ignoreNotInSchema;

  const Config({this.ignoreNotInSchema = false});
}

/// Mark field to be generated as a nested schema instead of a field
class SchemaTables {
  /// In the annotated field of type [Map<String, Schema>] all keys that are also in [canBeNull]
  /// will be nullable, which means that if the config is missing this key than the field will be null
  final Set<String> canBeNull;

  const SchemaTables({this.canBeNull = const {}});
}


/// Mark field to be generated as a nested schema instead of a field
class SchemaTable {
  final bool required;
  /// use this if the declaration is not in the form of XXXConfig.staticSchema
  final Type? type;

  const SchemaTable({this.type, this.required = true});
}
