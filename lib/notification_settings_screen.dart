import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'profile_widgets.dart';

@immutable
class NotificationPreferences {
  const NotificationPreferences({
    this.promotions = false,
    this.orders = false,
    this.rewards = false,
  });

  final bool promotions;
  final bool orders;
  final bool rewards;

  NotificationPreferences copyWith({
    bool? promotions,
    bool? orders,
    bool? rewards,
  }) => NotificationPreferences(
    promotions: promotions ?? this.promotions,
    orders: orders ?? this.orders,
    rewards: rewards ?? this.rewards,
  );
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key, required this.preferences});

  /// Owned by Profile so choices survive reopening settings during that visit.
  final ValueNotifier<NotificationPreferences> preferences;

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<NotificationPreferences>(
    valueListenable: preferences,
    builder: (context, settings, _) => ProfileScaffold(
      title: 'Notificaciones',
      children: [
        const ProfileIntro(
          icon: Icons.notifications_none_outlined,
          title: 'Elige qué te interesa',
          description:
              'Preferencias simuladas durante tu visita a Perfil. '
              'No se solicitan permisos ni se envían notificaciones reales.',
        ),
        Card(
          color: Colors.white,
          elevation: 0,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Promociones y descuentos'),
                value: settings.promotions,
                onChanged: (value) =>
                    preferences.value = settings.copyWith(promotions: value),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Estado de pedidos'),
                value: settings.orders,
                onChanged: (value) =>
                    preferences.value = settings.copyWith(orders: value),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Nuevos beneficios y coronas'),
                value: settings.rewards,
                onChanged: (value) =>
                    preferences.value = settings.copyWith(rewards: value),
              ),
            ],
          ),
        ),
        ProfileSubmitButton(
          label: 'Ver notificación de ejemplo',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              scrollable: true,
              icon: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.red,
              ),
              title: const Text('Notificación de ejemplo'),
              content: const Text(
                'Bod Burguer · ¡Una corona más para ti!\n\n'
                'Vista previa manual, independiente de tus interruptores. '
                'Es una notificación simulada; no otorga beneficios reales.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
