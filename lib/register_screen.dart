import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'profile_validators.dart';
import 'profile_widgets.dart';
import 'services/account_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.accountService = const FirebaseAccountService(),
  });

  final AccountService accountService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isRegistering) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isRegistering = true);
    try {
      await widget.accountService.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _name.clear();
      _email.clear();
      _phone.clear();
      _password.clear();
      _confirmation.clear();
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Cuenta creada!'),
          content: const Text(
            'Tu cuenta y perfil se guardaron. También se registró este acceso.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on AccountServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) => ProfileScaffold(
    title: 'Crear cuenta',
    children: [
      ProfileIntro(
        icon: Icons.person_add_alt_1_outlined,
        title: '¡Tu próxima corona te espera!',
        description: widget.accountService.isConfigured
            ? 'Crea tu cuenta con correo y contraseña. Tus pedidos quedarán '
                  'asociados a este perfil.'
            : 'Firebase aún no está configurado. No escribas datos reales '
                  'hasta conectar tu proyecto.',
      ),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              decoration: ProfileStyles.input('Nombre completo'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: ProfileValidators.requiredText,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              decoration: ProfileStyles.input('Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              validator: ProfileValidators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
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
                  title: const Text('Términos de la aplicación'),
                  content: const Text(
                    'La cuenta y los pedidos se guardan en Firebase cuando el '
                    'proyecto está configurado. La contraseña la administra '
                    'Firebase Authentication y no se guarda en el perfil. '
                    'Los pedidos son demostrativos: no se cobra ni se coordina '
                    'un envío real.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
              child: const Text('Leer términos de la aplicación'),
            ),
            const ConsentField(
              label: 'Acepto los términos de la demostración.',
              errorMessage: 'Debes aceptar los términos para continuar.',
            ),
            ProfileSubmitButton(
              label: _isRegistering ? 'Creando cuenta...' : 'Registrarme',
              onPressed: _register,
            ),
          ],
        ),
      ),
    ],
  );
}
