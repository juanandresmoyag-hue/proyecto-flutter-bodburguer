import 'package:flutter/material.dart';

import 'app_theme.dart';

class SectionNavigationBar extends StatelessWidget {
  const SectionNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _items = [
    (label: 'Menú', icon: Icons.storefront_outlined),
    (label: 'Coronas', icon: Icons.workspace_premium_outlined),
    (label: 'Cupones', icon: Icons.local_offer_outlined),
    (label: 'Pedidos', icon: Icons.shopping_bag_outlined),
    (label: 'Yo', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBF7),
      boxShadow: [
        BoxShadow(
          color: Colors.brown.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _NavigationItem(
                  key: ValueKey('section-navigation-$index'),
                  label: _items[index].label,
                  icon: _items[index].icon,
                  selected: selectedIndex == index,
                  onTap: () => onSelect(index),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 19,
            color: selected ? AppColors.red : AppColors.brown,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.red : AppColors.brown,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}
