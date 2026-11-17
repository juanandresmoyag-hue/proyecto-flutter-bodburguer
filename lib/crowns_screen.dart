import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'promotions_screen.dart';
import 'section_navigation_bar.dart';

class CrownsScreen extends StatelessWidget {
  const CrownsScreen({super.key});

  static const _rewards = [
    (
      cost: 200,
      name: 'Papas regulares',
      description: 'Un acompañamiento clásico',
      emoji: '🍟',
    ),
    (
      cost: 350,
      name: 'Whopper Jr.',
      description: 'Carne a la parrilla, a tu manera',
      emoji: '🍔',
    ),
    (
      cost: 500,
      name: 'Combo Whopper',
      description: 'Hamburguesa, papas y bebida',
      emoji: '👑',
    ),
  ];

  static const _balance = 450;

  void _redeem(BuildContext context, String reward) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'El canje de $reward estará disponible al conectar tu cuenta.',
          ),
        ),
      );
  }

  void _selectNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const HomeScreen(openMenuOnStart: true),
          ),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PromotionsScreen()),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Consulta los pedidos desde el carrito.'),
            ),
          );
        break;
      case 4:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Mis Coronas'),
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _balanceCard(),
              const SizedBox(height: 14),
              _progressCard(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE6B8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.redeem,
                      color: AppColors.red,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premios para ti',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const Text(
                          'Canjea tus coronas por algo delicioso',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final reward in _rewards)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _rewardCard(context, reward),
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2DF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.brown, size: 18),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Las coronas y los canjes son de demostración. '
                        'Conecta tu cuenta para habilitar recompensas reales.',
                        style: TextStyle(
                          color: AppColors.brown,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: SectionNavigationBar(
      selectedIndex: 1,
      onSelect: (index) => _selectNavigation(context, index),
    ),
  );

  Widget _balanceCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFD92300), Color(0xFFA65332)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.red.withValues(alpha: 0.18),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: -14,
          top: -18,
          child: Icon(
            Icons.workspace_premium,
            size: 120,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'TU SALDO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFFFDEA7),
                  size: 32,
                ),
                SizedBox(width: 9),
                Text(
                  '450',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'CORONAS',
                  style: TextStyle(
                    color: Color(0xFFFFDEA7),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Disfruta tus favoritos y sigue sumando en cada pedido.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _progressCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF2DF),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFFE6B5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Tu próximo premio',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDEA7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Whopper Combo',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            value: _balance / 500,
            minHeight: 9,
            color: Color(0xFFC78B0E),
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 3,
          children: [
            Text(
              '450 de 500 coronas',
              style: TextStyle(
                color: AppColors.brown,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Te faltan 50',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _rewardCard(
    BuildContext context,
    ({int cost, String name, String description, String emoji}) reward,
  ) {
    final canRedeem = _balance >= reward.cost;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E6DC)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2DF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(reward.emoji, style: const TextStyle(fontSize: 29)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFC78B0E),
                    size: 19,
                  ),
                  Text(
                    '${reward.cost}',
                    style: const TextStyle(
                      color: AppColors.brown,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF0E6DC)),
          ),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: FilledButton(
              onPressed: canRedeem ? () => _redeem(context, reward.name) : null,
              style: FilledButton.styleFrom(
                backgroundColor: canRedeem
                    ? AppColors.red
                    : const Color(0xFFF1E9DE),
                foregroundColor: canRedeem ? Colors.white : AppColors.muted,
                disabledBackgroundColor: const Color(0xFFF1E9DE),
                disabledForegroundColor: AppColors.muted,
                shape: const StadiumBorder(),
              ),
              child: Text(
                canRedeem
                    ? 'Canjear premio'
                    : 'Te faltan ${reward.cost - _balance} coronas',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
