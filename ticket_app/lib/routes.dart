import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/afisha_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/seat_selection_screen.dart';
import 'screens/purchase_screen.dart';
import 'models/event.dart';
import 'screens/profile_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/user_tickets_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/admin_screen.dart';

class Routes {
  static const String home = '/';
  static const String login = '/login';
  static const String afisha = '/afisha';
  static const String eventDetail = '/event-detail';
  static const String seatSelection = '/seat-selection';
  static const String purchase = '/purchase';
  static const String profile = '/profile';
  static const String welcome = '/welcome';
  static const String myTickets = '/my-tickets';
  static const String forgotPassword = '/forgot-password';
  static const String admin = '/admin';
}

class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Route _noAnim(Widget page) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    }

    Route _fadeSlide(Widget page) {
      return PageRouteBuilder(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          final slide = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
      );
    }

    switch (settings.name) {
      case Routes.welcome:
        return _noAnim(const WelcomeScreen());
      case Routes.home:
        return _noAnim(const HomeScreen());
      case Routes.login:
        return _noAnim(const LoginScreen());
      case Routes.afisha:
        return _noAnim(const AfishaScreen());

      case Routes.eventDetail:
        final event = settings.arguments as Event;
        return _fadeSlide(EventDetailScreen(event: event));

      case Routes.seatSelection:
        final args = settings.arguments;
        if (args is Event) {
          return _noAnim(SeatSelectionScreen(event: args));
        } else if (args is Map && args['event'] is Event) {
          return _noAnim(SeatSelectionScreen(event: args['event'] as Event));
        }
        return null;

      case Routes.purchase:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['event'] is Event &&
            args['selectedSeats'] is List<String>) {
          return _noAnim(
            PurchaseScreen(
              event: args['event'] as Event,
              selectedSeats: List<String>.from(args['selectedSeats'] as List),
            ),
          );
        }
        return null;

      case Routes.myTickets:
        return _noAnim(const MyTicketsScreen());
      case Routes.profile:
        return _noAnim(const ProfileScreen());
      case Routes.forgotPassword:
        return _noAnim(const ForgotPasswordScreen());
      case Routes.admin:
        return _noAnim(const AdminScreen());

      default:
        return _noAnim(const HomeScreen());
    }
  }
}
