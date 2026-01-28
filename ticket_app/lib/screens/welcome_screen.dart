import 'package:flutter/material.dart';
import '../routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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

          Container(color: Colors.black.withOpacity(0.5)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80, left: 24, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, 
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'LiveWave',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Лучший выбор для покупки билетов',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), 
                  SizedBox(
                    width: double.infinity, 
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, Routes.login);
                      },
                      child: const Text(
                        'Продолжить',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
