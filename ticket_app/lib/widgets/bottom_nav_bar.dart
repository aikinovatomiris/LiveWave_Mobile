import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');

    setState(() {
      _isAdmin = role == 'ADMIN';
      final maxIndex = _isAdmin ? 4 : 3;
      if (_selectedIndex > maxIndex) _selectedIndex = 0;
    });
  }

  List<_NavItemData> _visibleItems() {
    final navItems = [
      const _NavItemData(icon: Icons.home_outlined, route: Routes.home),
      const _NavItemData(icon: Icons.grid_view, route: Routes.afisha),
      const _NavItemData(icon: Icons.confirmation_num_outlined, route: Routes.myTickets),
      const _NavItemData(icon: Icons.person, route: Routes.profile),
    ];
    if (_isAdmin) {
      navItems.add(const _NavItemData(
        icon: Icons.admin_panel_settings_outlined,
        route: Routes.admin,
      ));
    }
    return navItems;
  }

  Future<void> _onItemTapped(BuildContext context, int index) async {
    final navItems = _visibleItems();

    if (index >= navItems.length) return;
    if (_selectedIndex == index) return;

    if (navItems[index].route == Routes.profile) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        Navigator.pushNamed(context, Routes.login);
        return;
      }
    }

    setState(() => _selectedIndex = index);

    Future.delayed(const Duration(milliseconds: 150), () {
      Navigator.pushReplacementNamed(context, navItems[index].route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _visibleItems();
    final widthFactor = _isAdmin ? 0.9 : 0.85;

    return Container(
      height: 95,
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width * widthFactor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  navItems.length,
                  (index) => _NavButton(
                    icon: navItems[index].icon,
                    isActive: _selectedIndex == index,
                    onTap: () => _onItemTapped(context, index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2F8CFF);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black.withOpacity(0.7),
          size: 28,
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String route;
  const _NavItemData({required this.icon, required this.route});
}
