class ApiController {
  const ApiController({
    required this.title,
    required this.version,
    this.description,
    this.schemas = const <ApiSchemaDoc>[],
  });

  final String title;
  final String version;
  final String? description;
  final List<ApiSchemaDoc> schemas;
}

class ApiOperation {
  const ApiOperation({
    required this.method,
    required this.path,
    required this.summary,
    required this.operationId,
    this.description,
    this.responses = const <ApiResponseDoc>[],
  });

  final String method;
  final String path;
  final String summary;
  final String operationId;
  final String? description;
  final List<ApiResponseDoc> responses;
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
  });

  final String name;
  final String type;
  final List<String> required;
  final List<ApiPropertyDoc> properties;
}

class ApiPropertyDoc {
  const ApiPropertyDoc({
    required this.name,
    this.type,
    this.ref,
    this.enumValues = const <String>[],
    this.example,
    this.required = false,
  }) : assert(type != null || ref != null,
            'Either type or ref must be provided for ApiPropertyDoc.');

  final String name;
  final String? type;
  final String? ref;
  final List<String> enumValues;
  final Object? example;
  final bool required;
}
