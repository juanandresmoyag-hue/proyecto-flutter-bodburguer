import 'package:bod_burguer/app_theme.dart';
import 'package:bod_burguer/contact_screen.dart';
import 'package:bod_burguer/home_screen.dart';
import 'package:bod_burguer/login_screen.dart';
import 'package:bod_burguer/newsletter_screen.dart';
import 'package:bod_burguer/notification_settings_screen.dart';
import 'package:bod_burguer/profile_screen.dart';
import 'package:bod_burguer/quick_guide_screen.dart';
import 'package:bod_burguer/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_services.dart';
import 'support/network_images.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.data,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, int index, String value) async {
  final field = find.byType(TextFormField).at(index);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> fillRegistration(WidgetTester tester) async {
  await fill(tester, 0, 'Alex Parrilla');
  await fill(tester, 1, 'alex@ejemplo.com');
  await fill(tester, 2, '987654321');
  await fill(tester, 3, 'ClaveDemo123');
  await fill(tester, 4, 'ClaveDemo123');
}

void main() {
  testWidgets(
    'Inicio abre Perfil y vuelve conservando la navegación existente',
    (tester) async {
      await withLocalNetworkImages(() async {
        // main's Home already overflows on phones; isolate module navigation.
        // The new module has separate phone and landscape layout tests below.
        await tester.binding.setSurfaceSize(const Size(1000, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await pumpScreen(tester, const HomeScreen());
        for (final label in ['Inicio', 'Menú', 'Cupones', 'Coronas']) {
          expect(find.text(label), findsWidgets);
        }
        await tapVisible(tester, find.byIcon(Icons.add).first);
        expect(find.text('S/ 0.00'), findsNothing);
        await tapVisible(tester, find.byTooltip('Mi perfil'));
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.text('450 coronas · Demo'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byTooltip('Mi perfil'), findsOneWidget);
        expect(find.text('S/ 0.00'), findsNothing);
        expect(find.text('S/ 49.90'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    },
  );

  testWidgets('Login abre Registro y volver conserva Login', (tester) async {
    await pumpScreen(tester, const LoginScreen());
    await tapVisible(tester, find.text('Regístrate aquí'));
    expect(find.byType(RegisterScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Cada pantalla de Perfil permite regresar', (tester) async {
    await pumpScreen(tester, const ProfileScreen());
    final destinations = <String, Type>{
      'Registro': RegisterScreen,
      'Guía rápida': QuickGuideScreen,
      'Contacto': ContactScreen,
      'Newsletter': NewsletterScreen,
      'Notificaciones': NotificationSettingsScreen,
    };
    for (final entry in destinations.entries) {
      await tapVisible(tester, find.text(entry.key));
      expect(find.byType(entry.value), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Mi perfil'), findsOneWidget);
    }
  });

  testWidgets('Registro valida campos obligatorios y términos', (tester) async {
    await pumpScreen(tester, const RegisterScreen());
    await tapVisible(tester, find.text('Registrarme'));
    for (final error in [
      'Este campo es obligatorio.',
      'Ingresa tu correo electrónico.',
      'Ingresa 9 dígitos de un celular peruano que empiece con 9.',
      'Ingresa una contraseña.',
      'Confirma tu contraseña.',
      'Debes aceptar los términos para continuar.',
    ]) {
      expect(find.text(error), findsOneWidget);
    }
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'Registro permite validar en pantalla pequeña con teclado abierto',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetViewInsets);
      await pumpScreen(tester, const RegisterScreen(), scale: 1.5);
      await fill(tester, 4, 'otra clave');
      await tapVisible(tester, find.text('Registrarme'));
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      expect(
        find.text('Debes aceptar los términos para continuar.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Registro rechaza correo, celular, clave corta y confirmación distinta',
    (tester) async {
      await pumpScreen(tester, const RegisterScreen());
      await fill(tester, 0, 'Alex');
      await fill(tester, 1, 'correo@invalido');
      await fill(tester, 2, '812345678');
      await fill(tester, 3, 'corta');
      await fill(tester, 4, 'otra');
      await tapVisible(tester, find.text('Registrarme'));
      expect(find.textContaining('Ingresa un correo válido'), findsOneWidget);
      expect(
        find.textContaining('celular peruano que empiece con 9'),
        findsOneWidget,
      );
      expect(find.text('Usa al menos 8 caracteres.'), findsOneWidget);
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      for (final invalidPhone in ['98765432', '9876543210']) {
        await fill(tester, 2, invalidPhone);
        await tapVisible(tester, find.text('Registrarme'));
        expect(
          find.textContaining('celular peruano que empiece con 9'),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets(
    'Registro exige consentimiento y confirma sin retener contraseñas',
    (tester) async {
      final accountService = FakeAccountService();
      await pumpScreen(tester, ProfileScreen(accountService: accountService));
      await tapVisible(tester, find.text('Registro'));
      await fillRegistration(tester);
      await tapVisible(tester, find.text('Registrarme'));
      expect(
        find.text('Debes aceptar los términos para continuar.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      await tapVisible(tester, find.byType(CheckboxListTile));
      await tapVisible(tester, find.text('Registrarme'));
      expect(find.text('¡Cuenta creada!'), findsOneWidget);
      expect(accountService.events, ['account_created']);
      final fields = tester.widgetList<EditableText>(find.byType(EditableText));
      expect(fields.every((field) => field.controller.text.isEmpty), isTrue);
      await tapVisible(tester, find.text('Entendido'));
      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    },
  );

  testWidgets('Registro permite leer términos y mostrar ambas contraseñas', (
    tester,
  ) async {
    await pumpScreen(tester, const RegisterScreen());
    await tapVisible(tester, find.text('Leer términos de la aplicación'));
    expect(find.text('Términos de la aplicación'), findsOneWidget);
    await tapVisible(tester, find.text('Cerrar'));
    await tapVisible(tester, find.byTooltip('Mostrar contraseña'));
    await tapVisible(tester, find.byTooltip('Mostrar confirmación'));
    expect(
      tester
          .widgetList<EditableText>(find.byType(EditableText))
          .every((field) => !field.obscureText),
      isTrue,
    );
  });

  testWidgets(
    'Guía recorre cuatro pasos, permite retroceder, deslizar y finalizar',
    (tester) async {
      await pumpScreen(tester, const ProfileScreen());
      await tapVisible(tester, find.text('Guía rápida'));
      expect(find.text('Paso 1 de 4'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Anterior'),
            )
            .onPressed,
        isNull,
      );
      await tapVisible(tester, find.text('Siguiente'));
      expect(find.text('Paso 2 de 4'), findsOneWidget);
      await tapVisible(tester, find.text('Anterior'));
      expect(find.text('Paso 1 de 4'), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(-700, 0));
      await tester.pumpAndSettle();
      expect(find.text('Paso 2 de 4'), findsOneWidget);
      await tapVisible(tester, find.text('Siguiente'));
      expect(find.text('Paso 3 de 4'), findsOneWidget);
      await tapVisible(tester, find.text('Siguiente'));
      expect(find.text('Paso 4 de 4'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        1,
      );
      await tapVisible(tester, find.text('Finalizar'));
      expect(find.byType(ProfileScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Contacto valida, permite elegir motivo y confirma el envío simulado',
    (tester) async {
      await pumpScreen(tester, const ContactScreen());
      await tapVisible(tester, find.text('Enviar mensaje'));
      expect(find.text('Este campo es obligatorio.'), findsNWidgets(2));
      expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
      expect(find.text('Selecciona un motivo de consulta.'), findsOneWidget);
      await fill(tester, 0, 'Alex');
      await fill(tester, 1, 'correo inválido');
      await tapVisible(tester, find.text('Enviar mensaje'));
      expect(find.textContaining('Ingresa un correo válido'), findsOneWidget);
      await fill(tester, 1, 'alex@ejemplo.com');
      await tapVisible(tester, find.byType(DropdownButtonFormField<String>));
      await tapVisible(tester, find.text('Sugerencia').last);
      await fill(tester, 2, 'Consulta de ejemplo para probar el prototipo.');
      await tapVisible(tester, find.text('Enviar mensaje'));
      expect(find.text('¡Mensaje simulado enviado!'), findsOneWidget);
      await tapVisible(tester, find.text('Entendido'));
      expect(
        tester
            .widgetList<EditableText>(find.byType(EditableText))
            .every((field) => field.controller.text.isEmpty),
        isTrue,
      );
      await tapVisible(tester, find.text('Enviar mensaje'));
      expect(find.text('Selecciona un motivo de consulta.'), findsOneWidget);
    },
  );

  testWidgets('Newsletter valida correo y consentimiento antes de confirmar', (
    tester,
  ) async {
    await pumpScreen(tester, const NewsletterScreen());
    await tapVisible(tester, find.text('Suscribirme'));
    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(
      find.textContaining('Necesitamos tu consentimiento'),
      findsOneWidget,
    );
    await fill(tester, 0, 'correo inválido');
    await tapVisible(tester, find.text('Suscribirme'));
    expect(find.textContaining('Ingresa un correo válido'), findsOneWidget);
    await fill(tester, 0, 'alex@ejemplo.com');
    await tapVisible(tester, find.text('Suscribirme'));
    expect(find.byType(AlertDialog), findsNothing);
    await tapVisible(tester, find.byType(CheckboxListTile));
    await tapVisible(tester, find.text('Suscribirme'));
    expect(find.text('¡Suscripción simulada completada!'), findsOneWidget);
    await tapVisible(tester, find.text('Entendido'));
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      isEmpty,
    );
  });

  testWidgets(
    'Notificaciones alterna cada preferencia y las conserva al reabrir',
    (tester) async {
      await pumpScreen(tester, const ProfileScreen());
      await tapVisible(tester, find.text('Notificaciones'));
      for (final label in [
        'Promociones y descuentos',
        'Estado de pedidos',
        'Nuevos beneficios y coronas',
      ]) {
        await tapVisible(tester, find.text(label));
      }
      expect(
        tester
            .widgetList<SwitchListTile>(find.byType(SwitchListTile))
            .every((tile) => tile.value),
        isTrue,
      );
      await tapVisible(tester, find.text('Estado de pedidos'));
      await tapVisible(tester, find.text('Ver notificación de ejemplo'));
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Notificación de ejemplo'), findsOneWidget);
      await tapVisible(tester, find.text('Cerrar'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Notificaciones'));
      final values = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .map((tile) => tile.value);
      expect(values, [true, false, true]);
    },
  );

  testWidgets('Compartir permite cancelar y confirmar la simulación', (
    tester,
  ) async {
    await pumpScreen(tester, const ProfileScreen());
    await tapVisible(tester, find.text('Compartir aplicación'));
    expect(find.byType(AlertDialog), findsOneWidget);
    await tapVisible(tester, find.text('Cancelar'));
    expect(find.byType(AlertDialog), findsNothing);
    await tapVisible(tester, find.text('Compartir aplicación'));
    await tapVisible(tester, find.text('Simular compartir'));
    expect(
      find.text('¡Aplicación compartida de forma simulada!'),
      findsOneWidget,
    );
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(640, 360),
    const Size(768, 1024),
  ]) {
    testWidgets('Pantallas del módulo sin overflow a $size y texto ampliado', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final preferences = ValueNotifier(const NotificationPreferences());
      addTearDown(preferences.dispose);
      for (final screen in [
        const ProfileScreen(),
        const RegisterScreen(),
        const ContactScreen(),
        const NewsletterScreen(),
        const QuickGuideScreen(),
        NotificationSettingsScreen(preferences: preferences),
      ]) {
        await pumpScreen(tester, screen, scale: 1.5);
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.runtimeType} at $size',
        );
      }
    });
  }
}
