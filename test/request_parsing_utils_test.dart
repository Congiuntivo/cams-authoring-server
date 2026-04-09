import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/http/dto/request_parsing_utils.dart';

void main() {
  group('ensureNoUnknownFields', () {
    test('accepts payload with only allowed keys', () {
      expect(
        () => ensureNoUnknownFields(
          <String, dynamic>{
            'name': 'task',
            'description': 'desc',
          },
          const <String>{'name', 'description'},
          'task request body',
        ),
        returnsNormally,
      );
    });

    test('throws FormatException for unknown keys', () {
      expect(
        () => ensureNoUnknownFields(
          <String, dynamic>{
            'name': 'task',
            'unexpected': 1,
          },
          const <String>{'name'},
          'task request body',
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Unsupported field(s) in task request body: unexpected.'),
          ),
        ),
      );
    });
  });

  group('requireNonBlankString', () {
    test('returns trimmed value for valid string', () {
      final value = requireNonBlankString(
        <String, dynamic>{'name': '  my task  '},
        'name',
        context: 'task request body',
      );

      expect(value, 'my task');
    });

    test('throws for missing, blank, or non-string value', () {
      expect(
        () => requireNonBlankString(
          <String, dynamic>{},
          'name',
          context: 'task request body',
        ),
        throwsFormatException,
      );
      expect(
        () => requireNonBlankString(
          <String, dynamic>{'name': '   '},
          'name',
          context: 'task request body',
        ),
        throwsFormatException,
      );
      expect(
        () => requireNonBlankString(
          <String, dynamic>{'name': 42},
          'name',
          context: 'task request body',
        ),
        throwsFormatException,
      );
    });
  });

  group('requireValidUrlString', () {
    test('returns trimmed valid URL', () {
      final value = requireValidUrlString(
        <String, dynamic>{'url': ' https://example.org/path '},
        'url',
        context: 'web task request body',
      );

      expect(value, 'https://example.org/path');
    });

    test('throws for invalid URL', () {
      expect(
        () => requireValidUrlString(
          <String, dynamic>{'url': 'not-a-url'},
          'url',
          context: 'web task request body',
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Invalid URL in web task request body. Use a valid URL.'),
          ),
        ),
      );
    });
  });

  group('parseOptionalString', () {
    test('returns null for null and trimmed string for string', () {
      expect(
        parseOptionalString(
          null,
          'name',
          context: 'task request body',
        ),
        isNull,
      );
      expect(
        parseOptionalString(
          '  value  ',
          'name',
          context: 'task request body',
        ),
        'value',
      );
    });

    test('throws for non-string value', () {
      expect(
        () => parseOptionalString(
          7,
          'name',
          context: 'task request body',
        ),
        throwsFormatException,
      );
    });
  });

  group('parseOptionalInt', () {
    test('returns null for null and int for int', () {
      expect(
        parseOptionalInt(
          null,
          'intervalSeconds',
          context: 'task request body',
        ),
        isNull,
      );
      expect(
        parseOptionalInt(
          30,
          'intervalSeconds',
          context: 'task request body',
        ),
        30,
      );
    });

    test('throws for non-int numerics and strings', () {
      expect(
        () => parseOptionalInt(
          30.0,
          'intervalSeconds',
          context: 'task request body',
        ),
        throwsFormatException,
      );
      expect(
        () => parseOptionalInt(
          '30',
          'intervalSeconds',
          context: 'task request body',
        ),
        throwsFormatException,
      );
    });
  });

  group('parseOptionalDouble', () {
    test('returns null for null and double for numeric values', () {
      expect(
        parseOptionalDouble(
          null,
          'distance',
          context: 'location request body',
        ),
        isNull,
      );
      expect(
        parseOptionalDouble(
          10,
          'distance',
          context: 'location request body',
        ),
        10.0,
      );
      expect(
        parseOptionalDouble(
          10.5,
          'distance',
          context: 'location request body',
        ),
        10.5,
      );
    });

    test('throws for non-numeric values', () {
      expect(
        () => parseOptionalDouble(
          '10.5',
          'distance',
          context: 'location request body',
        ),
        throwsFormatException,
      );
    });
  });

  group('parseOptionalBool', () {
    test('returns null for null and bool for bool', () {
      expect(
        parseOptionalBool(
          null,
          'isOptional',
          context: 'device request body',
        ),
        isNull,
      );
      expect(
        parseOptionalBool(
          true,
          'isOptional',
          context: 'device request body',
        ),
        isTrue,
      );
    });

    test('throws for non-bool values', () {
      expect(
        () => parseOptionalBool(
          'true',
          'isOptional',
          context: 'device request body',
        ),
        throwsFormatException,
      );
    });
  });
}
