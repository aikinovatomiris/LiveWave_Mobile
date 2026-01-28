import 'package:flutter_test/flutter_test.dart';
import 'package:ticket_app/models/seat.dart';

void main() {
  group('Seat Model Tests', () {
    test('Seat.fromJson creates Seat with correct values', () {
      final json = {
        'id': 1,
        'seatNumber': 'A1',
        'rowNum': 1,
        'colNum': 1,
        'eventId': 100,
        'booked': false,
      };

      final seat = Seat.fromJson(json);

      expect(seat.id, 1);
      expect(seat.seatNumber, 'A1');
      expect(seat.rowNum, 1);
      expect(seat.colNum, 1);
      expect(seat.eventId, 100);
      expect(seat.isBooked, false);
    });

    test('Seat.fromJson handles isBooked field', () {
      final jsonBooked = {
        'id': 2,
        'seatNumber': 'A2',
        'rowNum': 1,
        'colNum': 2,
        'eventId': 100,
        'isBooked': true,
      };

      final seat = Seat.fromJson(jsonBooked);

      expect(seat.isBooked, true);
    });

    test('Seat.fromJson converts string id to int', () {
      final json = {
        'id': '5',
        'seatNumber': 'B5',
        'rowNum': 2,
        'colNum': 5,
        'eventId': 100,
        'booked': false,
      };

      final seat = Seat.fromJson(json);

      expect(seat.id, 5);
    });

    test('Seat.fromJson handles missing eventId', () {
      final json = {
        'id': 3,
        'seatNumber': 'C3',
        'rowNum': 3,
        'colNum': 3,
        'booked': false,
      };

      final seat = Seat.fromJson(json);

      expect(seat.eventId, isNull);
    });

    test('Seat.fromJson uses seat_number alternative key', () {
      final json = {
        'id': 4,
        'seat_number': 'D4',
        'row_num': 4,
        'col_num': 4,
        'event_id': 100,
        'booked': false,
      };

      final seat = Seat.fromJson(json);

      expect(seat.seatNumber, 'D4');
      expect(seat.rowNum, 4);
      expect(seat.colNum, 4);
    });

    test('Seat.fromJson defaults missing fields to 0', () {
      final json = {
        'id': 6,
        'seatNumber': 'E6',
      };

      final seat = Seat.fromJson(json);

      expect(seat.rowNum, 0);
      expect(seat.colNum, 0);
      expect(seat.isBooked, false);
    });

    test('Seat.fromJson treats booked:true as isBooked:true', () {
      final json = {
        'id': 7,
        'seatNumber': 'F7',
        'rowNum': 7,
        'colNum': 7,
        'booked': true,
      };

      final seat = Seat.fromJson(json);

      expect(seat.isBooked, true);
    });

    test('Seat constructor assigns all fields correctly', () {
      final seat = Seat(
        id: 10,
        seatNumber: 'Z10',
        rowNum: 26,
        colNum: 10,
        eventId: 500,
        isBooked: true,
      );

      expect(seat.id, 10);
      expect(seat.seatNumber, 'Z10');
      expect(seat.rowNum, 26);
      expect(seat.colNum, 10);
      expect(seat.eventId, 500);
      expect(seat.isBooked, true);
    });

    test('Seat.fromJson handles empty seatNumber', () {
      final json = {
        'id': 11,
        'seatNumber': '',
        'rowNum': 11,
        'colNum': 11,
        'booked': false,
      };

      final seat = Seat.fromJson(json);

      expect(seat.seatNumber, '');
    });

    test('Multiple seats can be created independently', () {
      final json1 = {
        'id': 1,
        'seatNumber': 'A1',
        'rowNum': 1,
        'colNum': 1,
        'booked': false,
      };

      final json2 = {
        'id': 2,
        'seatNumber': 'A2',
        'rowNum': 1,
        'colNum': 2,
        'booked': false,
      };

      final seat1 = Seat.fromJson(json1);
      final seat2 = Seat.fromJson(json2);

      expect(seat1.id, 1);
      expect(seat2.id, 2);
      expect(seat1.seatNumber, 'A1');
      expect(seat2.seatNumber, 'A2');
    });

    test('Seat.fromJson handles integer id field', () {
      final json = {
        'id': 99,
        'seatNumber': 'TEST',
        'rowNum': 1,
        'colNum': 1,
        'booked': false,
      };

      final seat = Seat.fromJson(json);

      expect(seat.id, 99);
    });

    test('Seat.fromJson with invalid id defaults to 0', () {
      final json = {
        'id': 'invalid',
        'seatNumber': 'TEST',
        'rowNum': 1,
        'colNum': 1,
        'booked': false,
      };

      final seat = Seat.fromJson(json);

      expect(seat.id, 0);
    });
  });
}
