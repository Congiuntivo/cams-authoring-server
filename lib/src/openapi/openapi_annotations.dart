class ApiController {
  const ApiController({
    required this.title,
    required this.version,
    this.description,
    this.schemas = const <ApiSchemaDoc>[],
    this.sharedParameters = const <ApiSharedParameterDoc>[],
    this.sharedResponses = const <ApiSharedResponseDoc>[],
    this.tags = const <ApiTagDoc>[],
  });

  final String title;
  final String version;
  final String? description;
  final List<ApiSchemaDoc> schemas;
  final List<ApiSharedParameterDoc> sharedParameters;
  final List<ApiSharedResponseDoc> sharedResponses;
  final List<ApiTagDoc> tags;
}

class ApiTagDoc {
  const ApiTagDoc({required this.name, required this.description});

  final String name;
  final String description;
}

class ApiSchemas {
  const ApiSchemas({
    this.schemas = const <ApiSchemaDoc>[],
  });

  final List<ApiSchemaDoc> schemas;
}

class ApiOperation {
  const ApiOperation({
    required this.method,
    required this.path,
    required this.summary,
    required this.operationId,
    this.description,
    this.tags = const <String>[],
    this.parameters = const <ApiParameterDoc>[],
    this.sharedParameterRefs = const <String>[],
    this.requestBody,
    this.responses = const <ApiResponseDoc>[],
    this.sharedResponseRefs = const <String>[],
  });

  final String method;
  final String path;
  final String summary;
  final String operationId;
  final String? description;
  final List<String> tags;
  final List<ApiParameterDoc> parameters;
  final List<String> sharedParameterRefs;
  final ApiRequestBodyDoc? requestBody;
  final List<ApiResponseDoc> responses;
  final List<String> sharedResponseRefs;
}

class ApiRequestBodyDoc {
  const ApiRequestBodyDoc({
    required this.schemaRef,
    this.description,
    this.required = true,
    this.example,
  });

  final String schemaRef;
  final String? description;
  final bool required;
  final Object? example;
}

class ApiParameterDoc {
  const ApiParameterDoc({
    required this.name,
    required this.location,
    required this.type,
    this.required = false,
    this.description,
    this.example,
    this.enumValues = const <String>[],
  });

  final String name;
  final String location;
  final String type;
  final bool required;
  final String? description;
  final String? example;
  final List<String> enumValues;
}

// A parameter defined once in @ApiController.sharedParameters and referenced
// in @ApiOperation.sharedParameterRefs by name. The name field is used as
// both the OpenAPI parameter name and the components.parameters key.
class ApiSharedParameterDoc extends ApiParameterDoc {
  const ApiSharedParameterDoc({
    required super.name,
    required super.location,
    required super.type,
    super.required = false,
    super.description,
    super.example,
    super.enumValues = const <String>[],
  });
}

// A response defined once in @ApiController.sharedResponses and referenced
// in @ApiOperation.sharedResponseRefs by name.
class ApiSharedResponseDoc {
  const ApiSharedResponseDoc({
    required this.name,
    required this.statusCode,
    required this.description,
    this.schemaRef,
  });

  // Components key and $ref target name.
  final String name;
  // HTTP status code string (e.g. '404') or 'default'.
  final String statusCode;
  final String description;
  final String? schemaRef;
}

class ApiResponseDoc {
  const ApiResponseDoc({
    required this.statusCode,
    required this.description,
    this.schemaRef,
  });

  final int statusCode;
  final String description;
  final String? schemaRef;
}

class ApiSchemaDoc {
  const ApiSchemaDoc({
    required this.name,
    this.type = 'object',
    this.required = const <String>[],
    this.properties = const <ApiPropertyDoc>[],
    this.enumValues = const <String>[],
    this.allOfRefs = const <String>[],
  });

  final String name;
  final String type;
  final List<String> required;
  final List<ApiPropertyDoc> properties;
  // When non-empty, emits a top-level enum schema instead of an object.
  final List<String> enumValues;
  // When non-empty, emits an allOf schema composing these $ref targets with
  // the inline properties defined on this schema.
  final List<String> allOfRefs;
}

class ApiPropertyDoc {
  const ApiPropertyDoc({
    required this.name,
    this.type,
    this.ref,
    this.itemsType,
    this.itemsRef,
    this.enumValues = const <String>[],
    this.example,
    this.required = false,
    this.format,
    this.pattern,
    this.minimum,
    this.additionalProperties = false,
  }) : assert(type != null || ref != null,
            'Either type or ref must be provided for ApiPropertyDoc.');

  final String name;
  final String? type;
  final String? ref;
  final String? itemsType;
  final String? itemsRef;
  final List<String> enumValues;
  final Object? example;
  final bool required;
  final String? format;
  final String? pattern;
  final int? minimum;
  // Emits additionalProperties: true for dynamic/polymorphic object payloads.
  final bool additionalProperties;
}
