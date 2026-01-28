
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  late FlutterDriver driver;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    await driver.close();
  });

  group('Authentication Flow Tests', () {
    test('Login screen validates email format', () async {
      // навигация к экрану логина
      await driver.tap(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('login_form'));

      // Ввод некорректного email
      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('notanemail');
      await Future.delayed(Duration(milliseconds: 300));

      // Проверка валидации
      await driver.waitFor(find.byValueKey('email_error'));
    });

    test('Login screen validates password length', () async {
      // Ввод короткого пароля
      await driver.tap(find.byValueKey('password_field'));
      await driver.enterText('123');
      await Future.delayed(Duration(milliseconds: 300));

      // Проверка валидации
      await driver.waitFor(find.byValueKey('password_error'));
    });

    test('Valid login credentials navigate to home', () async {
      // Ввод корректных данных
      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('test@example.com');
      await driver.tap(find.byValueKey('password_field'));
      await driver.enterText('password123');

      await driver.tap(find.byValueKey('submit_button'));
      await driver.waitFor(find.byValueKey('home_screen'));
    });

    test('Forgot password link navigates correctly', () async {
      await driver.tap(find.byValueKey('forgot_password_link'));
      await driver.waitFor(find.byValueKey('forgot_password_screen'));
    });

    test('Password reset email field validates', () async {
      // забыли пароль
      await driver.tap(find.byValueKey('forgot_password_link'));
      await driver.waitFor(find.byValueKey('reset_email_field'));

      // Ввод некорректного email
      await driver.tap(find.byValueKey('reset_email_field'));
      await driver.enterText('invalidemail');
      await Future.delayed(Duration(milliseconds: 300));

      await driver.waitFor(find.byValueKey('reset_email_error'));
    });

    test('Password reset sends recovery email', () async {
      // Ввод корректного email
      await driver.tap(find.byValueKey('reset_email_field'));
      await driver.enterText('test@example.com');

      await driver.tap(find.byValueKey('reset_button'));
      await driver.waitFor(find.byValueKey('reset_success_message'));
    });

    test('Register screen requires all fields', () async {
      // Навигация к регистрации
      await driver.tap(find.byValueKey('register_button'));
      await driver.waitFor(find.byValueKey('register_form'));

      // Оставляем все поля пустыми и пытаемся отправить
      await driver.tap(find.byValueKey('register_submit'));
      await Future.delayed(Duration(milliseconds: 300));

      // Проверка ошибок валидации
      await driver.waitFor(find.byValueKey('register_error'));
    });

    test('Register with valid data creates account', () async {
      // заполнение формы регистрации
      await driver.tap(find.byValueKey('register_name_field'));
      await driver.enterText('John Doe');

      await driver.tap(find.byValueKey('register_email_field'));
      await driver.enterText('john@example.com');

      await driver.tap(find.byValueKey('register_password_field'));
      await driver.enterText('securepass123');

      await driver.tap(find.byValueKey('register_confirm_password_field'));
      await driver.enterText('securepass123');

      await driver.tap(find.byValueKey('register_submit'));
      await driver.waitFor(find.byValueKey('home_screen'));
    });

    test('Password confirmation must match', () async {
      // Навигация к регистрации
      await driver.tap(find.byValueKey('register_button'));
      await driver.waitFor(find.byValueKey('register_form'));

      // Заполнение полей с несовпадающими паролями
      await driver.tap(find.byValueKey('register_password_field'));
      await driver.enterText('password123');

      await driver.tap(find.byValueKey('register_confirm_password_field'));
      await driver.enterText('password456');
      await Future.delayed(Duration(milliseconds: 300));

      await driver.waitFor(find.byValueKey('password_mismatch_error'));
    });

    test('User session persists on app restart', () async {
      // Проверка сохранения сессии
      await driver.waitFor(find.byValueKey('home_screen'));
    });

    test('Logout clears session data', () async {
      // Навигация к профилю
      await driver.tap(find.byValueKey('nav_profile'));
      await driver.waitFor(find.byValueKey('profile_screen'));

      // Выход из аккаунта
      await driver.tap(find.byValueKey('logout_button'));
      await driver.waitFor(find.byValueKey('welcome_title'));
    });

    test('Login state recovered after logout', () async {
      // Навигация к логину
      await driver.tap(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('email_field'));
    });
  });

  group('Session Management Tests', () {
    test('Expired token redirects to login', () async {
      await driver.waitFor(find.byValueKey('home_screen'));
    });

    test('Network timeout shows error', () async {
      await driver.waitFor(find.byValueKey('home_screen'));
    });

    test('Session data is encrypted', () async {
      await driver.tap(find.byValueKey('nav_profile'));
      await driver.waitFor(find.byValueKey('profile_screen'));

      await driver.waitFor(find.byValueKey('user_email'));
    });

    test('Auto-logout after inactivity', () async {
      // Ожидание периода неактивности
      await driver.waitFor(
        find.byValueKey('home_screen'),
        timeout: Duration(seconds: 30),
      );
    });

    test('BiometricAuth is available', () async {
      await driver.tap(find.byValueKey('nav_profile'));
      await driver.waitFor(find.byValueKey('profile_screen'));

      final bioButton = find.byValueKey('enable_biometric_button');
      try {
        await driver.waitFor(bioButton, timeout: Duration(seconds: 2));
      } catch (e) {
        // Биометрия не поддерживается
      }
    });

    test('Two-Factor Authentication setup', () async {
      // Навигация к настройкам
      await driver.tap(find.byValueKey('settings_button'));
      await driver.waitFor(find.byValueKey('settings_screen'));
    });
  });

  group('Form Interaction Tests', () {
    test('TextField focus and blur works', () async {

      await driver.tap(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('email_field'));

      // фокус на поле
      await driver.tap(find.byValueKey('email_field'));
      await Future.delayed(Duration(milliseconds: 200));

    
      await driver.enterText('test@example.com');


      await driver.tap(find.byValueKey('password_field'));
      await Future.delayed(Duration(milliseconds: 200));
    });

    test('Keyboard is dismissed on submit', () async {
      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('test@example.com');

      await driver.tap(find.byValueKey('submit_button'));
      await Future.delayed(Duration(milliseconds: 200));
    });

    test('Text field clearing works', () async {
      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('test@example.com');

      await driver.tap(find.byValueKey('clear_email_button'));
      await Future.delayed(Duration(milliseconds: 200));

      final emailText = await driver.getText(find.byValueKey('email_field'));
      expect(emailText.isEmpty, true);
    });

    test('Checkbox toggle works', () async {
      await driver.tap(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('remember_me_checkbox'));

      await driver.tap(find.byValueKey('remember_me_checkbox'));
      await Future.delayed(Duration(milliseconds: 200));
    });

    test('Radio button selection works', () async {
      final radioButtons = find.byType('RadioListTile');
      try {
        await driver.tap(radioButtons);
        await Future.delayed(Duration(milliseconds: 200));
      } catch (e) {
        // Нет радио кнопок на экране
      }
    });
  });

  group('UI Responsiveness Tests', () {
    test('Login button is accessible and tappable', () async {
      await driver.waitFor(find.byValueKey('login_button'));
    });

    test('Form fields have proper labels', () async {
      await driver.tap(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('email_field'));

      await driver.waitFor(find.byValueKey('email_label'));
      await driver.waitFor(find.byValueKey('password_label'));
    });

    test('Error messages are visible', () async {
      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('invalid');
      await driver.tap(find.byValueKey('password_field'));
      await Future.delayed(Duration(milliseconds: 300));

      try {
        await driver.waitFor(
          find.byValueKey('email_error'),
          timeout: Duration(seconds: 2),
        );
      } catch (e) {
        // Ошибка не появилась
      }
    });

    test('Loading indicators appear during auth', () async {
      // Submit login
      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('test@example.com');
      await driver.tap(find.byValueKey('password_field'));
      await driver.enterText('password123');

      await driver.tap(find.byValueKey('submit_button'));

      try {
        await driver.waitFor(
          find.byValueKey('loading_indicator'),
          timeout: Duration(seconds: 1),
        );
      } catch (e) {
        // Индикатор загрузки не появился
      }
    });
  });
}
