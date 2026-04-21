import 'dart:io';

import 'package:yaml/yaml.dart';

const String _openApiSpecPath = 'openapi/openapi.yaml';

String openApiYaml() => File(_openApiSpecPath).readAsStringSync();

Map<String, dynamic> buildOpenApiSpec({required String serverUrl}) {
  final yaml = loadYaml(openApiYaml());
  if (yaml is! YamlMap) {
    throw const FormatException('OpenAPI YAML root must be a mapping/object.');
  }

  final spec = _toJsonCompatible(yaml) as Map<String, dynamic>;
  spec['servers'] = <Map<String, dynamic>>[
    <String, dynamic>{'url': serverUrl}
  ];

  return spec;
}

dynamic _toJsonCompatible(dynamic value) {
  if (value is YamlMap) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key.toString(): _toJsonCompatible(entry.value),
    };
  }
  if (value is YamlList) {
    return value.map(_toJsonCompatible).toList();
  }
  return value;
}

String swaggerUiHtml() => '''
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Study Protocol Authoring API Docs</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js" crossorigin></script>
    <script>
      window.ui = SwaggerUIBundle({
        url: '/openapi.json',
        dom_id: '#swagger-ui',
        deepLinking: true,
        displayRequestDuration: true,
      });
    </script>
  </body>
</html>
''';
