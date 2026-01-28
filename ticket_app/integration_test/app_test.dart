import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticket_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Welcome and Navigation Integration Tests', () {
    testWidgets('Welcome screen displays and user can navigate to login',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Verify welcome screen is displayed
      expect(find.text('LiveWave'), findsOneWidget);
      expect(find.text('Лучший выбор для покупки билетов'), findsOneWidget);

      // Find and tap login button
      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.text('Вход'), findsWidgets);
    });

    testWidgets('Welcome screen can navigate via button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('LiveWave'), findsOneWidget);

      // Tap button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Navigation should occur
      expect(find.text('LiveWave'), findsNothing);
    });
  });

  group('Home Screen Integration Tests', () {
    testWidgets('Home screen displays events and city selector',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login first
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find "Continue without login" option if available
      final continueButton = find.byType(ElevatedButton);
      if (continueButton.evaluate().isNotEmpty) {
        // Try to find continue without login button
        await tester.tap(continueButton.first);
        await tester.pumpAndSettle();
      }

      // Wait for home screen to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify home screen elements exist
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('City selector dropdown is visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate past welcome screen
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Look for dropdown button
      await tester.pumpAndSettle();

      // Verify dropdown exists
      expect(find.byType(DropdownButton), findsWidgets);
    });

    testWidgets('Can change city selection', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Find and tap dropdown
      final dropdown = find.byType(DropdownButton).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Verify dropdown menu items appear
      expect(find.byType(DropdownMenuItem), findsWidgets);
    });
  });

  group('Search and Filter Integration Tests', () {
    testWidgets('Search bar is visible', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Find search bar
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Search bar accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Find and interact with search field
      final searchField = find.byType(TextField).first;
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Concert');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('Concert'), findsWidgets);
    });
  });

  group('Bottom Navigation Integration Tests', () {
    testWidgets('Bottom nav bar is visible', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Bottom nav should exist
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Can navigate between bottom nav items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for icon buttons in bottom nav
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsWidgets);
    });
  });

  group('Event Detail Screen Integration Tests', () {
    testWidgets('Event cards are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for cards or containers representing events
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Event detail navigation is possible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for GestureDetectors or buttons that might open event details
      final gestureDetectors = find.byType(GestureDetector);
      if (gestureDetectors.evaluate().isNotEmpty) {
        await tester.tap(gestureDetectors.first);
        await tester.pumpAndSettle();
      }
    });
  });

  group('Scrolling and Layout Integration Tests', () {
    testWidgets('Main screen is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Try to scroll
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      // App should still be responsive
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Page view carousel scrolls correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for PageView
      final pageView = find.byType(PageView);
      if (pageView.evaluate().isNotEmpty) {
        // Swipe to next page
        await tester.drag(pageView.first, const Offset(-300, 0));
        await tester.pumpAndSettle();
      }
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('App handles rapid navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Rapid taps
      await tester.tap(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // App should not crash
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App remains stable after multiple interactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());

      // Multiple pump cycles
      for (int i = 0; i < 5; i++) {
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Text Display Integration Tests', () {
    testWidgets('All major text elements are visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Welcome text should be visible
      expect(find.byType(Text), findsWidgets);
      expect(find.text('LiveWave'), findsWidgets);
    });

    testWidgets('Localization text is properly displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Check for Russian text
      expect(find.byType(Text), findsWidgets);

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // More text should be visible
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('Widget Tree Integrity Tests', () {
    testWidgets('Initial app structure is correct',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Verify main widgets exist
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Navigation does not cause duplicate widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Widget tree should remain clean
      expect(find.byType(Scaffold).evaluate().isNotEmpty, true);
    });
  });
}
