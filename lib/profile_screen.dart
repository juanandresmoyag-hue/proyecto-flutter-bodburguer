import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'contact_screen.dart';
import 'newsletter_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_widgets.dart';
import 'quick_guide_screen.dart';
import 'register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _preferences = ValueNotifier(const NotificationPreferences());

  @override
  void dispose() {
    _preferences.dispose();
    super.dispose();
  }

  void _open(Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _share() async {
    final shared = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        icon: const Icon(Icons.share_outlined, color: AppColors.red),
        title: const Text('Compartir aplicación'),
        content: const Text(
          '¡Conoce Bod Burguer! Un prototipo académico para explorar '
          'pedidos y beneficios.\n\n'
          'Esta demostración no abre otras aplicaciones ni envía mensajes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Simular compartir'),
          ),
        ],
      ),
    );
    if (shared == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('¡Aplicación compartida de forma simulada!'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => ProfileScaffold(
    title: 'Mi perfil',
    children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.hero,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.red,
              child: Icon(Icons.person_outline, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Alex Parrilla',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text('alex@ejemplo.com', textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Text('Cuenta de demostración', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Chip(
              avatar: Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.red,
              ),
              label: Text('450 coronas · Demo'),
              backgroundColor: AppColors.beige,
              side: BorderSide.none,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text('Tu cuenta y más', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      _option(
        Icons.person_add_alt_1_outlined,
        'Registro',
        'Prueba crear una cuenta',
        () => _open(const RegisterScreen()),
      ),
      _option(
        Icons.explore_outlined,
        'Guía rápida',
        'Conoce la app en cuatro pasos',
        () => _open(const QuickGuideScreen()),
      ),
      _option(
        Icons.chat_bubble_outline,
        'Contacto',
        'Simula una consulta',
        () => _open(const ContactScreen()),
      ),
      _option(
        Icons.mail_outline,
        'Newsletter',
        'Novedades y promociones',
        () => _open(const NewsletterScreen()),
      ),
      _option(
        Icons.notifications_none_outlined,
        'Notificaciones',
        'Configura tus preferencias',
        () => _open(NotificationSettingsScreen(preferences: _preferences)),
      ),
      _option(
        Icons.share_outlined,
        'Compartir aplicación',
        'Invita con una interacción simulada',
        _share,
      ),
    ],
  );

  Widget _option(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: AppColors.red),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.brown),
        onTap: onTap,
      ),
    ),
  );
}
