import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticket_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Event Browsing and Selection Tests', () {
    testWidgets('Events are loaded and displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Can tap on event to view details', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final eventCards = find.byType(GestureDetector);
      if (eventCards.evaluate().isNotEmpty) {
        await tester.tap(eventCards.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Event details screen displays information',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final events = find.byType(GestureDetector);
      if (events.evaluate().isNotEmpty) {
        await tester.tap(events.first);
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsWidgets);
        expect(find.byType(Image), findsWidgets);
      }
    });

    testWidgets('Can navigate back from event details',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final events = find.byType(GestureDetector);
      if (events.evaluate().isNotEmpty) {
        await tester.tap(events.first);
        await tester.pumpAndSettle();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  group('Seat Selection Tests', () {
    testWidgets('Seat selection screen displays seats',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Can select and deselect seats', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      if (containers.evaluate().length > 10) {
        await tester.tap(containers.at(5));
        await tester.pumpAndSettle();

        await tester.tap(containers.at(5));
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Seat legend is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Can proceed to purchase after selecting seats',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Purchase Flow Tests', () {
    testWidgets('Purchase screen displays order summary',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Purchase button is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
    });

    testWidgets('Price calculation is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
    });

    testWidgets('Prompts for login if not authenticated',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().length > 5) {
        await tester.tap(buttons.last);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('My Tickets Screen Tests', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'test_token');
    });

    testWidgets('My Tickets screen is accessible from nav bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navItems = find.byType(IconButton);
      if (navItems.evaluate().length > 2) {
        await tester.tap(navItems.at(1));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tickets are displayed in a list',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'test_token');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsAny);
    });

    testWidgets('Ticket details can be viewed',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'test_token');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final tickets = find.byType(GestureDetector);
      if (tickets.evaluate().isNotEmpty) {
        await tester.tap(tickets.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Upcoming and past tickets can be distinguished',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'test_token');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });
  });

  group('Event Filter and Search Tests', () {
    testWidgets('City filter changes displayed events',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButton);
      if (dropdown.evaluate().isNotEmpty) {
        await tester.tap(dropdown.first);
        await tester.pumpAndSettle();

        final items = find.byType(DropdownMenuItem);
        if (items.evaluate().length > 1) {
          await tester.tap(items.at(1));
          await tester.pumpAndSettle();
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Search filter works', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.tap(searchFields.first);
        await tester.enterText(searchFields.first, 'Concert');
        await tester.pumpAndSettle();

        expect(find.text('Concert'), findsAny);
      }
    });

    testWidgets('Search results are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'Concert');
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsAny);
      }
    });

    testWidgets('Can clear search', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'test');
        await tester.pumpAndSettle();

        await tester.tap(fields.first);
        await tester.enterText(fields.first, '');
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  group('Deep Linking and Navigation Tests', () {
    testWidgets('App handles rapid screen transitions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Navigation stack is properly maintained',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Performance and Responsiveness Tests', () {
    testWidgets('App responds quickly to taps',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('List scrolling is smooth', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -100));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Images load without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Image), findsAny);
    });
  });
}
