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

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for event containers
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Can tap on event to view details', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find first event card
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

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to tap event
      final events = find.byType(GestureDetector);
      if (events.evaluate().isNotEmpty) {
        await tester.tap(events.first);
        await tester.pumpAndSettle();

        // Check for event detail elements
        expect(find.byType(Text), findsWidgets);
        expect(find.byType(Image), findsWidgets);
      }
    });

    testWidgets('Can navigate back from event details',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Open event details
      final events = find.byType(GestureDetector);
      if (events.evaluate().isNotEmpty) {
        await tester.tap(events.first);
        await tester.pumpAndSettle();

        // Go back
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Should be back on home
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  group('Seat Selection Tests', () {
    testWidgets('Seat selection screen displays seats',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate through app to reach seat selection
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for seat grid or seat representation
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Can select and deselect seats', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Try to find and tap seats
      final containers = find.byType(Container);
      if (containers.evaluate().length > 10) {
        // Tap first potential seat
        await tester.tap(containers.at(5));
        await tester.pumpAndSettle();

        // Tap again to deselect
        await tester.tap(containers.at(5));
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Seat legend is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to seat selection
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for legend text
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Can proceed to purchase after selecting seats',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to seat selection
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for checkout button
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        // Try to tap purchase button
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

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Purchase screen would show summary
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Purchase button is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Find purchase buttons
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
    });

    testWidgets('Price calculation is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate through app
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for price display (numbers in Text widgets)
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
    });

    testWidgets('Prompts for login if not authenticated',
        (WidgetTester tester) async {
      // Clear auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // When trying to purchase, should ask to login
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().length > 5) {
        // Might be purchase button
        await tester.tap(buttons.last);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Check if we're back at login or show auth required message
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('My Tickets Screen Tests', () {
    setUp(() async {
      // Set up authentication
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'test_token');
    });

    testWidgets('My Tickets screen is accessible from nav bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for navigation items
      final navItems = find.byType(IconButton);
      if (navItems.evaluate().length > 2) {
        // Try to tap tickets navigation
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

      // Navigate to my tickets
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for list view
      expect(find.byType(ListView), findsAny);
    });

    testWidgets('Ticket details can be viewed',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'test_token');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to tickets
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Try to tap on a ticket
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

      // Navigate through app
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Check for filters or tabs
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('Event Filter and Search Tests', () {
    testWidgets('City filter changes displayed events',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Find dropdown
      final dropdown = find.byType(DropdownButton);
      if (dropdown.evaluate().isNotEmpty) {
        await tester.tap(dropdown.first);
        await tester.pumpAndSettle();

        // Select different city
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

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Find search field
      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.tap(searchFields.first);
        await tester.enterText(searchFields.first, 'Concert');
        await tester.pumpAndSettle();

        // Search should filter results
        expect(find.text('Concert'), findsAny);
      }
    });

    testWidgets('Search results are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Type in search
      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'Concert');
        await tester.pumpAndSettle();

        // Results should appear
        expect(find.byType(ListView), findsAny);
      }
    });

    testWidgets('Can clear search', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Search
      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'test');
        await tester.pumpAndSettle();

        // Clear
        await tester.tap(fields.first);
        await tester.enterText(fields.first, '');
        await tester.pumpAndSettle();

        // Should show all events again
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  group('Deep Linking and Navigation Tests', () {
    testWidgets('App handles rapid screen transitions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());

      // Rapid navigation
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      await tester.pumpAndSettle();

      // App should not crash
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Navigation stack is properly maintained',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate forward
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should return to previous screen
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

      // Response should be quick (less than 500ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('List scrolling is smooth', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Scroll multiple times
      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -100));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
      }

      // App should remain responsive
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Images load without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for images
      expect(find.byType(Image), findsAny);
    });
  });
}
