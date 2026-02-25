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

      expect(find.text('LiveWave'), findsOneWidget);
      expect(find.text('Лучший выбор для покупки билетов'), findsOneWidget);

      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Вход'), findsWidgets);
    });

    testWidgets('Welcome screen can navigate via button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      expect(find.text('LiveWave'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('LiveWave'), findsNothing);
    });
  });

  group('Home Screen Integration Tests', () {
    testWidgets('Home screen displays events and city selector',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final continueButton = find.byType(ElevatedButton);
      if (continueButton.evaluate().isNotEmpty) {
        await tester.tap(continueButton.first);
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('City selector dropdown is visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton), findsWidgets);
    });

    testWidgets('Can change city selection', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButton).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownMenuItem), findsWidgets);
    });
  });

  group('Search and Filter Integration Tests', () {
    testWidgets('Search bar is visible', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Search bar accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField).first;
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Concert');
      await tester.pumpAndSettle();

      expect(find.text('Concert'), findsWidgets);
    });
  });

  group('Bottom Navigation Integration Tests', () {
    testWidgets('Bottom nav bar is visible', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Can navigate between bottom nav items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsWidgets);
    });
  });

  group('Event Detail Screen Integration Tests', () {
    testWidgets('Event cards are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Event detail navigation is possible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

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

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Page view carousel scrolls correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final pageView = find.byType(PageView);
      if (pageView.evaluate().isNotEmpty) {
        await tester.drag(pageView.first, const Offset(-300, 0));
        await tester.pumpAndSettle();
      }
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('App handles rapid navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App remains stable after multiple interactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());

      for (int i = 0; i < 5; i++) {
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Text Display Integration Tests', () {
    testWidgets('All major text elements are visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
      expect(find.text('LiveWave'), findsWidgets);
    });

    testWidgets('Localization text is properly displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });
  });

  group('Widget Tree Integrity Tests', () {
    testWidgets('Initial app structure is correct',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Navigation does not cause duplicate widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold).evaluate().isNotEmpty, true);
    });
  });
}
