import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitySelector extends StatefulWidget {
  final ValueChanged<String> onCityChanged;

  const CitySelector({Key? key, required this.onCityChanged}) : super(key: key);

  @override
  State<CitySelector> createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  final List<String> cities = ['Алматы', 'Астана'];
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('selectedCity') ?? 'Алматы';
    setState(() => _selectedCity = savedCity);
    widget.onCityChanged(savedCity);
  }

  Future<void> _saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          dropdownColor: const Color(0xFF1E1E1E),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          borderRadius: BorderRadius.circular(25),
          items: cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(
                city,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCity = value);
              _saveCity(value);
              widget.onCityChanged(value);
            }
          },
        ),
      ),
    );
  }
}
