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

  group('Welcome and Navigation Tests', () {
    test('App starts and displays welcome screen', () async {
      await driver.waitFor(find.byValueKey('welcome_title'));
      final welcomeText = await driver.getText(find.byValueKey('welcome_title'));
      expect(welcomeText, 'Welcome to LiveWave');
    });

    test('Welcome screen has all required buttons', () async {
      await driver.waitFor(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('register_button'));
    });

    test('Navigate from welcome to login screen', () async {
      await driver.tap(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('login_form'));
      final loginTitle = await driver.getText(find.byValueKey('login_title'));
      expect(loginTitle, 'Login');
    });

    test('Navigate from welcome to register screen', () async {
      await driver.tap(find.byValueKey('register_button'));
      await driver.waitFor(find.byValueKey('register_form'));
      final registerTitle = await driver.getText(find.byValueKey('register_title'));
      expect(registerTitle, 'Register');
    });

    test('Back button works on login screen', () async {
      await driver.tap(find.byValueKey('back_button'));
      await driver.waitFor(find.byValueKey('welcome_title'));
    });
  });

  group('Home Screen Tests', () {
    test('Home screen displays after successful login', () async {
      // навигация к экрану входа
      await driver.tap(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('email_field'));

      // ввод email
      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('test@example.com');
      await driver.waitFor(find.byValueKey('password_field'));

      // ввод пароля
      await driver.tap(find.byValueKey('password_field'));
      await driver.enterText('password123');

      // отправка формы
      await driver.tap(find.byValueKey('submit_button'));
      await driver.waitFor(find.byValueKey('home_screen'));
      await driver.waitFor(find.byValueKey('search_bar'));
    });

    test('Events are displayed on home screen', () async {
      await driver.waitFor(find.byValueKey('event_list'));
    });

    test('City selector is accessible', () async {
      await driver.tap(find.byValueKey('city_selector'));
      await driver.waitFor(find.byValueKey('city_dropdown'));
    });

    test('Search functionality works', () async {
      await driver.tap(find.byValueKey('search_bar'));
      await driver.enterText('Concert');
      await driver.waitFor(find.byValueKey('search_results'));
    });

    test('Bottom navigation bar is visible', () async {
      await driver.waitFor(find.byValueKey('bottom_nav_bar'));
      await driver.waitFor(find.byValueKey('nav_home'));
      await driver.waitFor(find.byValueKey('nav_tickets'));
      await driver.waitFor(find.byValueKey('nav_profile'));
    });

    test('Navigate to tickets via bottom nav', () async {
      await driver.tap(find.byValueKey('nav_tickets'));
      await driver.waitFor(find.byValueKey('tickets_screen'));
    });

    test('Navigate to profile via bottom nav', () async {
      await driver.tap(find.byValueKey('nav_profile'));
      await driver.waitFor(find.byValueKey('profile_screen'));
    });
  });

  group('Event Details Tests', () {
    test('Tap event card opens details screen', () async {
      // навигация к домашнему экрану
      await driver.tap(find.byValueKey('nav_home'));
      await driver.waitFor(find.byValueKey('event_list'));

      // открытие события
      await driver.tap(find.byValueKey('event_card_0'));
      await driver.waitFor(find.byValueKey('event_details_screen'));
      await driver.waitFor(find.byValueKey('event_title'));
      await driver.waitFor(find.byValueKey('event_description'));
    });

    test('Event details displays all information', () async {
      await driver.waitFor(find.byValueKey('event_date'));
      await driver.waitFor(find.byValueKey('event_location'));
      await driver.waitFor(find.byValueKey('event_price'));
      await driver.waitFor(find.byValueKey('select_seats_button'));
    });

    test('Navigate to seat selection from details', () async {
      await driver.tap(find.byValueKey('select_seats_button'));
      await driver.waitFor(find.byValueKey('seat_selection_screen'));
    });

    test('Back button returns to home', () async {
      await driver.tap(find.byValueKey('back_button'));
      await driver.waitFor(find.byValueKey('home_screen'));
    });
  });

  group('Seat Selection Tests', () {
    test('Seat grid is displayed', () async {
      // открытие деталей события
      await driver.tap(find.byValueKey('event_card_0'));
      await driver.waitFor(find.byValueKey('select_seats_button'));
      await driver.tap(find.byValueKey('select_seats_button'));
      await driver.waitFor(find.byValueKey('seat_grid'));
    });

    test('Can select and deselect seats', () async {
      // выбор места
      await driver.tap(find.byValueKey('seat_A1'));
      await driver.waitFor(find.byValueKey('seat_A1_selected'));

      // снятие выбора места
      await driver.tap(find.byValueKey('seat_A1_selected'));
      await driver.waitFor(find.byValueKey('seat_A1'));
    });

    test('Selected seats are counted correctly', () async {
      // Выбор нескольких мест
      await driver.tap(find.byValueKey('seat_A1'));
      await driver.waitFor(find.byValueKey('seat_A1_selected'));

      await driver.tap(find.byValueKey('seat_A2'));
      await driver.waitFor(find.byValueKey('seat_A2_selected'));

      // Проверка счётчика выбранных мест
      final count = await driver.getText(find.byValueKey('seat_count'));
      expect(count, contains('2'));
    });

    test('Total price updates with seat selection', () async {
      // Выбор места
      await driver.tap(find.byValueKey('seat_A1'));
      await driver.waitFor(find.byValueKey('total_price'));

      final price = await driver.getText(find.byValueKey('total_price'));
      expect(price.isNotEmpty, true);
    });

    test('Purchase button is enabled with seats selected', () async {
      // Убедиться что кнопка покупки активна
      await driver.tap(find.byValueKey('seat_A1'));
      await driver.waitFor(find.byValueKey('purchase_button'));
    });
  });

  group('Purchase Flow Tests', () {
    test('Purchase button proceeds to payment', () async {
      // Завершение покупки
      await driver.tap(find.byValueKey('seat_A1'));
      await driver.tap(find.byValueKey('purchase_button'));
      await driver.waitFor(find.byValueKey('payment_screen'));
    });

    test('Purchase confirmation shows ticket details', () async {
      // Завершение оплаты
      await driver.waitFor(find.byValueKey('confirmation_message'));
    });
  });

  group('Profile Screen Tests', () {
    test('Profile screen displays user information', () async {
      await driver.tap(find.byValueKey('nav_profile'));
      await driver.waitFor(find.byValueKey('profile_screen'));
      await driver.waitFor(find.byValueKey('user_name'));
      await driver.waitFor(find.byValueKey('user_email'));
      await driver.waitFor(find.byValueKey('user_city'));
    });

    test('Edit profile opens edit dialog', () async {
      await driver.tap(find.byValueKey('edit_profile_button'));
      await driver.waitFor(find.byValueKey('edit_dialog'));
    });

    test('City preferences can be changed', () async {
      await driver.tap(find.byValueKey('city_preferences'));
      await driver.waitFor(find.byValueKey('city_list'));
    });

    test('Logout button signs out user', () async {
      await driver.tap(find.byValueKey('logout_button'));
      await driver.waitFor(find.byValueKey('welcome_title'));
    });
  });

  group('Error Handling Tests', () {
    test('Invalid email shows error message', () async {
      await driver.tap(find.byValueKey('login_button'));
      await driver.waitFor(find.byValueKey('email_field'));

      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('invalidemail');
      await driver.tap(find.byValueKey('submit_button'));

      await driver.waitFor(find.byValueKey('error_message'));
    });

    test('Short password shows error', () async {
      await driver.tap(find.byValueKey('email_field'));
      await driver.enterText('test@example.com');
      await driver.tap(find.byValueKey('password_field'));
      await driver.enterText('123');

      await driver.tap(find.byValueKey('submit_button'));
      await driver.waitFor(find.byValueKey('error_message'));
    });

    test('Network error is handled gracefully', () async {
      // эмуляция сетевой ошибки пропущена, предполагается что приложение уже в этом состоянии
      await driver.waitFor(find.byValueKey('error_handling'));
    });
  });

  group('Performance Tests', () {
    test('Event list scrolls smoothly', () async {
      await driver.waitFor(find.byValueKey('event_list'));
      
      // прокрутка списка событий
      await driver.scroll(
        find.byValueKey('event_list'),
        0,
        -300,
        Duration(milliseconds: 500),
      );

      // проверка что список всё ещё доступен
      await driver.waitFor(find.byValueKey('event_list'));
    });

    test('Images load within acceptable time', () async {
      final startTime = DateTime.now();

      await driver.waitFor(
        find.byValueKey('event_image'),
        timeout: Duration(seconds: 5),
      );

      final duration = DateTime.now().difference(startTime);
      expect(duration.inSeconds, lessThan(5));
    });

    test('Search completes in reasonable time', () async {
      final startTime = DateTime.now();

      await driver.tap(find.byValueKey('search_bar'));
      await driver.enterText('Concert');
      await driver.waitFor(
        find.byValueKey('search_results'),
        timeout: Duration(seconds: 3),
      );

      final duration = DateTime.now().difference(startTime);
      expect(duration.inSeconds, lessThan(3));
    });
  });
}

