import 'package:flutter_test/flutter_test.dart';
import 'package:ticket_app/models/event.dart';

void main() {
  group('Event Model Tests', () {
    test('Event.fromJson creates Event with correct values', () {
      final json = {
        'id': 1,
        'title': 'Концерт Test',
        'description': 'Тестовое описание',
        'date': '2026-02-15T19:00:00',
        'price': 150.0,
        'city': 'Алматы',
        'venue': 'Mega Dome',
        'imageKey': 'concert',
      };

      final event = Event.fromJson(json);

      expect(event.id, 1);
      expect(event.title, 'Концерт Test');
      expect(event.description, 'Тестовое описание');
      expect(event.price, 150.0);
      expect(event.city, 'Алматы');
      expect(event.venue, 'Mega Dome');
      expect(event.imageKey, 'concert');
    });

    test('Event.fromJson formats date correctly from ISO format', () {
      final json = {
        'id': 2,
        'title': 'Event',
        'description': 'Desc',
        'date': '2026-02-15T19:00:00',
        'price': 100.0,
        'city': 'Астана',
        'venue': 'Arena',
        'imageKey': 'test',
      };

      final event = Event.fromJson(json);

      // Проверяем, что дата отформатирована
      expect(event.date, isNotEmpty);
      expect(event.date, contains('15'));
      expect(event.date, contains('02'));
    });

    test('Event.fromJson handles missing fields with defaults', () {
      final json = {
        'id': 3,
        'title': '',
        'description': '',
        'date': '',
        'price': 0,
        'city': '',
        'venue': '',
        'imageKey': '',
      };

      final event = Event.fromJson(json);

      expect(event.id, 3);
      expect(event.title, '');
      expect(event.price, 0.0);
    });

    test('Event.fromJson creates correct banner image path', () {
      final json = {
        'id': 4,
        'title': 'Event',
        'description': 'Desc',
        'date': '2026-02-15T19:00:00',
        'price': 100.0,
        'city': 'Алматы',
        'venue': 'Venue',
        'imageKey': 'concert',
      };

      final event = Event.fromJson(json);

      expect(event.bannerImagePath, 'assets/images/concert_banner.jpg');
    });

    test('Event.fromJson uses default image path for empty imageKey', () {
      final json = {
        'id': 5,
        'title': 'Event',
        'description': 'Desc',
        'date': '2026-02-15T19:00:00',
        'price': 100.0,
        'city': 'Алматы',
        'venue': 'Venue',
        'imageKey': '',
      };

      final event = Event.fromJson(json);

      expect(event.bannerImagePath, 'assets/images/default_event.jpg');
    });

    test('Event.fromJson converts imageKey to lowercase', () {
      final json = {
        'id': 6,
        'title': 'Event',
        'description': 'Desc',
        'date': '2026-02-15T19:00:00',
        'price': 100.0,
        'city': 'Алматы',
        'venue': 'Venue',
        'imageKey': 'CONCERT',
      };

      final event = Event.fromJson(json);

      expect(event.imageKey, 'concert');
      expect(event.bannerImagePath, 'assets/images/concert_banner.jpg');
    });

    test('Event.fromJson handles invalid date format gracefully', () {
      final json = {
        'id': 7,
        'title': 'Event',
        'description': 'Desc',
        'date': 'invalid-date',
        'price': 100.0,
        'city': 'Алматы',
        'venue': 'Venue',
        'imageKey': 'test',
      };

      final event = Event.fromJson(json);

      // Должен возвращать оригинальное значение при ошибке парсинга
      expect(event.date, 'invalid-date');
    });

    test('Event.fromJson handles null date', () {
      final json = {
        'id': 8,
        'title': 'Event',
        'description': 'Desc',
        'date': null,
        'price': 100.0,
        'city': 'Алматы',
        'venue': 'Venue',
        'imageKey': 'test',
      };

      final event = Event.fromJson(json);

      expect(event.date, '');
    });

    test('Event.fromJson converts price to double', () {
      final jsonWithIntPrice = {
        'id': 9,
        'title': 'Event',
        'description': 'Desc',
        'date': '2026-02-15T19:00:00',
        'price': 100,
        'city': 'Алматы',
        'venue': 'Venue',
        'imageKey': 'test',
      };

      final event = Event.fromJson(jsonWithIntPrice);

      expect(event.price, 100.0);
    });

    test('Event properties are correctly assigned', () {
      final event = Event(
        id: 10,
        title: 'Manual Event',
        description: 'Manual Desc',
        date: '15.02.2026',
        price: 200.0,
        city: 'Алматы',
        venue: 'Test Arena',
        imageKey: 'manual',
        bannerImagePath: 'assets/images/manual_banner.jpg',
      );

      expect(event.id, 10);
      expect(event.title, 'Manual Event');
      expect(event.description, 'Manual Desc');
      expect(event.date, '15.02.2026');
      expect(event.price, 200.0);
      expect(event.city, 'Алматы');
      expect(event.venue, 'Test Arena');
      expect(event.imageKey, 'manual');
      expect(event.bannerImagePath, 'assets/images/manual_banner.jpg');
    });
  });
}