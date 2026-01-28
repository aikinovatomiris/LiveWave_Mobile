import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool isLoading = false;
  bool stepReset = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final RegExp _emailRegex =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void _showSnack(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _sendResetEmail() async {
    if (isLoading) return;

    final email = _emailCtrl.text.trim();

    // TC-01 пустой эмейл
    if (email.isEmpty) {
      _showSnack('Введите email');
      return;
    }

    // TC-02 неправильный формат
    if (!_emailRegex.hasMatch(email)) {
      _showSnack('Некорректный формат email');
      return;
    }

    setState(() => isLoading = true);

    final api = ApiService();
    final token = await api.requestPasswordReset(email);

    // TC-03 не найден email
    if (token == null) {
      _showSnack('Ошибка: email не найден');
      setState(() => isLoading = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reset_token', token);
    await prefs.setString('reset_email', email);

    _showSnack('Код для сброса получен!');

    setState(() {
      stepReset = true;
      isLoading = false;
    });
  }

  // пароль и подтверждение
  Future<void> _resetPassword() async {
    if (isLoading) return;

    final password = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    // TC-04 пустой пароль
    if (password.isEmpty || confirm.isEmpty) {
      _showSnack('Введите пароль');
      return;
    }

    // TC-05 длина пароля
    if (password.length < 5) {
      _showSnack('Пароль должен быть не менее 6 символов');
      return;
    }

    // TC-06 совпадение пароля
    if (password != confirm) {
      _showSnack('Пароли не совпадают');
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('reset_token');

    // TC-07 токен не найден
    if (token == null) {
      _showSnack('Ошибка: токен не найден');
      setState(() => isLoading = false);
      return;
    }

    final api = ApiService();
    final success = await api.resetPassword(token, password);

    // TC-08 обновление не сработало 
    if (!success) {
      _showSnack('Ошибка при обновлении пароля');
      setState(() => isLoading = false);
      return;
    }

    _showSnack('Пароль успешно обновлён!');
    await prefs.remove('reset_token');

    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome_bg.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: stepReset
                    ? _buildResetPasswordStep()
                    : _buildEmailStep(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Container(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Сброс пароля',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Введите email, чтобы получить ссылку на сброс пароля.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.email, color: Colors.white70),
              labelText: 'Email',
              labelStyle:
                  const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.black)
                  : const Text('Отправить'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(
                context, Routes.login),
            child: const Text(
              'Назад к входу',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordStep() {
    return Container(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Создание нового пароля',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() =>
                    _obscurePassword = !_obscurePassword),
              ),
              labelText: 'Новый пароль',
              labelStyle:
                  const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() =>
                    _obscureConfirm = !_obscureConfirm),
              ),
              labelText: 'Повторите пароль',
              labelStyle:
                  const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.black)
                  : const Text('Сохранить пароль'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                setState(() => stepReset = false),
            child: const Text(
              'Назад',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
