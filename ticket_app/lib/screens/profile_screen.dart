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
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Редактировать профиль", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Имя',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text("Выберите аватар:", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
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
                        child: CircleAvatar(
                          backgroundImage: AssetImage(img),
                          radius: 24,
                          child: _selectedAvatar == img
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
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
              child: const Text("Сохранить", style: TextStyle(color: Colors.blueAccent)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Image.asset('assets/images/background.JPEG',
              fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Container(),

          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundImage: AssetImage(_selectedAvatar),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _userName,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                _userEmail,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white70),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _openEditProfileDialog,
                                icon: const Icon(Icons.edit, color: Colors.black),
                                label: const Text("Редактировать профиль"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Card(
                                color: Colors.black.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.location_city,
                                          color: Colors.white70),
                                      title: const Text('Мой город',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      subtitle: Text(_city,
                                          style: const TextStyle(
                                              color: Colors.white54)),
                                      trailing: CitySelector(
                                        onCityChanged: _changeCity,
                                      ),
                                    ),
                                    const Divider(color: Colors.white24, height: 0),
                                    ListTile(
                                      leading: const Icon(Icons.lock_outline,
                                          color: Colors.white70),
                                      title: const Text('Изменить пароль',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, Routes.forgotPassword);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              Card(
                                color: Colors.black.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.phone,
                                          color: Colors.white70),
                                      title: Text('Связаться с поддержкой',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    Divider(color: Colors.white24, height: 0),
                                    ListTile(
                                      leading: Icon(Icons.info_outline,
                                          color: Colors.white70),
                                      title: Text('О приложении',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    Divider(color: Colors.white24, height: 0),
                                    ListTile(
                                      leading: Icon(Icons.notifications_none,
                                          color: Colors.white70),
                                      title: Text('Настройки уведомлений',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text('Выйти из аккаунта',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
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
