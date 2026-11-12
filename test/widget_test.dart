import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bod_burguer/main.dart';
import 'package:bod_burguer/promotions_screen.dart';

void main() {
  testWidgets('guest can browse coupons and save a favorite', (tester) async {
    await tester.pumpWidget(const BodBurguerApp());

    await tester.ensureVisible(find.text('Pedir rápido como invitado'));
    await tester.tap(find.text('Pedir rápido como invitado'));
    await tester.pumpAndSettle();

    expect(find.byType(PromotionsScreen), findsOneWidget);
    expect(find.text('EXCLUSIVO PRIMERA COMPRA'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('2 Whopper® Jr. + 2 Papas Regulares'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Agregar a favoritos').first);
    await tester.tap(find.byTooltip('Agregar a favoritos').first);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('2 Whopper® Jr. + 2 Papas Regulares'), findsOneWidget);
    expect(find.text('Duo Stacker Doble + 2 Bebidas'), findsNothing);
  });

  testWidgets('coupon redemption asks for confirmation', (tester) async {
    await tester.pumpWidget(const BodBurguerApp());

    await tester.ensureVisible(find.text('Pedir rápido como invitado'));
    await tester.tap(find.text('Pedir rápido como invitado'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Canjear').first);
    await tester.tap(find.text('Canjear').first);
    await tester.pumpAndSettle();
    expect(
      find.text(
        '¿Quieres canjear "2 Whopper® Jr. + 2 Papas Regulares" por S/ 25.90?',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Canjear').last);
    await tester.pumpAndSettle();
    expect(find.text('Canjeado'), findsOneWidget);
  });

  testWidgets('login requires an identifier and password', (tester) async {
    await tester.pumpWidget(const BodBurguerApp());

    await tester.ensureVisible(find.text('INICIAR SESIÓN'));
    await tester.tap(find.text('INICIAR SESIÓN'));
    await tester.pump();

    expect(find.text('Ingresa tus datos para iniciar sesión.'), findsOneWidget);
    expect(find.byType(PromotionsScreen), findsNothing);
  });

  testWidgets('app loads login screen', (tester) async {
    await tester.pumpWidget(const BodBurguerApp());
    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
  });
}
