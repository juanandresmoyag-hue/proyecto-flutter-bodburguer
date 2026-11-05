import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bod_burguer/main.dart';

void main() {
  testWidgets('Login screen has no back arrow, no close button, and no email option', (WidgetTester tester) async {
    await tester.pumpWidget(const BodBurguerApp());

    // Header has title
    expect(find.text('LOGIN PHONE'), findsOneWidget);

    // No back button icon
    expect(find.byIcon(Icons.arrow_back), findsNothing);

    // No close button icon in header
    expect(find.byTooltip('Limpiar campos'), findsNothing);

    // No email tab / selector
    expect(find.text('Correo'), findsNothing);
    expect(find.text('Correo electrónico'), findsNothing);

    // Has phone number field
    expect(find.text('Número de celular'), findsOneWidget);
  });

  testWidgets('Navigates to HomeScreen after login and tests Restaurante map view', (WidgetTester tester) async {
    await tester.pumpWidget(const BodBurguerApp());

    // Enter phone and password to login
    await tester.enterText(find.byType(TextField).first, '987654321');
    await tester.enterText(find.byType(TextField).last, '123456');

    // Scroll to and tap Iniciar Sesión
    final loginBtn = find.text('INICIAR SESIÓN');
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    // Verify we are now on HomeScreen
    expect(find.text('Miraflores, Lima'), findsOneWidget);
    expect(find.text('MEGA PROMO\nDEL MES'), findsOneWidget);
    expect(find.text('Restaurante'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text('Auto-King'), findsNothing);

    // Tap "Restaurante" tab
    await tester.tap(find.text('Restaurante'));
    await tester.pumpAndSettle();

    // Verify restaurant map view and store schedules are shown
    expect(find.textContaining('Restaurantes cercanos'), findsOneWidget);
    expect(find.text('BK Benavides Miraflores'), findsWidgets);
    expect(find.textContaining('10:00 AM - 11:30 PM'), findsWidgets);

    // Tap back on "Delivery"
    await tester.tap(find.text('Delivery'));
    await tester.pumpAndSettle();

    // Verify we are back to the home feed
    expect(find.text('MEGA PROMO\nDEL MES'), findsOneWidget);
  });
}
