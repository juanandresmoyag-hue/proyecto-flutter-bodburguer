import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'login_screen.dart';

void main() {
  runApp(const BodBurguerApp());
}

class BodBurguerApp extends StatelessWidget {
  const BodBurguerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burger King Perú',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data,
      home: const LoginScreen(),
    );
  }
}
