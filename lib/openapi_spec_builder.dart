// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/openapi_annotations.dart';

Builder openApiSpecBuilder(BuilderOptions options) =>
    _OpenApiSpecBuilder(const _OpenApiSpecGenerator());

class _OpenApiSpecBuilder implements Builder {
  _OpenApiSpecBuilder(this._generator);

  final _OpenApiSpecGenerator _generator;

  @override
  final Map<String, List<String>> buildExtensions =
      const <String, List<String>>{
    'lib/src/http/handlers/authoring_routes.dart': <String>[
      'openapi/openapi.yaml'
    ],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final library = await buildStep.resolver.libraryFor(buildStep.inputId);
    final output = await _generator.generate(LibraryReader(library), buildStep);
    if (output == null || output.trim().isEmpty) {
      return;
    }

    final outputId = AssetId(buildStep.inputId.package, 'openapi/openapi.yaml');
    await buildStep.writeAsString(outputId, output);
  }
}

class _OpenApiSpecGenerator extends Generator {
  const _OpenApiSpecGenerator();

  static const TypeChecker _controllerChecker =
      TypeChecker.fromRuntime(ApiController);
  static const TypeChecker _operationChecker =
      TypeChecker.fromRuntime(ApiOperation);

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) {
    for (final classElement in library.classes) {
      final controllerAnnotation = _controllerChecker.firstAnnotationOf(
        classElement,
        throwOnUnresolved: false,
      );
      if (controllerAnnotation == null) {
        continue;
      }

      final controller = ConstantReader(controllerAnnotation);
      final title = controller.read('title').stringValue;
      final version = controller.read('version').stringValue;
      final descriptionReader = controller.read('description');
      final description =
          descriptionReader.isNull ? null : descriptionReader.stringValue;

      final schemas = controller
          .read('schemas')
          .listValue
          .map(_readSchema)
          .toList(growable: false);

      final operations = _controllerMethods(classElement)
          .map((MethodElement method) => _operationChecker
              .firstAnnotationOf(method, throwOnUnresolved: false))
          .whereType<DartObject>()
          .map((DartObject object) => _readOperation(ConstantReader(object)))
          .toList(growable: false);

      if (operations.isEmpty) {
        throw InvalidGenerationSourceError(
          'ApiController requires at least one @ApiOperation method.',
          element: classElement,
        );
      }

      final spec = <String, Object?>{
        'openapi': '3.0.3',
        'info': <String, Object?>{
          'title': title,
          'version': version,
          if (description != null) 'description': description,
        },
        'servers': <Map<String, String>>[
          <String, String>{'url': 'http://localhost:8080'}
        ],
        'paths': _buildPaths(operations),
        if (schemas.isNotEmpty)
          'components': <String, Object?>{
            'schemas': <String, Object?>{
              for (final schema in schemas)
                schema['name']! as String: <String, Object?>{
                  'type': schema['type']! as String,
                  if ((schema['required']! as List<String>).isNotEmpty)
                    'required': schema['required']! as List<String>,
                  'properties': <String, Object?>{
                    for (final property
                        in schema['properties']! as List<Map<String, Object?>>)
                      property['name']! as String: _toPropertySchema(property),
                  },
                },
            },
          },
      };

      return _toYaml(spec);
    }

    return null;
  }

  static Iterable<MethodElement> _controllerMethods(
      ClassElement classElement) sync* {
    yield* classElement.methods;
    for (final mixinType in classElement.mixins) {
      final mixinElement = mixinType.element;
      yield* mixinElement.methods;
    }
  }

  static Map<String, Object?> _toPropertySchema(Map<String, Object?> property) {
    final schema = <String, Object?>{};
    if (property['ref'] != null) {
      schema[r'$ref'] = '#/components/schemas/${property['ref']}';
      return schema;
    }

    schema['type'] = property['type'] as String;

    final enumValues = property['enumValues']! as List<String>;
    if (enumValues.isNotEmpty) {
      schema['enum'] = enumValues;
    }

    if (property['example'] != null) {
      schema['example'] = property['example'];
    }

    if (property['type'] == 'array') {
      final itemsRef = property['itemsRef'] as String?;
      final itemsType = property['itemsType'] as String?;
      if (itemsRef != null) {
        schema['items'] = <String, String>{
          r'$ref': '#/components/schemas/$itemsRef',
        };
      } else {
        // OpenAPI arrays must define "items". Default to object for flexible payloads.
        schema['items'] = <String, String>{'type': itemsType ?? 'object'};
      }
    }

    return schema;
  }

  static Map<String, Map<String, Object?>> _buildPaths(
      List<Map<String, Object?>> operations) {
    final paths = <String, Map<String, Object?>>{};

    for (final operation in operations) {
      final path = operation['path']! as String;
      final method = (operation['method']! as String).toLowerCase();
      paths.putIfAbsent(path, () => <String, Object?>{});

      final operationSpec = <String, Object?>{
        'summary': operation['summary']! as String,
        'operationId': operation['operationId']! as String,
        if (operation['description'] != null)
          'description': operation['description'],
        if ((operation['parameters']! as List<Map<String, Object?>>).isNotEmpty)
          'parameters': (operation['parameters']! as List<Map<String, Object?>>)
              .map((Map<String, Object?> parameter) {
            final schema = <String, Object?>{
              'type': parameter['type']! as String,
              if (parameter['example'] != null)
                'example': parameter['example']! as String,
            };

            final enumValues = parameter['enumValues']! as List<String>;
            if (enumValues.isNotEmpty) {
              schema['enum'] = enumValues;
            }

            return <String, Object?>{
              'name': parameter['name']! as String,
              'in': parameter['location']! as String,
              'required': parameter['required']! as bool,
              if (parameter['description'] != null)
                'description': parameter['description']! as String,
              'schema': schema,
            };
          }).toList(growable: false),
        if (operation['requestBody'] != null)
          'requestBody': _buildRequestBody(
            operation['requestBody']! as Map<String, Object?>,
          ),
        'responses': <String, Object?>{},
      };

      final responses = operation['responses']! as List<Map<String, Object?>>;
      for (final response in responses) {
        final statusCode = (response['statusCode']! as int).toString();
        final responseSpec = <String, Object?>{
          'description': response['description']! as String,
        };

        final schemaRef = response['schemaRef'] as String?;
        if (schemaRef != null) {
          responseSpec['content'] = <String, Object?>{
            'application/json': <String, Object?>{
              'schema': <String, String>{
                r'$ref': '#/components/schemas/$schemaRef',
              },
            },
          };
        }

        (operationSpec['responses']! as Map<String, Object?>)[statusCode] =
            responseSpec;
      }

      paths[path]![method] = operationSpec;
    }

    return paths;
  }

  static Map<String, Object?> _readOperation(ConstantReader reader) {
    return <String, Object?>{
      'method': reader.read('method').stringValue,
      'path': reader.read('path').stringValue,
      'summary': reader.read('summary').stringValue,
      'operationId': reader.read('operationId').stringValue,
      'description': reader.read('description').isNull
          ? null
          : reader.read('description').stringValue,
      'parameters': reader
          .read('parameters')
          .listValue
          .map((DartObject object) => _readParameter(ConstantReader(object)))
          .toList(growable: false),
      'requestBody': reader.read('requestBody').isNull
          ? null
          : _readRequestBody(
              ConstantReader(reader.read('requestBody').objectValue)),
      'responses': reader
          .read('responses')
          .listValue
          .map((DartObject object) => _readResponse(ConstantReader(object)))
          .toList(growable: false),
    };
  }

  static Map<String, Object?> _readRequestBody(ConstantReader reader) {
    return <String, Object?>{
      'schemaRef': reader.read('schemaRef').stringValue,
      'description': reader.read('description').isNull
          ? null
          : reader.read('description').stringValue,
      'required': reader.read('required').boolValue,
      'example': reader.read('example').isNull
          ? null
          : _normalizeLiteralValue(reader.read('example').literalValue),
    };
  }

  static Object? _normalizeLiteralValue(Object? value) {
    if (value is DartObject) {
      return _normalizeDartObjectValue(value);
    }

    if (value is Map<Object?, Object?>) {
      return <String, Object?>{
        for (final entry in value.entries)
          _normalizeMapKey(entry.key): _normalizeLiteralValue(entry.value),
      };
    }

    if (value is List<Object?>) {
      return value.map(_normalizeLiteralValue).toList(growable: false);
    }

    return value;
  }

  static Object? _normalizeDartObjectValue(DartObject value) {
    final map = value.toMapValue();
    if (map != null) {
      return <String, Object?>{
        for (final entry in map.entries)
          _normalizeMapKey(entry.key): _normalizeLiteralValue(entry.value),
      };
    }

    final list = value.toListValue();
    if (list != null) {
      return list.map(_normalizeLiteralValue).toList(growable: false);
    }

    final stringValue = value.toStringValue();
    if (stringValue != null) return stringValue;

    final boolValue = value.toBoolValue();
    if (boolValue != null) return boolValue;

    final intValue = value.toIntValue();
    if (intValue != null) return intValue;

    final doubleValue = value.toDoubleValue();
    if (doubleValue != null) return doubleValue;

    return value.toString();
  }

  static String _normalizeMapKey(Object? key) {
    if (key is String) {
      return key;
    }

    if (key is DartObject) {
      final asString = key.toStringValue();
      if (asString != null) {
        return asString;
      }
    }

    return key.toString();
  }

  static Map<String, Object?> _buildRequestBody(
      Map<String, Object?> requestBody) {
    final schemaRef = requestBody['schemaRef']! as String;

    final contentSchema = <String, Object?>{
      'schema': <String, String>{
        r'$ref': '#/components/schemas/$schemaRef',
      },
    };

    if (requestBody['example'] != null) {
      contentSchema['example'] = requestBody['example'];
    }

    return <String, Object?>{
      if (requestBody['description'] != null)
        'description': requestBody['description'],
      'required': requestBody['required']! as bool,
      'content': <String, Object?>{
        'application/json': contentSchema,
      },
    };
  }

  static Map<String, Object?> _readParameter(ConstantReader reader) {
    return <String, Object?>{
      'name': reader.read('name').stringValue,
      'location': reader.read('location').stringValue,
      'type': reader.read('type').stringValue,
      'required': reader.read('required').boolValue,
      'description': reader.read('description').isNull
          ? null
          : reader.read('description').stringValue,
      'example': reader.read('example').isNull
          ? null
          : reader.read('example').stringValue,
      'enumValues': reader
          .read('enumValues')
          .listValue
          .map((DartObject value) => value.toStringValue()!)
          .toList(growable: false),
    };
  }

  static Map<String, Object?> _readResponse(ConstantReader reader) {
    return <String, Object?>{
      'statusCode': reader.read('statusCode').intValue,
      'description': reader.read('description').stringValue,
      'schemaRef': reader.read('schemaRef').isNull
          ? null
          : reader.read('schemaRef').stringValue,
    };
  }

  static Map<String, Object?> _readSchema(DartObject object) {
    final reader = ConstantReader(object);
    return <String, Object?>{
      'name': reader.read('name').stringValue,
      'type': reader.read('type').stringValue,
      'required': reader
          .read('required')
          .listValue
          .map((DartObject value) => value.toStringValue()!)
          .toList(growable: false),
      'properties': reader
          .read('properties')
          .listValue
          .map((DartObject value) => _readProperty(ConstantReader(value)))
          .toList(growable: false),
    };
  }

  static Map<String, Object?> _readProperty(ConstantReader reader) {
    return <String, Object?>{
      'name': reader.read('name').stringValue,
      'type':
          reader.read('type').isNull ? null : reader.read('type').stringValue,
      'ref': reader.read('ref').isNull ? null : reader.read('ref').stringValue,
      'itemsType': reader.read('itemsType').isNull
          ? null
          : reader.read('itemsType').stringValue,
      'itemsRef': reader.read('itemsRef').isNull
          ? null
          : reader.read('itemsRef').stringValue,
      'enumValues': reader
          .read('enumValues')
          .listValue
          .map((DartObject value) => value.toStringValue()!)
          .toList(growable: false),
      'example': reader.read('example').isNull
          ? null
          : reader.read('example').literalValue,
      'required': reader.read('required').boolValue,
    };
  }

  static String _toYaml(Object? value, {int indent = 0}) {
    final prefix = '  ' * indent;

    if (value is Map<String, Object?>) {
      final lines = <String>[];
      for (final entry in value.entries) {
        if (_isPrimitive(entry.value)) {
          lines.add('$prefix${entry.key}: ${_formatPrimitive(entry.value)}');
          continue;
        }

        lines.add('$prefix${entry.key}:');
        lines.add(_toYaml(entry.value, indent: indent + 1));
      }
      return lines.join('\n');
    }

    if (value is List<Object?>) {
      if (value.isEmpty) {
        return '$prefix[]';
      }

      final lines = <String>[];
      for (final item in value) {
        if (_isPrimitive(item)) {
          lines.add('$prefix- ${_formatPrimitive(item)}');
        } else if (item is Map<String, Object?> && item.isEmpty) {
          lines.add('$prefix- {}');
        } else {
          lines.add('$prefix-');
          lines.add(_toYaml(item, indent: indent + 1));
        }
      }
      return lines.join('\n');
    }

    return '$prefix${_formatPrimitive(value)}';
  }

  static bool _isPrimitive(Object? value) =>
      value == null || value is String || value is num || value is bool;

  static String _formatPrimitive(Object? value) {
    if (value == null) {
      return 'null';
    }
    if (value is String) {
      final escaped = value.replaceAll("'", "''");
      return "'$escaped'";
    }
    if (value is bool || value is num) {
      return value.toString();
    }

    throw ArgumentError(
        'Unsupported YAML primitive type: ${value.runtimeType}');
  }
}
