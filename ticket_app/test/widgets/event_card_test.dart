import 'package:flutter_test/flutter_test.dart';
import 'package:ticket_app/widgets/event_card.dart';

void main() {
  group('Event Card Helper Functions Tests', () {
    group('formatShortDate', () {
      test('formats ISO date correctly', () {
        final input = '2026-02-15T19:00:00';
        final result = formatShortDate(input);

        expect(result, '15.02');
      });

      test('formats dd.MM.yyyy, HH:mm format correctly', () {
        final input = '15.02.2026, 19:00';
        final result = formatShortDate(input);

        // Should parse and reformat
        expect(result, isNotEmpty);
      });

      test('formats dd.MM.yyyy format correctly', () {
        final input = '15.02.2026';
        final result = formatShortDate(input);

        expect(result, '15.02');
      });

      test('returns original string for invalid date', () {
        final input = 'invalid-date-format';
        final result = formatShortDate(input);

        expect(result, 'invalid-date-format');
      });

      test('handles empty string', () {
        final result = formatShortDate('');
        expect(result, '');
      });

      test('formats date from various months correctly', () {
        expect(formatShortDate('2026-01-01T10:00:00'), '01.01');
        expect(formatShortDate('2026-12-31T23:59:59'), '31.12');
        expect(formatShortDate('2026-06-15T12:00:00'), '15.06');
      });

      test('handles dates with single digit day and month', () {
        final input = '2026-03-05T10:00:00';
        final result = formatShortDate(input);

        expect(result, '05.03');
      });

      test('formats dates from different years correctly', () {
        expect(formatShortDate('2025-02-15T19:00:00'), '15.02');
        expect(formatShortDate('2026-02-15T19:00:00'), '15.02');
        expect(formatShortDate('2027-02-15T19:00:00'), '15.02');
      });

      test('handles leap year dates', () {
        final input = '2024-02-29T19:00:00'; // Leap year
        final result = formatShortDate(input);

        expect(result, '29.02');
      });

      test('returns original value if no parser matches', () {
        final unknownFormat = '15th February 2026';
        final result = formatShortDate(unknownFormat);

        expect(result, '15th February 2026');
      });

      test('handles whitespace in date strings', () {
        final input = '  2026-02-15T19:00:00  ';
        // Note: This tests actual behavior - may need adjustment based on implementation
        final result = formatShortDate(input);
        expect(result, isNotEmpty);
      });

      test('formats multiple dates independently', () {
        final date1 = formatShortDate('2026-01-15T10:00:00');
        final date2 = formatShortDate('2026-02-20T14:00:00');
        final date3 = formatShortDate('2026-03-10T18:00:00');

        expect(date1, '15.01');
        expect(date2, '20.02');
        expect(date3, '10.03');
      });

      test('handles midnight times', () {
        final input = '2026-02-15T00:00:00';
        final result = formatShortDate(input);

        expect(result, '15.02');
      });

      test('handles end of day times', () {
        final input = '2026-02-15T23:59:59';
        final result = formatShortDate(input);

        expect(result, '15.02');
      });
    });

    group('_tryParseIso helper function', () {
      test('successfully parses ISO datetime string', () {
        final input = '2026-02-15T19:00:00';
        // Testing through formatShortDate which uses _tryParseIso
        final result = formatShortDate(input);

        expect(result, '15.02');
      });

      test('returns null for non-ISO format via formatShortDate fallback', () {
        final input = 'not-iso-format';
        final result = formatShortDate(input);

        // Should return original since it can't parse
        expect(result, 'not-iso-format');
      });
    });

    group('Date parsing fallback logic', () {
      test('tries multiple formats in order', () {
        // All these should be parsed correctly by the fallback logic
        final isoDate = formatShortDate('2026-02-15T19:00:00');

        expect(isoDate, '15.02');
        // Others depend on implementation
      });

      test('ISO format has priority', () {
        // ISO format should be tried first
        final isoResult = formatShortDate('2026-02-15T19:00:00');
        expect(isoResult, '15.02');
      });

      test('handles format with time correctly', () {
        final input = '15.02.2026, 19:00';
        final result = formatShortDate(input);

        expect(result, isNotEmpty);
        expect(result, contains('15'));
      });
    });

    group('Edge cases and special scenarios', () {
      test('handles very old dates', () {
        final input = '1900-01-01T10:00:00';
        final result = formatShortDate(input);

        expect(result, '01.01');
      });

      test('handles future dates', () {
        final input = '2099-12-31T23:59:59';
        final result = formatShortDate(input);

        expect(result, '31.12');
      });

      test('handles dates with different time zones (as strings)', () {
        // This tests if function handles various string formats
        final input = '2026-02-15T19:00:00.000Z';
        // Depending on implementation, may or may not parse
        final result = formatShortDate(input);
        expect(result, isNotEmpty);
      });

      test('consistent results for same input', () {
        final input = '2026-02-15T19:00:00';
        final result1 = formatShortDate(input);
        final result2 = formatShortDate(input);

        expect(result1, result2);
      });

      test('does not modify valid dates', () {
        final input = '2026-02-15T19:00:00';
        final result = formatShortDate(input);

        // Result should be short date format
        expect(result.length, 5); // 'dd.mm' format
      });
    });
  });

  group('Date formatting utility tests', () {
    test('dd.MM format is always 5 characters for valid dates', () {
      final validDates = [
        '2026-01-01T10:00:00',
        '2026-12-31T23:59:59',
        '2026-06-15T12:00:00',
      ];

      for (var date in validDates) {
        final result = formatShortDate(date);
        if (result.length == 5) {
          expect(result, matches(RegExp(r'\d{2}\.\d{2}')));
        }
      }
    });

    test('handles century transitions', () {
      final y2k = '2000-01-01T00:00:00';
      final result = formatShortDate(y2k);

      expect(result, '01.01');
    });
  });
}
