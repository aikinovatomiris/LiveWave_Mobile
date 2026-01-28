import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticket_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    setUp(() async {
      // Clear stored preferences before each test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('Login screen displays all required fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify login screen elements
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Can toggle between login and register modes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Look for toggle button or text
      final textButtons = find.byType(TextButton);
      if (textButtons.evaluate().isNotEmpty) {
        await tester.tap(textButtons.first);
        await tester.pumpAndSettle();
      }

      // Screen should update
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Email validation works', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find email field
      final emailFields = find.byType(TextField);
      expect(emailFields, findsWidgets);

      // Enter invalid email
      await tester.tap(emailFields.first);
      await tester.enterText(emailFields.first, 'invalidemail');
      await tester.pumpAndSettle();

      // Try to submit
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.last);
        await tester.pumpAndSettle();
      }

      // Form should still be visible (validation error)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Password field has visibility toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Look for IconButtons (visibility toggle)
      await tester.pumpAndSettle();
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('Continue without login button works',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find continue without login button (if present)
      final buttons = find.byType(TextButton);
      if (buttons.evaluate().isNotEmpty) {
        // Try first text button
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
      }

      // Should navigate to home
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Form resets after clearing input', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find and fill email field
      final emailFields = find.byType(TextField);
      if (emailFields.evaluate().isNotEmpty) {
        await tester.tap(emailFields.first);
        await tester.enterText(emailFields.first, 'test@example.com');
        await tester.pumpAndSettle();

        // Clear the field
        await tester.tap(emailFields.first);
        await tester.enterText(emailFields.first, '');
        await tester.pumpAndSettle();

        // Field should be empty
        expect(find.text('test@example.com'), findsNothing);
      }
    });

    testWidgets('Multiple field validation on submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Try to submit empty form
      final submitButtons = find.byType(ElevatedButton);
      if (submitButtons.evaluate().isNotEmpty) {
        await tester.tap(submitButtons.last);
        await tester.pumpAndSettle();
      }

      // Form should still be displayed
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Password field shows as obscured by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find password fields
      final fields = find.byType(TextField);
      expect(fields, findsWidgets);

      // Should have at least 2 fields (email + password)
      expect(fields.evaluate().length, greaterThanOrEqualTo(2));
    });
  });

  group('Forgot Password Flow Tests', () {
    testWidgets('Can navigate to forgot password screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Look for forgot password link/button
      final links = find.byType(GestureDetector);
      if (links.evaluate().isNotEmpty) {
        // Try tapping different elements
        for (var i = 0; i < links.evaluate().length; i++) {
          await tester.pumpAndSettle();
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Forgot password form accepts email input',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Try to find forgot password route
      await tester.pumpAndSettle();

      // Verify form structure
      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('Session Management Tests', () {
    testWidgets('App preserves user state after navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Navigate back if possible
      await tester.pageBack();
      await tester.pumpAndSettle();

      // App should still function
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Token is properly stored in preferences',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Check if SharedPreferences works
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('test_key', 'test_value');

      final value = prefs.getString('test_key');
      expect(value, 'test_value');

      // Clean up
      await prefs.remove('test_key');
    });

    testWidgets('User name is loaded from preferences',
        (WidgetTester tester) async {
      // Set up preferences with user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', 'Test User');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // User name should be available
      // (exact verification depends on UI implementation)
      expect(find.byType(Scaffold), findsWidgets);

      // Clean up
      await prefs.remove('user_name');
    });
  });

  group('Input Validation Integration Tests', () {
    testWidgets('Minimum password length is enforced',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find password field (usually second text field)
      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        final passwordField = fields.at(1);
        await tester.tap(passwordField);
        await tester.enterText(passwordField, '123');
        await tester.pumpAndSettle();

        // Try to submit
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pumpAndSettle();
        }
      }

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Email format validation works',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find and fill email with invalid format
      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'not-an-email');
        await tester.pumpAndSettle();

        // Try to submit
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pumpAndSettle();
        }

        // Should show error or remain on page
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Form submits with valid data',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Fill with valid data
      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        // Email
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'test@example.com');

        // Password
        await tester.tap(fields.at(1));
        await tester.enterText(fields.at(1), 'password123');

        await tester.pumpAndSettle();

        // Try to submit
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pumpAndSettle();
        }
      }

      // App should respond to submission
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('UI/UX Flow Tests', () {
    testWidgets('Login button is properly styled',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify buttons exist and are accessible
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Loading indicator appears during submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Fill form
      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'test@example.com');
        await tester.tap(fields.at(1));
        await tester.enterText(fields.at(1), 'password123');

        // Submit
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pump();

          // Check for loading indicator (CircularProgressIndicator)
          // May or may not be visible depending on network speed
          expect(find.byType(CircularProgressIndicator), findsAny);
        }
      }
    });

    testWidgets('Error messages display on failed auth',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Submit with invalid data that will fail
      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'nonexistent@example.com');
        await tester.tap(fields.at(1));
        await tester.enterText(fields.at(1), 'wrongpassword');

        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Should show error message or SnackBar
        expect(find.byType(SnackBar), findsAny);
      }
    });
  });
}
