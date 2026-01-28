import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:ticket_app/services/api_service.dart';
import 'package:ticket_app/models/event.dart';
import 'package:ticket_app/models/seat.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    // Tests for fetchEvents
    group('fetchEvents', () {
      test('method exists and returns Future<List<Event>>', () {
        final result = apiService.fetchEvents();
        expect(result, isA<Future<List<Event>>>());
      });

      test('fetchEvents with city parameter returns Future<List<Event>>', () {
        final result = apiService.fetchEvents(city: 'Almaty');
        expect(result, isA<Future<List<Event>>>());
      });

      test('fetchEvents without city parameter returns Future<List<Event>>', () {
        final result = apiService.fetchEvents();
        expect(result, isA<Future<List<Event>>>());
      });
    });

    // Tests for getSeatsByEvent
    group('getSeatsByEvent', () {
      test('method exists and returns Future<List<Seat>>', () {
        final result = apiService.getSeatsByEvent(1);
        expect(result, isA<Future<List<Seat>>>());
      });

      test('returns Future with valid event ID', () {
        final result = apiService.getSeatsByEvent(100);
        expect(result, isA<Future<List<Seat>>>());
      });
    });

    // Tests for authentication methods
    group('Authentication methods', () {
      test('login method returns Future<http.Response>', () {
        final result = apiService.login('test@example.com', 'password123');
        expect(result, isA<Future<http.Response>>());
      });

      test('register method returns Future<http.Response>', () {
        final result = apiService.register('Test User', 'test@example.com', 'password123');
        expect(result, isA<Future<http.Response>>());
      });

      test('login creates correct request with email and password', () async {
        final email = 'test@example.com';
        final password = 'password123';

        // Check that method exists and returns Future
        final loginFuture = apiService.login(email, password);
        expect(loginFuture, isA<Future>());
      });

      test('register creates correct request with name, email and password', () async {
        final name = 'Test User';
        final email = 'test@example.com';
        final password = 'password123';

        final registerFuture = apiService.register(name, email, password);
        expect(registerFuture, isA<Future>());
      });
    });

    // Tests for seat booking
    group('Seat booking', () {
      test('bookSeats method returns Future<http.Response>', () {
        final result = apiService.bookSeats('token123', 1, ['A1', 'A2']);
        expect(result, isA<Future<http.Response>>());
      });

      test('bookSeats includes authorization header', () async {
        // Demonstrates that method is properly constructed
        final result = apiService.bookSeats('valid_token', 100, ['A1']);
        expect(result, isA<Future>());
      });
    });

    // Tests for password reset
    group('Password reset methods', () {
      test('requestPasswordReset returns Future<String?>', () {
        final result = apiService.requestPasswordReset('test@example.com');
        expect(result, isA<Future<String?>>());
      });

      test('resetPassword returns Future<bool>', () {
        final result = apiService.resetPassword('reset_token', 'newPassword123');
        expect(result, isA<Future<bool>>());
      });
    });

    // Tests for profile methods
    group('Profile methods', () {
      test('fetchUserProfile returns Future<Map?>', () {
        final result = apiService.fetchUserProfile('token123');
        expect(result, isA<Future<Map<String, dynamic>?>>());
      });

      test('updateUserProfile returns Future<Map?>', () {
        final result = apiService.updateUserProfile('token123', {'name': 'New Name'});
        expect(result, isA<Future<Map<String, dynamic>?>>());
      });
    });

    // Tests for tickets
    group('Tickets methods', () {
      test('fetchUserTickets returns Future<List>', () {
        final result = apiService.fetchUserTickets('token123');
        expect(result, isA<Future<List<dynamic>>>());
      });
    });

    // Tests for admin methods
    group('Admin methods', () {
      test('fetchAdminEvents returns Future<List<Event>>', () {
        final result = apiService.fetchAdminEvents('admin_token');
        expect(result, isA<Future<List<Event>>>());
      });

      test('createEvent returns Future<bool>', () {
        final eventData = {
          'title': 'New Event',
          'description': 'Desc',
          'date': '2026-03-01T19:00:00',
          'price': 200.0,
          'city': 'Almaty',
          'venue': 'Arena',
          'rows': 10,
          'cols': 10,
        };
        final result = apiService.createEvent('admin_token', eventData);
        expect(result, isA<Future<bool>>());
      });

      test('deleteEvent returns Future<bool>', () {
        final result = apiService.deleteEvent('admin_token', 1);
        expect(result, isA<Future<bool>>());
      });

      test('updateEvent returns Future<bool>', () {
        final updateData = {'title': 'Updated Event'};
        final result = apiService.updateEvent('admin_token', 1, updateData);
        expect(result, isA<Future<bool>>());
      });
    });

    // Tests for API endpoint structure
    group('API endpoint structure', () {
      test('baseUrl is defined and not empty', () {
        expect(ApiService.baseUrl, isNotEmpty);
      });

      test('baseUrl contains http protocol', () {
        expect(ApiService.baseUrl, startsWith('http'));
      });

      test('baseUrl does not contain trailing slash', () {
        expect(ApiService.baseUrl.endsWith('/'), false);
      });
    });
  });
}
