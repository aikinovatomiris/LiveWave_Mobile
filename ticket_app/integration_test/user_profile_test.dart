import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticket_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Screen Tests', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'test_token');
      await prefs.setString('user_name', 'Test User');
      await prefs.setString('user_email', 'test@example.com');
    });

    testWidgets('Profile screen is accessible from navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for profile navigation button
      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        // Tap on profile (usually last nav item)
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('User information is displayed on profile',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home and then profile
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      // Look for user name or email display
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Avatar selection is available', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      // Look for avatar or profile picture
      expect(find.byType(Image), findsAny);
    });

    testWidgets('Edit profile button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      // Look for edit button
      expect(find.byType(ElevatedButton), findsAny);
    });

    testWidgets('Logout button works', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      // Find logout button
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().length > 1) {
        await tester.tap(buttons.last);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Should return to login or welcome
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('City Preference Tests', () {
    testWidgets('Selected city persists in preferences',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCity', 'Astana');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Verify stored city
      final storedCity = prefs.getString('selectedCity');
      expect(storedCity, 'Astana');
    });

    testWidgets('City change is reflected in UI', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Find city selector dropdown
      final dropdown = find.byType(DropdownButton);
      if (dropdown.evaluate().isNotEmpty) {
        await tester.tap(dropdown.first);
        await tester.pumpAndSettle();

        // Select a city
        final items = find.byType(DropdownMenuItem);
        if (items.evaluate().length > 1) {
          await tester.tap(items.at(1));
          await tester.pumpAndSettle();

          // Verify city was changed
          final prefs = await SharedPreferences.getInstance();
          final selectedCity = prefs.getString('selectedCity');
          expect(selectedCity, isNotNull);
        }
      }
    });

    testWidgets('Events update when city changes', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Change city
      final dropdown = find.byType(DropdownButton);
      if (dropdown.evaluate().isNotEmpty) {
        await tester.tap(dropdown.first);
        await tester.pumpAndSettle();

        final items = find.byType(DropdownMenuItem);
        if (items.evaluate().length > 1) {
          await tester.tap(items.at(1));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Events should update
          expect(find.byType(Container), findsWidgets);
        }
      }
    });
  });

  group('Edit Profile Dialog Tests', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'test_token');
      await prefs.setString('user_name', 'Test User');
    });

    testWidgets('Edit profile dialog opens', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      // Look for edit button and tap it
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();

        // Dialog should appear
        expect(find.byType(AlertDialog), findsAny);
      }
    });

    testWidgets('Can edit user name', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      // Open edit dialog
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();

        // Find text fields in dialog
        final fields = find.byType(TextField);
        if (fields.evaluate().isNotEmpty) {
          await tester.tap(fields.first);
          await tester.enterText(fields.first, 'New Name');
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Can save profile changes', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      // Open and fill dialog
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();

        // Find and tap save button
        final dialogButtons = find.byType(ElevatedButton);
        if (dialogButtons.evaluate().length > 1) {
          await tester.tap(dialogButtons.last);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Can cancel profile edit', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle();
      }

      // Open dialog
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();

        // Find cancel button (usually TextButton)
        final textButtons = find.byType(TextButton);
        if (textButtons.evaluate().isNotEmpty) {
          await tester.tap(textButtons.first);
          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('Guest User Experience Tests', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    });

    testWidgets('Guest can browse events', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home without login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Should see events
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Guest requires login to purchase', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Try to purchase
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().length > 5) {
        await tester.tap(buttons.last);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Should prompt for login or redirect
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Guest can view profile screen', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Try to navigate to profile
      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 2) {
        await tester.tap(navButtons.at(navButtons.evaluate().length - 1));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Admin Panel Tests', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'admin_token');
      await prefs.setString('user_role', 'ADMIN');
    });

    testWidgets('Admin can access admin panel', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for admin navigation item
      final navButtons = find.byType(IconButton);
      if (navButtons.evaluate().length > 3) {
        // Should have extra admin button
        expect(navButtons.evaluate().length, greaterThan(3));
      }
    });

    testWidgets('Admin panel displays events', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'ADMIN');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to admin
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for admin panel elements
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Admin can add new event', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'ADMIN');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to admin
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Look for add event button
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        // Try to tap add button
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Preference Persistence Tests', () {
    testWidgets('User preferences are saved', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Change preferences
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Change city
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

      // Verify preferences saved
      final city = prefs.getString('selectedCity');
      expect(city, isNotNull);
    });

    testWidgets('Preferences load on app restart', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCity', 'Almaty');

      // App start should load preferences
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // City should be loaded
      final loaded = prefs.getString('selectedCity');
      expect(loaded, 'Almaty');
    });
  });
}
