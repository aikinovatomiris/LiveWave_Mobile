import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/graphql_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

  Future<void> _submit() async {
    setState(() => isLoading = true);
    final api = ApiService();

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (!isLogin && (name.isEmpty || email.isEmpty || password.isEmpty)) {
      _showError('Пожалуйста, заполните все поля');
      return;
    }

    if (isLogin && (email.isEmpty || password.isEmpty)) {
      _showError('Введите email и пароль');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      _showError('Введите корректный адрес электронной почты');
      return;
    }

    if (password.length < 5) {
      _showError('Пароль должен содержать не менее 5 символов');
      return;
    }

    try {
      if (!isLogin) {
        final registerResponse = await api.register(name, email, password);
        if (registerResponse.statusCode != 200 && registerResponse.statusCode != 201) {
          String errorMessage = 'Ошибка регистрации';
          try {
            final body = jsonDecode(registerResponse.body);
            errorMessage = body['message'] ?? errorMessage;
          } catch (_) {}
          _showError('$errorMessage (${registerResponse.statusCode})');
          return;
        }

        final loginResponse = await api.login(email, password);
        await _handleLoginResponse(loginResponse);
      } else {
        final response = await api.login(email, password);
        await _handleLoginResponse(response);
      }
    } catch (e) {
      _showError('Ошибка соединения. Проверьте интернет или попробуйте позже.');
    } finally {
      setState(() => isLoading = false);
    }
  }

Future<void> _handleLoginResponse(dynamic response) async {
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', data['token']);
    await prefs.setString('user_role', data['role']);

    await GraphQLService.instance.init(token: data['token']);

    print("LOGIN SUCCESS");

    // 🔥 ПОЛУЧАЕМ FCM токен
    final messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("NOTIFICATION PERMISSION: ${settings.authorizationStatus}");

    String? fcmToken = await messaging.getToken();

    print("=====================================");
    print("FCM TOKEN FROM DEVICE: $fcmToken");
    print("=====================================");

    if (fcmToken != null && fcmToken.isNotEmpty) {
      print("SENDING TOKEN TO BACKEND...");
      final result = await ApiService().sendFcmToken(data['token'], fcmToken);
      print("SEND RESULT: $result");
    } else {
      print("FCM TOKEN IS NULL !!!");
    }

    Navigator.pushReplacementNamed(context, Routes.home);
  } else {
    String message = 'Неверный email или пароль';
    try {
      final body = jsonDecode(response.body);
      message = body['message'] ?? message;
    } catch (_) {}
    _showError(message);
  }
}


  void _showError(String message) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.shade200,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _continueWithoutLogin() async {
    await GraphQLService.instance.initAsGuest();
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/welcome_bg.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),

          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLogin ? 'Вход' : 'Регистрация',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!isLogin)
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person, color: Colors.white70),
                          labelText: 'Имя',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    if (!isLogin) const SizedBox(height: 12),

                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, color: Colors.white70),
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        labelText: 'Пароль',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                                isLogin ? 'Войти' : 'Зарегистрироваться',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin
                            ? 'Нет аккаунта? Зарегистрироваться'
                            : 'Уже есть аккаунт? Войти',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: _continueWithoutLogin,
                      child: const Text(
                        'Продолжить без авторизации',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text(
                        'Забыли пароль?',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
