import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

enum LoginMethod { phone, email }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  LoginMethod _method = LoginMethod.phone;
  bool _hidePassword = true;
  bool _rememberDevice = false;

  TextEditingController get _identifier =>
      _method == LoginMethod.phone ? _phone : _email;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _login() {
    if (_identifier.text.trim().isEmpty || _password.text.isEmpty) {
      _message('Ingresa tus datos para iniciar sesión.');
      return;
    }
    _message('El inicio de sesión estará disponible próximamente.');
  }

  void _sendCode() {
    if (_phone.text.trim().length < 7) {
      _message('Ingresa un número de celular válido.');
      return;
    }
    _message('Te enviaremos un código por WhatsApp.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _hero(),
                        const SizedBox(height: 24),
                        _offer(),
                        const SizedBox(height: 28),
                        _methodSelector(),
                        const SizedBox(height: 22),
                        _identifierField(),
                        const SizedBox(height: 20),
                        _passwordField(),
                        const SizedBox(height: 20),
                        _whatsAppPrompt(),
                        _rememberOption(),
                        const SizedBox(height: 16),
                        _loginButton(),
                        const SizedBox(height: 28),
                        _socialLogin(),
                        const SizedBox(height: 22),
                        _guestButton(),
                        const SizedBox(height: 22),
                        _registerText(),
                        const SizedBox(height: 12),
                        _termsText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => SizedBox(
    height: 72,
    child: Row(
      children: [
        IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        const Spacer(),
        const Icon(Icons.local_fire_department, color: AppColors.red),
        const SizedBox(width: 8),
        const Text('LOGIN PHONE', style: LoginStyles.header),
        const Spacer(),
        IconButton(
          tooltip: 'Limpiar campos',
          onPressed: () {
            _phone.clear();
            _email.clear();
            _password.clear();
          },
          icon: const Icon(Icons.close),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 20),
          child: CircleAvatar(
            backgroundColor: AppColors.red,
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ),
      ],
    ),
  );

  Widget _hero() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.hero,
      borderRadius: BorderRadius.circular(42),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🔥  PERÚ A LA PARRILLA', style: LoginStyles.kicker),
              const SizedBox(height: 14),
              const Text.rich(
                TextSpan(
                  style: LoginStyles.heroTitle,
                  children: [
                    TextSpan(text: '¡A tu manera,\n'),
                    TextSpan(text: 'siempre!', style: LoginStyles.highlight),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tus cupones, coronas y pedidos express en un solo lugar.',
                style: LoginStyles.heroDescription,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          flex: 4,
          child: CircleAvatar(
            radius: 64,
            backgroundColor: AppColors.burger,
            child: Text('🍔', style: LoginStyles.burger),
          ),
        ),
      ],
    ),
  );

  Widget _offer() => Container(
    padding: const EdgeInsets.all(18),
    color: AppColors.offer,
    child: const Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.background,
          child: Icon(Icons.workspace_premium_outlined, color: AppColors.brown),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: LoginStyles.offerText,
              children: [
                TextSpan(
                  text: 'REGALO DE BIENVENIDA • Nuevo Usuario\n',
                  style: LoginStyles.offerHeading,
                ),
                TextSpan(text: 'Recibe '),
                TextSpan(text: '20% OFF', style: LoginStyles.offerEmphasis),
                TextSpan(text: ' en tu primer pedido + '),
                TextSpan(text: '100 Coronas', style: LoginStyles.offerEmphasis),
                TextSpan(text: ' gratis.'),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _methodSelector() => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: AppColors.beige,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Row(
      children: [
        _methodOption(LoginMethod.phone, Icons.phone_iphone, 'Celular'),
        _methodOption(LoginMethod.email, Icons.mail_outline, 'Correo'),
      ],
    ),
  );

  Widget _methodOption(LoginMethod method, IconData icon, String label) {
    final selected = _method == method;
    return Expanded(
      child: TextButton.icon(
        onPressed: () => setState(() => _method = method),
        icon: Icon(icon),
        label: Text(label),
        style: LoginStyles.methodButton(selected),
      ),
    );
  }

  Widget _identifierField() {
    final isPhone = _method == LoginMethod.phone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isPhone ? 'Número de celular' : 'Correo electrónico',
              style: LoginStyles.sectionTitle,
            ),
            const Spacer(),
            if (isPhone) const Text('Vía SMS / WhatsApp'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (isPhone) ...[
              const Text('🇵🇪  +51'),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: TextField(
                controller: _identifier,
                keyboardType: isPhone
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                inputFormatters: isPhone
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                decoration: LoginStyles.input(
                  hint: isPhone ? '987 654 321' : 'tucorreo@ejemplo.com',
                  prefix: isPhone ? null : const Icon(Icons.mail_outline),
                  suffix: IconButton(
                    tooltip: 'Borrar',
                    onPressed: _identifier.clear,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _passwordField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text('Contraseña o clave', style: LoginStyles.sectionTitle),
          const Spacer(),
          TextButton(
            onPressed: () => _message('Te ayudaremos a recuperar tu clave.'),
            child: const Text('¿Olvidaste tu clave?'),
          ),
        ],
      ),
      TextField(
        controller: _password,
        obscureText: _hidePassword,
        decoration: LoginStyles.input(
          hint: 'Ingresa tus dígitos o clave',
          prefix: const Icon(Icons.lock_outline),
          suffix: IconButton(
            tooltip: _hidePassword ? 'Mostrar clave' : 'Ocultar clave',
            onPressed: () => setState(() => _hidePassword = !_hidePassword),
            icon: Icon(
              _hidePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _whatsAppPrompt() => Card(
    color: AppColors.quickLogin,
    elevation: 0,
    child: ListTile(
      leading: const Icon(Icons.bolt, color: AppColors.red, size: 30),
      title: const Text('Ingreso rápido por WhatsApp'),
      subtitle: const Text('Sin recordar contraseñas'),
      trailing: TextButton(
        onPressed: _sendCode,
        child: const Text('Enviar código'),
      ),
    ),
  );

  Widget _rememberOption() => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    value: _rememberDevice,
    onChanged: (value) => setState(() => _rememberDevice = value ?? false),
    title: const Text('Recordarme en este dispositivo'),
    controlAffinity: ListTileControlAffinity.leading,
    secondary: const Icon(Icons.verified_user_outlined),
  );

  Widget _loginButton() => SizedBox(
    height: 68,
    child: ElevatedButton(
      onPressed: _login,
      style: LoginStyles.redButton,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('INICIAR SESIÓN', style: LoginStyles.primaryButton),
          SizedBox(width: 12),
          Icon(Icons.arrow_forward),
        ],
      ),
    ),
  );

  Widget _socialLogin() => Column(
    children: [
      const Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('O CONTINÚA CON'),
          ),
          Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          Expanded(
            child: _socialButton('Google', 'G', () {
              _message('Inicio de sesión con Google próximamente.');
            }),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _socialButton('Apple', '', () {
              _message('Inicio de sesión con Apple próximamente.');
            }),
          ),
        ],
      ),
    ],
  );

  Widget _socialButton(String name, String mark, VoidCallback onPressed) =>
      ElevatedButton(
        onPressed: onPressed,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mark, style: LoginStyles.socialMark),
              const SizedBox(width: 10),
              Text(name),
            ],
          ),
        ),
      );

  Widget _guestButton() => ElevatedButton.icon(
    onPressed: () => _message('Puedes explorar el menú como invitado.'),
    icon: const Icon(Icons.storefront_outlined),
    label: const Text('Pedir rápido como invitado'),
    style: LoginStyles.guestButton,
  );

  Widget _registerText() => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      const Text('¿Aún no tienes cuenta? '),
      TextButton(
        onPressed: () => _message('El registro estará disponible pronto.'),
        child: const Text('Regístrate aquí'),
      ),
    ],
  );

  Widget _termsText() => Text.rich(
    TextSpan(
      style: LoginStyles.terms,
      children: [
        const TextSpan(text: 'Al ingresar confirmas que aceptas nuestros '),
        const TextSpan(
          text: 'Términos y Condiciones',
          style: LoginStyles.legalLink,
        ),
        const TextSpan(text: ' y la '),
        const TextSpan(
          text: 'Política de Privacidad',
          style: LoginStyles.legalLink,
        ),
        const TextSpan(text: ' de Burger King Perú.'),
      ],
    ),
    textAlign: TextAlign.center,
  );
}
