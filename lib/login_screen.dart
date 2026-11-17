import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'services/account_service.dart';
import 'services/order_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.accountService = const FirebaseAccountService(),
    this.orderService = const FirebaseOrderService(),
  });

  final AccountService accountService;
  final OrderService orderService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _rememberDevice = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
  }

  Future<void> _restoreRememberedEmail() async {
    try {
      final email = await widget.accountService.loadRememberedEmail();
      if (mounted && email != null) {
        _phone.text = email;
        setState(() => _rememberDevice = true);
      }
    } on Exception catch (error) {
      if (mounted) _message('No se pudo recuperar el correo guardado: $error');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _navigateToHome({AccountSession? session}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          accountService: widget.accountService,
          orderService: widget.orderService,
          session: session,
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _phone.text.trim();
    if (email.isEmpty || _password.text.isEmpty) {
      _message('Ingresa tu correo electrónico y contraseña.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final session = await widget.accountService.signIn(
        email: email,
        password: _password.text,
      );
      await widget.accountService.rememberEmail(_rememberDevice ? email : null);
      if (mounted) _navigateToHome(session: session);
    } on AccountServiceException catch (error) {
      if (mounted) _message(error.message);
    } on Exception catch (error) {
      if (mounted) _message('No se pudo iniciar sesión: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sendCode() {
    _message('El ingreso por WhatsApp estará disponible próximamente.');
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
                        _phoneField(),
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
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: const [
          Icon(Icons.local_fire_department, color: AppColors.red, size: 28),
          SizedBox(width: 8),
          Text('LOGIN PHONE', style: LoginStyles.header),
          Spacer(),
          CircleAvatar(
            backgroundColor: AppColors.red,
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
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
            children: const [
              Text('🔥  PERÚ A LA PARRILLA', style: LoginStyles.kicker),
              SizedBox(height: 14),
              Text.rich(
                TextSpan(
                  style: LoginStyles.heroTitle,
                  children: [
                    TextSpan(text: '¡A tu manera,\n'),
                    TextSpan(text: 'siempre!', style: LoginStyles.highlight),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
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

  Widget _phoneField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const [
          Text('Correo electrónico', style: LoginStyles.sectionTitle),
          Text('Acceso seguro'),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _phone,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: LoginStyles.input(
                hint: 'correo@ejemplo.com',
                prefix: const Icon(Icons.email_outlined),
                suffix: IconButton(
                  tooltip: 'Borrar',
                  onPressed: _phone.clear,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _passwordField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Contraseña', style: LoginStyles.sectionTitle),
          TextButton(
            onPressed: _resetPassword,
            child: const Text('¿Olvidaste tu clave?'),
          ),
        ],
      ),
      TextField(
        controller: _password,
        obscureText: _hidePassword,
        decoration: LoginStyles.input(
          hint: 'Ingresa tu contraseña',
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
      onPressed: _isLoading ? null : _login,
      style: LoginStyles.redButton,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isLoading ? 'INGRESANDO...' : 'INICIAR SESIÓN',
            style: LoginStyles.primaryButton.copyWith(fontSize: 18),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward),
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
            child: _socialButton('Google', 'G', _unsupportedSocialLogin),
          ),
          const SizedBox(width: 14),
          Expanded(child: _socialButton('Apple', '', _unsupportedSocialLogin)),
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
    onPressed: _navigateToHome,
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
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                RegisterScreen(accountService: widget.accountService),
          ),
        ),
        child: const Text('Regístrate aquí'),
      ),
    ],
  );

  Widget _termsText() => Text.rich(
    TextSpan(
      style: LoginStyles.terms,
      children: const [
        TextSpan(text: 'Al ingresar confirmas que aceptas nuestros '),
        TextSpan(text: 'Términos y Condiciones', style: LoginStyles.legalLink),
        TextSpan(text: ' y la '),
        TextSpan(text: 'Política de Privacidad', style: LoginStyles.legalLink),
        TextSpan(text: ' de Burger King Perú.'),
      ],
    ),
    textAlign: TextAlign.center,
  );

  Future<void> _resetPassword() async {
    final email = _phone.text.trim();
    if (email.isEmpty) {
      _message('Escribe tu correo para enviarte el enlace de recuperación.');
      return;
    }
    try {
      await widget.accountService.sendPasswordReset(email);
      if (mounted) _message('Revisa tu correo para restablecer la contraseña.');
    } on AccountServiceException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  void _unsupportedSocialLogin() {
    _message('El ingreso con Google o Apple no está configurado todavía.');
  }
}
