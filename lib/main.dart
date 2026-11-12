import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'auth_gate.dart';
import 'firebase_options.dart';
import 'services/account_service.dart';
import 'services/order_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;

  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (error) {
      startupError =
          'No se pudo iniciar Firebase (${error.code}). '
          'Revisa la configuración del proyecto.';
    } on UnsupportedError catch (error) {
      startupError = error.message;
    }
  }

  runApp(BodBurguerApp(startupError: startupError));
}

class BodBurguerApp extends StatelessWidget {
  const BodBurguerApp({
    super.key,
    this.accountService = const FirebaseAccountService(),
    this.orderService = const FirebaseOrderService(),
    this.startupError,
  });

  final AccountService accountService;
  final OrderService orderService;
  final String? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burger King Perú',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data,
      home: AuthGate(
        accountService: accountService,
        orderService: orderService,
        startupError: startupError,
      ),
    );
  }
}
