import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bod_burguer/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Login retains the Juancito design with email authentication', (
    tester,
  ) async {
    setPhoneViewport(tester);
    await tester.pumpWidget(const BodBurguerApp());
    await tester.pumpAndSettle();

    expect(find.text('LOGIN PHONE'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Número de celular'), findsNothing);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.text('Pedir rápido como invitado'), findsOneWidget);
  });

  testWidgets('Guest can open home and switch to the restaurant map', (
    tester,
  ) async {
    setPhoneViewport(tester);
    await tester.pumpWidget(const BodBurguerApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Pedir rápido como invitado'));
    await tester.tap(find.text('Pedir rápido como invitado'));
    await tester.pumpAndSettle();

    expect(find.text('Miraflores, Lima'), findsOneWidget);
    expect(find.text('MEGA PROMO\nDEL MES'), findsOneWidget);
    expect(find.text('Restaurante'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);

    await tester.tap(find.text('Restaurante'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Restaurantes cercanos'), findsOneWidget);
    expect(find.text('BK Benavides Miraflores'), findsWidgets);

    await tester.tap(find.text('Delivery'));
    await tester.pumpAndSettle();
    expect(find.text('MEGA PROMO\nDEL MES'), findsOneWidget);
  });

  testWidgets('Menu categories and crowns screen fit a phone viewport', (
    tester,
  ) async {
    setPhoneViewport(tester);
    await tester.pumpWidget(const BodBurguerApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Pedir rápido como invitado'));
    await tester.tap(find.text('Pedir rápido como invitado'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menú').last);
    await tester.pumpAndSettle();
    expect(find.text('Explora el menú'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsWidgets);
    expect(tester.takeException(), isNull);
    final whopperCategory = find.widgetWithText(ChoiceChip, 'Whopper®');
    await tester.ensureVisible(whopperCategory);
    await tester.tap(whopperCategory);
    await tester.pumpAndSettle();
    expect(find.text('Whopper Doble con Queso'), findsOneWidget);
    expect(find.text('Sundae de chocolate'), findsNothing);

    await tester.tap(find.byIcon(Icons.workspace_premium).first);
    await tester.pumpAndSettle();
    expect(find.text('450'), findsOneWidget);
    expect(find.text('Premios para ti'), findsOneWidget);
    expect(find.text('Te faltan 50'), findsOneWidget);
    for (var index = 0; index < 5; index++) {
      expect(find.byKey(ValueKey('section-navigation-$index')), findsOneWidget);
    }
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('section-navigation-0')));
    await tester.pumpAndSettle();
    expect(find.text('Explora el menú'), findsOneWidget);
  });

  testWidgets('Product can be customized and opened in the persistent cart', (
    tester,
  ) async {
    setPhoneViewport(tester);
    await tester.pumpWidget(const BodBurguerApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Pedir rápido como invitado'));
    await tester.tap(find.text('Pedir rápido como invitado'));
    await tester.pumpAndSettle();

    final product = find.text('Whopper Clásico').first;
    await tester.ensureVisible(product);
    await tester.tap(product);
    await tester.pumpAndSettle();

    expect(find.text('Quita lo que no te gusta'), findsOneWidget);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Cebolla'));
    await tester.tap(find.text('Agregar · S/ 21.50'));
    await tester.pumpAndSettle();
    expect(find.text('Agregar · S/ 21.50'), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    final savedItems =
        jsonDecode(preferences.getString('bod_burguer_cart')!) as List;
    expect(savedItems.single['removedIngredients'], contains('Cebolla'));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Tu carrito'), findsOneWidget);
    expect(find.text('Sin: Cebolla'), findsOneWidget);
    expect(find.text('Total: S/ 21.50'), findsOneWidget);

    await tester.tap(find.byTooltip('Agregar una unidad de Whopper Clásico'));
    await tester.pumpAndSettle();
    expect(find.text('Total: S/ 43.00'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar Whopper Clásico'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tu carrito está vacío. Agrega algo del menú.'),
      findsOneWidget,
    );
  });
}
