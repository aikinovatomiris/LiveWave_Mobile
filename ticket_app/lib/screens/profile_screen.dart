import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/city_selector.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  String? token;

  String _selectedAvatar = 'assets/images/avatar5.JPG';
  String _userName = 'Загрузка...';
  String _userEmail = '';
  String _city = 'Алматы';
  bool _isLoading = true;

  static const _glass = Color(0x1FFFFFFF); 
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xCCFFFFFF); 
  static const _textMuted = Color(0x99FFFFFF); 
  static const _dividerColor = Color(0x22FFFFFF);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwt_token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, Routes.login);
      return;
    }

    try {
      final data = await _apiService.fetchUserProfile(token!);
      if (data != null) {
        setState(() {
          _userName = data['name'] ?? 'Без имени';
          _userEmail = data['email'] ?? 'Неизвестно';
          _selectedAvatar = prefs.getString('user_avatar') ?? _selectedAvatar;
          _city = prefs.getString('selectedCity') ?? 'Алматы';
          _isLoading = false;
        });

        await prefs.setString('user_name', _userName);
        await prefs.setString('user_email', _userEmail);
      } else {
        await prefs.remove('jwt_token');
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    } catch (e) {
      print("Ошибка загрузки профиля: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  void _openEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController(text: _userName);
        final emailCtrl = TextEditingController(text: _userEmail);

        InputDecoration deco(String label, IconData icon) {
          return InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: _textMuted),
            prefixIcon: Icon(icon, color: _textMuted),
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.28)),
            ),
          );
        }

        return AlertDialog(
          backgroundColor: const Color(0xFF0E0E0E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Редактировать профиль",
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: _textPrimary),
                decoration: deco('Имя', Icons.person_outline),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: _textPrimary),
                decoration: deco('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Выберите аватар",
                  style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final img in [
                    'assets/images/avatar1.JPG',
                    'assets/images/avatar3.JPG',
                    'assets/images/avatar4.JPG',
                    'assets/images/avatar5.JPG'
                  ])
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('user_avatar', img);
                        setState(() => _selectedAvatar = img);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedAvatar == img
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.white.withOpacity(0.18),
                              width: _selectedAvatar == img ? 2 : 1,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(img),
                            radius: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена", style: TextStyle(color: _textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('jwt_token');

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ошибка: токен не найден. Авторизуйтесь снова.')),
                  );
                  return;
                }

                final updatedName = nameCtrl.text.trim();
                final updatedEmail = emailCtrl.text.trim();

                try {
                  final response = await _apiService.updateUserProfile(token, {
                    "name": updatedName,
                    "email": updatedEmail,
                  });

                  if (response != null && response['message'] == "Profile updated successfully") {
                    await prefs.setString('user_name', updatedName);
                    await prefs.setString('user_email', updatedEmail);

                    setState(() {
                      _userName = updatedName;
                      _userEmail = updatedEmail;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Профиль успешно обновлён!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Не удалось обновить профиль')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Сохранить", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _changeCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
    setState(() => _city = city);
  }

  void _showMiniPopup({required String title, required String message, IconData? icon}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E0E0E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: _textSecondary, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ок", style: TextStyle(color: _textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Icon(icon, color: _textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.65), size: 26),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: _dividerColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.JPEG',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // лёгкая затемняющая вуаль, чтобы белый текст читался лучше
          // Container(color: Colors.black.withOpacity(0.22)),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _glassCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.20)),
                                    ),
                                    child: CircleAvatar(
                                      radius: 36,
                                      backgroundImage: AssetImage(_selectedAvatar),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _userName,
                                          style: const TextStyle(
                                            color: _textPrimary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _userEmail,
                                          style: const TextStyle(
                                            color: _textMuted,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: ElevatedButton.icon(
                                            onPressed: _openEditProfileDialog,
                                            icon: const Icon(Icons.edit, color: Colors.black, size: 18),
                                            label: const Text(
                                              "Редактировать",
                                              style: TextStyle(fontWeight: FontWeight.w800),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle("Аккаунт"),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _glassCard(
                            child: Column(
                              children: [
                                _menuTile(
                                  icon: Icons.location_city_outlined,
                                  title: 'Мой город',
                                  subtitle: _city,
                                  trailing: CitySelector(onCityChanged: _changeCity),
                                  onTap: null,
                                ),
                                _divider(),
                                _menuTile(
                                  icon: Icons.lock_outline_rounded,
                                  title: 'Изменить пароль',
                                  subtitle: 'Сброс / восстановление',
                                  onTap: () {
                                    Navigator.pushNamed(context, Routes.forgotPassword);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle("Информация"),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _glassCard(
                            child: Column(
                              children: [
                                _menuTile(
                                  icon: Icons.support_agent_rounded,
                                  title: 'Связаться с поддержкой',
                                  subtitle: 'Написать или получить помощь',
                                  onTap: () {
                                    _showMiniPopup(
                                      title: 'Поддержка',
                                      message: 'Emaile: support@livewave.kz\nТелефон: +7 777 123 4567',
                                      icon: Icons.support_agent_rounded,
                                    );
                                  },
                                ),
                                _divider(),
                                _menuTile(
                                  icon: Icons.info_outline_rounded,
                                  title: 'О приложении',
                                  subtitle: 'Версия и информация',
                                  onTap: () {
                                    _showMiniPopup(
                                      title: 'О приложении',
                                      message: 'LiveWave Ticket App\n Ваш помошник в покупке билетов!\nВерсия: 1.0.0',
                                      icon: Icons.info_outline_rounded,
                                    );
                                  },
                                ),
                                _divider(),
                                _menuTile(
                                  icon: Icons.notifications_none_rounded,
                                  title: 'Настройки уведомлений',
                                  subtitle: 'Управление push-уведомлениями',
                                  onTap: () {
                                    _showMiniPopup(
                                      title: 'Уведомления',
                                      message: 'Перейти в настройки уведомлений телефона\n',
                                      icon: Icons.notifications_none_rounded,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Выйти из аккаунта',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.75),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: Opacity(
                opacity: 0.9,
                child: BottomNavBar(currentIndex: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}