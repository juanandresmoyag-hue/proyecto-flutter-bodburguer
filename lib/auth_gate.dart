import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'services/account_service.dart';
import 'services/order_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.accountService,
    required this.orderService,
    this.startupError,
  });

  final AccountService accountService;
  final OrderService orderService;
  final String? startupError;

  @override
  Widget build(BuildContext context) {
    if (startupError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(startupError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return StreamBuilder<AccountSession?>(
      stream: accountService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('No se pudo recuperar la sesión de Firebase.'),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final session = snapshot.data;
        if (session == null) {
          return LoginScreen(accountService: accountService);
        }
        return HomeScreen(
          accountService: accountService,
          orderService: orderService,
          session: session,
        );
      },
    );
  }
}
