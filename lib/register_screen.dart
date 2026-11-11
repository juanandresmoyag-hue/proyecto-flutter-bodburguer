import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'profile_validators.dart';
import 'profile_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _formKey.currentState!.reset();
    _password.clear();
    _confirmation.clear();
    await showDemoConfirmation(
      context,
      title: '¡Registro simulado completado!',
      message:
          'Has completado el formulario de demostración. '
          'No se creó una cuenta real ni se enviaron o guardaron tus datos '
          'o contraseñas.',
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => ProfileScaffold(
    title: 'Crear cuenta',
    children: [
      const ProfileIntro(
        icon: Icons.person_add_alt_1_outlined,
        title: '¡Tu próxima corona te espera!',
        description:
            'Prueba el registro con datos de ejemplo. '
            'Este formulario es una simulación académica.',
      ),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: ProfileStyles.input('Nombre completo'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: ProfileValidators.requiredText,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: ProfileStyles.input('Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              validator: ProfileValidators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: ProfileStyles.input('Celular peruano (9 dígitos)'),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: ProfileValidators.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              decoration: ProfileStyles.input(
                'Contraseña',
                suffix: IconButton(
                  tooltip: _hidePassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              obscureText: _hidePassword,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              validator: ProfileValidators.password,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmation,
              decoration: ProfileStyles.input(
                'Confirmar contraseña',
                suffix: IconButton(
                  tooltip: _hideConfirmation
                      ? 'Mostrar confirmación'
                      : 'Ocultar confirmación',
                  onPressed: () =>
                      setState(() => _hideConfirmation = !_hideConfirmation),
                  icon: Icon(
                    _hideConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              obscureText: _hideConfirmation,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (ProfileValidators.requiredText(value) != null) {
                  return 'Confirma tu contraseña.';
                }
                return value == _password.text
                    ? null
                    : 'Las contraseñas no coinciden.';
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  scrollable: true,
                  title: const Text('Términos de la demostración'),
                  content: const Text(
                    'Aplicación académica no oficial de SENATI. Usa datos ficticios. '
                    'No se crean cuentas, pedidos ni beneficios reales. '
                    'Los datos del formulario no se transmiten ni se almacenan '
                    'y se descartan al completar o cerrar esta pantalla.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
              child: const Text('Leer términos de la demostración'),
            ),
            const ConsentField(
              label: 'Acepto los términos de la demostración.',
              errorMessage: 'Debes aceptar los términos para continuar.',
            ),
            ProfileSubmitButton(label: 'Registrarme', onPressed: _register),
          ],
        ),
      ),
    ],
  );
}
