import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  static const _promotions = [
    _Promotion(
      id: 'whopper',
      badge: 'AHORRAS 30%',
      title: '2 Whopper® Jr. + 2 Papas Regulares',
      description: 'Carne 100% vacuna a la parrilla, pepinillos crujientes y papas doradas en corte regular.',
      image: 'assets/promotions/whopper.jpg',
      regularPrice: 'S/ 37.00',
      price: 'S/ 25.90',
      crowns: 40,
    ),
    _Promotion(
      id: 'stacker',
      badge: 'BACON LOVER',
      title: 'Duo Stacker Doble + 2 Bebidas',
      description: '2 Hamburguesas Stacker Doble con tocino crocante, queso fundido y 2 vasos de 16 oz.',
      image: 'assets/promotions/stacker.jpg',
      regularPrice: 'S/ 52.00',
      price: 'S/ 38.00',
      crowns: 55,
      badgeColor: Color(0xFF986500),
    ),
    _Promotion(
      id: 'crispy-chicken',
      badge: 'POLLO CRUJIENTE',
      title: 'Pollo Crispy + Papas',
      description: 'Pollo dorado y crujiente por fuera, jugoso por dentro, con papas regulares.',
      image: 'assets/promotions/chicken.jpg',
      regularPrice: 'S/ 41.00',
      price: 'S/ 29.90',
      crowns: 50,
    ),
    _Promotion(
      id: 'sundae',
      badge: 'DÚO DULCE',
      title: '2 Sundaes Chocolate o Caramelo',
      description: 'Helado suave y cremoso de vainilla bañado en abundante salsa caliente a tu gusto.',
      image: 'assets/promotions/sundae.jpg',
      regularPrice: 'S/ 13.80',
      price: 'S/ 8.90',
      crowns: 15,
      badgeColor: Color(0xFFB9745D),
    ),
    _Promotion(
      id: 'family',
      badge: 'AHORRO FAMILIAR 35%',
      title: 'King Box Familiar (4 Personas)',
      description: '2 Whopper® + 2 Cheeseburgers + 4 Papas medianas + 10 King Nuggets + 4 Bebidas.',
      image: 'assets/promotions/family.jpg',
      regularPrice: 'S/ 108.90',
      price: 'S/ 69.90',
      crowns: 90,
    ),
  ];

  final _codeController = TextEditingController();
  final Set<String> _favorites = {};
  final Set<String> _redeemed = {};
  bool _showFavorites = false;
  int _selectedNavigation = 2;

  static const _invitationText =
      '¡Prueba Bod Burguer! Usa mi invitación y disfruta 20% OFF.';

  List<_Promotion> get _visiblePromotions => _showFavorites
      ? _promotions
            .where((promotion) => _favorites.contains(promotion.id))
            .toList()
      : _promotions;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyText(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _message(message);
  }

  void _applyWelcomeCoupon() {
    _copyText('BKBIENVENIDO20', 'Cupón BKBIENVENIDO20 copiado.');
  }

  Future<void> _shareInvitation() async {
    final shareUrl = Uri.https('wa.me', '/', {'text': _invitationText});
    final opened = await launchUrl(
      shareUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted) return;
    if (!opened) _message('No se pudo abrir WhatsApp en este dispositivo.');
  }

  void _validateCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _message('Escribe el código impreso en tu cupón.');
    } else if (code.toUpperCase() == 'PERU-BK-7749') {
      _message('¡Código validado! Cupón de demostración agregado.');
    } else {
      _message('No reconocemos ese código. Revisa e inténtalo otra vez.');
    }
  }

  Future<void> _redeem(_Promotion promotion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canjear cupón'),
        content: Text(
          '¿Quieres canjear "${promotion.title}" por ${promotion.price}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Canjear'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _redeemed.add(promotion.id));
      _message('Cupón canjeado. Muéstralo en caja para usarlo.');
    }
  }

  void _selectNavigation(int index) {
    if (index == 2) {
      setState(() => _selectedNavigation = index);
      return;
    }
    const sections = ['Menú', 'Coronas', '', 'Pedidos', 'Yo'];
    _message('${sections[index]} estará disponible próximamente.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _welcomeCoupon(),
                      const SizedBox(height: 14),
                      _rewardsCard(),
                      const SizedBox(height: 14),
                      _couponFilters(),
                      const SizedBox(height: 10),
                      if (_visiblePromotions.isEmpty)
                        _emptyFavorites()
                      else
                        for (final promotion in _visiblePromotions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _promotionCard(promotion),
                          ),
                      const SizedBox(height: 4),
                      _codeValidation(),
                    ],
                  ),
                ),
                _bottomNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 9),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERÚ',
              style: TextStyle(color: AppColors.muted, fontSize: 10),
            ),
            Text(
              'Cupones',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.monetization_on, color: Color(0xFFF3B41B), size: 16),
              SizedBox(width: 3),
              Text(
                '420',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.red,
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: 'Mi cuenta',
            onPressed: () => _selectNavigation(4),
            icon: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ),
      ],
    ),
  );

  Widget _welcomeCoupon() => Container(
    padding: const EdgeInsets.fromLTRB(18, 15, 18, 14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFD91E00), Color(0xFFA65332)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(23),
      boxShadow: [
        BoxShadow(
          color: AppColors.red.withValues(alpha: 0.18),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'EXCLUSIVO PRIMERA COMPRA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          '¡20% de descuento en tu primera compra móvil!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Pide desde la app, ahorra tiempo y disfruta el sabor a la parrilla recién hecho.',
          style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(7),
          color: Colors.white.withValues(alpha: 0.13),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '♧ BKBIENVENIDO20',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: FilledButton.tonalIcon(
                  onPressed: _applyWelcomeCoupon,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE6B8),
                    foregroundColor: AppColors.brown,
                  ),
                  icon: const Icon(Icons.local_offer_outlined, size: 15),
                  label: const Text('Aplicar Cupón'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _rewardsCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF2DF),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFFFD8CB),
              child: Icon(
                Icons.campaign_outlined,
                color: AppColors.brown,
                size: 18,
              ),
            ),
            const SizedBox(width: 7),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 12, color: AppColors.ink),
                  children: [
                    TextSpan(
                      text: 'VIRAL REWARDS ',
                      style: TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '+150 Coronas\nRegala sabor a la parrilla',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text.rich(
          TextSpan(
            style: TextStyle(color: AppColors.brown, fontSize: 11, height: 1.4),
            children: [
              TextSpan(text: 'Comparte un link por WhatsApp: tu amigo recibe '),
              TextSpan(
                text: '20% OFF',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: ' en su debut y tú ganas '),
              TextSpan(
                text: '150 Coronas',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' automáticamente tras su primer bocado.'),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareInvitation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brown,
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.share_outlined, size: 15),
                label: const Text('Compartir en WhatsApp', maxLines: 1),
              ),
            ),
            const SizedBox(width: 7),
            IconButton.filledTonal(
              tooltip: 'Copiar enlace de invitación',
              onPressed: () => _copyText(
                Uri.https('wa.me', '/', {'text': _invitationText}).toString(),
                'Enlace de invitación copiado.',
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.brown,
              ),
              icon: const Icon(Icons.content_copy, size: 16),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _couponFilters() => Column(
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Cuponeras Activas',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(Icons.circle, color: Color(0xFFE6AA29), size: 7),
          const SizedBox(width: 4),
          const Text(
            'Renuevan en 3d',
            style: TextStyle(color: AppColors.brown, fontSize: 11),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _filterButton(
              label: 'Para Ti (Personalizados)',
              icon: Icons.local_offer_outlined,
              selected: !_showFavorites,
              onPressed: () => setState(() => _showFavorites = false),
            ),
          ),
          const SizedBox(width: 7),
          _filterButton(
            label: '${_favorites.length} Favoritos',
            icon: Icons.bookmark_border,
            selected: _showFavorites,
            onPressed: () => setState(() => _showFavorites = true),
          ),
        ],
      ),
    ],
  );

  Widget _filterButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onPressed,
  }) => SizedBox(
    height: 31,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? Colors.white : AppColors.brown,
        backgroundColor: selected ? AppColors.red : Colors.transparent,
        side: BorderSide(
          color: selected ? AppColors.red : const Color(0xFFE9DED3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 13),
      label: Text(label, style: const TextStyle(fontSize: 10)),
    ),
  );

  Widget _promotionCard(_Promotion promotion) {
    final isFavorite = _favorites.contains(promotion.id);
    final isRedeemed = _redeemed.contains(promotion.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.12),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2.08,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  promotion.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(
                        color: AppColors.beige,
                        child: Icon(
                          Icons.fastfood,
                          size: 48,
                          color: AppColors.red,
                        ),
                      ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: promotion.badgeColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      promotion.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 7,
                  bottom: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '◉ Ganas ${promotion.crowns} Coronas',
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    tooltip: isFavorite
                        ? 'Quitar de favoritos'
                        : 'Agregar a favoritos',
                    onPressed: () => setState(() {
                      if (isFavorite) {
                        _favorites.remove(promotion.id);
                      } else {
                        _favorites.add(promotion.id);
                      }
                    }),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  promotion.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Regular ${promotion.regularPrice}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            promotion.price,
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 31,
                      child: FilledButton.icon(
                        onPressed: isRedeemed ? null : () => _redeem(promotion),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.red,
                          disabledBackgroundColor: const Color(0xFFB5A8A0),
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                        ),
                        icon: Icon(
                          isRedeemed
                              ? Icons.check
                              : Icons.shopping_bag_outlined,
                          size: 14,
                        ),
                        label: Text(
                          isRedeemed ? 'Canjeado' : 'Canjear',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyFavorites() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Column(
      children: [
        Icon(Icons.bookmark_border, color: AppColors.muted, size: 32),
        SizedBox(height: 8),
        Text(
          'Aún no tienes favoritos',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4),
        Text(
          'Guarda una promo tocando el corazón.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _codeValidation() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF4E8D6),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '♧ ¿Tienes un cupón impreso o volante?',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ingresa el código alfanumérico que aparece al reverso de tu ticket físico para transferirlo a tu bolsa digital.',
          style: TextStyle(color: AppColors.brown, fontSize: 11, height: 1.4),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'EJ. PERU-BK-7749',
              hintStyle: const TextStyle(fontSize: 11, color: AppColors.muted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 38,
          child: FilledButton.icon(
            onPressed: _validateCode,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8A503E),
              shape: const RoundedRectangleBorder(),
            ),
            icon: const Text('Validar Código'),
            label: const Icon(Icons.arrow_forward, size: 15),
          ),
        ),
      ],
    ),
  );

  Widget _bottomNavigation() => Container(
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
        height: 52,
        child: Row(
          children: [
            _navItem(0, 'Menú', Icons.storefront_outlined),
            _navItem(1, 'Coronas', Icons.workspace_premium_outlined),
            _navItem(2, 'Cupones', Icons.local_offer_outlined),
            _navItem(3, 'Pedidos', Icons.receipt_long_outlined),
            _navItem(4, 'Yo', Icons.person_outline),
          ],
        ),
      ),
    ),
  );

  Widget _navItem(int index, String label, IconData icon) {
    final selected = _selectedNavigation == index;
    return Expanded(
      child: InkWell(
        onTap: () => _selectNavigation(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? AppColors.red : AppColors.brown,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.red : AppColors.brown,
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Promotion {
  const _Promotion({
    required this.id,
    required this.badge,
    required this.title,
    required this.description,
    required this.image,
    required this.regularPrice,
    required this.price,
    required this.crowns,
    this.badgeColor = AppColors.red,
  });

  final String id;
  final String badge;
  final String title;
  final String description;
  final String image;
  final String regularPrice;
  final String price;
  final int crowns;
  final Color badgeColor;
}
