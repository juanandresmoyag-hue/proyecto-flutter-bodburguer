import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bod_burguer/home_screen.dart';
import 'package:bod_burguer/main.dart';
import 'package:bod_burguer/promotions_screen.dart';
import 'package:bod_burguer/restaurant_map_view.dart';
import 'package:bod_burguer/cart_screen.dart';
import 'package:bod_burguer/services/account_service.dart';
import 'package:bod_burguer/services/order_service.dart';

import 'support/fake_services.dart';
import 'support/network_images.dart';

void main() {
  testWidgets('guest can browse coupons and save a favorite', (tester) async {
    await pumpApp(tester);

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
    await pumpApp(tester);

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
    await pumpApp(tester);

    await tester.ensureVisible(find.text('INICIAR SESIÓN'));
    await tester.tap(find.text('INICIAR SESIÓN'));
    await tester.pump();

    expect(find.text('Ingresa tus datos para iniciar sesión.'), findsOneWidget);
    expect(find.byType(PromotionsScreen), findsNothing);
  });

  testWidgets('app loads login screen', (tester) async {
    await pumpApp(tester);
    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
  });

  testWidgets('login opens home and home links to coupons', (tester) async {
    final accountService = FakeAccountService();
    await withLocalNetworkImages(() async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpApp(
        tester,
        accountService: accountService,
        orderService: FakeOrderService(),
      );
      await tester.ensureVisible(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'alex@example.com');
      await tester.ensureVisible(find.byType(TextField).last);
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.ensureVisible(find.text('INICIAR SESIÓN'));
      await tester.tap(find.text('INICIAR SESIÓN'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.tap(find.text('Cupones'));
      await tester.pumpAndSettle();
      expect(find.byType(PromotionsScreen), findsOneWidget);
    });
    expect(accountService.events, ['sign_in']);
    expect(accountService.rememberedEmail, 'alex@example.com');
  });

  testWidgets('home opens restaurant map from change location', (tester) async {
    await withLocalNetworkImages(() async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.ensureVisible(find.text('Cambiar'));
      await tester.tap(find.text('Cambiar'));
      await tester.pumpAndSettle();

      expect(find.byType(RestaurantMapView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('remembered email is restored without a saved password', (
    tester,
  ) async {
    final accountService = FakeAccountService()
      ..rememberedEmail = 'alex@example.com';
    await pumpApp(tester, accountService: accountService);

    expect(find.text('alex@example.com'), findsOneWidget);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isTrue,
    );
    expect(accountService.rememberedEmail, 'alex@example.com');
  });

  testWidgets('cart adjusts quantities and saves an order for the user', (
    tester,
  ) async {
    final accountService = FakeAccountService(
      session: const AccountSession(
        uid: 'user-1',
        email: 'alex@example.com',
        displayName: 'Alex Parrilla',
      ),
    );
    final orderService = FakeOrderService();
    var cart = const [
      CartItem(id: 'whopper', name: 'Whopper', unitPrice: 21.50, quantity: 1),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: CartScreen(
          items: cart,
          accountService: accountService,
          orderService: orderService,
          onItemsChanged: (items) => cart = items,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Agregar una unidad de Whopper'));
    await tester.pumpAndSettle();
    expect(find.text('Total: S/ 43.00'), findsOneWidget);

    await tester.tap(find.text('Guardar pedido'));
    await tester.pumpAndSettle();

    expect(orderService.lastUserId, 'user-1');
    expect(orderService.lastItems!.single.quantity, 2);
    expect(cart, isEmpty);
    expect(
      find.text('Tu carrito está vacío. Agrega algo del menú.'),
      findsOneWidget,
    );
    expect(find.textContaining('Pedido guardado en tu cuenta'), findsOneWidget);
  });
}

Future<void> pumpApp(
  WidgetTester tester, {
  FakeAccountService? accountService,
  FakeOrderService? orderService,
}) async {
  await tester.pumpWidget(
    BodBurguerApp(
      accountService: accountService ?? FakeAccountService(),
      orderService: orderService ?? FakeOrderService(),
    ),
  );
  await tester.pumpAndSettle();
}
