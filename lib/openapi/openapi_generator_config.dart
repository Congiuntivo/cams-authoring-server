// ignore_for_file: depend_on_referenced_packages

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  inputSpec: InputSpec(path: 'openapi/openapi.yaml'),
  generatorName: Generator.dio,
  outputDirectory: 'lib/src/generated/openapi',
  fetchDependencies: false,
  runSourceGenOnOutput: false,
  skipIfSpecIsUnchanged: true,
  forceAlwaysRun: false,
)
class OpenapiGeneratorConfig {}
