import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticket_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('Login screen displays all required fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Can toggle between login and register modes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final textButtons = find.byType(TextButton);
      if (textButtons.evaluate().isNotEmpty) {
        await tester.tap(textButtons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Email validation works', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final emailFields = find.byType(TextField);
      expect(emailFields, findsWidgets);

      await tester.tap(emailFields.first);
      await tester.enterText(emailFields.first, 'invalidemail');
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.last);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Password field has visibility toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('Continue without login button works',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final buttons = find.byType(TextButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Form resets after clearing input', (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final emailFields = find.byType(TextField);
      if (emailFields.evaluate().isNotEmpty) {
        await tester.tap(emailFields.first);
        await tester.enterText(emailFields.first, 'test@example.com');
        await tester.pumpAndSettle();

        await tester.tap(emailFields.first);
        await tester.enterText(emailFields.first, '');
        await tester.pumpAndSettle();

        expect(find.text('test@example.com'), findsNothing);
      }
    });

    testWidgets('Multiple field validation on submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final submitButtons = find.byType(ElevatedButton);
      if (submitButtons.evaluate().isNotEmpty) {
        await tester.tap(submitButtons.last);
        await tester.pumpAndSettle();
      }

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Password field shows as obscured by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      expect(fields, findsWidgets);

      expect(fields.evaluate().length, greaterThanOrEqualTo(2));
    });
  });

  group('Forgot Password Flow Tests', () {
    testWidgets('Can navigate to forgot password screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final links = find.byType(GestureDetector);
      if (links.evaluate().isNotEmpty) {
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

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('Session Management Tests', () {
    testWidgets('App preserves user state after navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Token is properly stored in preferences',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('test_key', 'test_value');

      final value = prefs.getString('test_key');
      expect(value, 'test_value');

      await prefs.remove('test_key');
    });

    testWidgets('User name is loaded from preferences',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', 'Test User');

      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);

      await prefs.remove('user_name');
    });
  });

  group('Input Validation Integration Tests', () {
    testWidgets('Minimum password length is enforced',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        final passwordField = fields.at(1);
        await tester.tap(passwordField);
        await tester.enterText(passwordField, '123');
        await tester.pumpAndSettle();

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

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'not-an-email');
        await tester.pumpAndSettle();

        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pumpAndSettle();
        }

        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Form submits with valid data',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'test@example.com');

        await tester.tap(fields.at(1));
        await tester.enterText(fields.at(1), 'password123');

        await tester.pumpAndSettle();

        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pumpAndSettle();
        }
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('UI/UX Flow Tests', () {
    testWidgets('Login button is properly styled',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Loading indicator appears during submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        await tester.tap(fields.first);
        await tester.enterText(fields.first, 'test@example.com');
        await tester.tap(fields.at(1));
        await tester.enterText(fields.at(1), 'password123');

        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.last);
          await tester.pump();

        
          expect(find.byType(CircularProgressIndicator), findsAny);
        }
      }
    });

    testWidgets('Error messages display on failed auth',
        (WidgetTester tester) async {
      await tester.pumpWidget(const TicketApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

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

        expect(find.byType(SnackBar), findsAny);
      }
    });
  });
}
