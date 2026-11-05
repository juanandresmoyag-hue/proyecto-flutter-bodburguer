import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'restaurant_map_view.dart';

enum OrderMode { delivery, restaurant }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OrderMode _orderMode = OrderMode.delivery;
  int _selectedCategoryIndex = 0;
  int _navBarIndex = 0;
  double _cartTotal = 0.00;
  int _cartItemCount = 0;
  String _selectedStoreName = 'BK Benavides Miraflores';
  String _selectedStoreHours = 'Abierto hoy hasta las 11:30 PM';

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Lo + Pedido', 'icon': Icons.local_fire_department, 'active': true},
    {'name': 'Whopper®', 'icon': Icons.lunch_dining, 'active': false},
    {'name': 'Pollo Crispy', 'icon': Icons.kebab_dining, 'active': false},
    {'name': 'Snacks', 'icon': Icons.fastfood, 'active': false},
    {'name': 'Postres', 'icon': Icons.icecream, 'active': false},
    {'name': 'Bebidas', 'icon': Icons.local_drink, 'active': false},
  ];

  void _addToCart(String itemName, double price) {
    setState(() {
      _cartTotal += price;
      _cartItemCount += 1;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        duration: const Duration(milliseconds: 1800),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Agregado: $itemName (S/ ${price.toStringAsFixed(2)})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Order Mode Switcher (Delivery / Restaurante / Auto-King)
            _buildOrderModeSwitcher(),

            // Content: Either Restaurant Map View OR Home Menu Content
            Expanded(
              child: _orderMode == OrderMode.restaurant
                  ? RestaurantMapView(
                      onSelectRestaurant: (restaurant) {
                        setState(() {
                          _selectedStoreName = restaurant.name;
                          _selectedStoreHours = 'Abierto hoy: ${restaurant.openHours}';
                          _orderMode = OrderMode.delivery; // Return to menu with selected store
                        });
                      },
                    )
                  : _buildHomeDeliveryFeed(),
            ),

            // Bottom Navigation Bar
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // 1. Top App Bar (Miraflores, Coronas badge, BK logo, profile avatar)
  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Burger King Logo badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF4E8),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.red, width: 2),
            ),
            child: const Center(
              child: Text(
                'BK',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Location Selector
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _orderMode = OrderMode.restaurant);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.red),
                        const SizedBox(width: 4),
                        const Text(
                          'Miraflores, Lima',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.ink),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: AppColors.muted),
                          SizedBox(width: 4),
                          Text(
                            '25–35 min',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
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

          // Coronas Points Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD580)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, color: Color(0xFFE08700), size: 18),
                SizedBox(width: 4),
                Text(
                  '450',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF8A5100),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // User Profile Avatar
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.beige,
            child: const Icon(Icons.person, color: AppColors.brown),
          ),
        ],
      ),
    );
  }

  // 2. Order Mode Selector: Delivery | Restaurante | Auto-King
  Widget _buildOrderModeSwitcher() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1E9DE),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            // Delivery Tab
            Expanded(
              child: _buildModeTabButton(
                title: 'Delivery',
                icon: Icons.delivery_dining,
                mode: OrderMode.delivery,
              ),
            ),

            // Restaurante Tab (replaced "Para Llevar")
            Expanded(
              child: _buildModeTabButton(
                title: 'Restaurante',
                icon: Icons.storefront,
                mode: OrderMode.restaurant,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildModeTabButton({
    required String title,
    required IconData icon,
    required OrderMode mode,
  }) {
    final isSelected = _orderMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() => _orderMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? AppColors.red : AppColors.brown,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.red : AppColors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Main Delivery Feed (Reproducing screen.png completely)
  Widget _buildHomeDeliveryFeed() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 4.1 Hero Promo Card: "MEGA PROMO DEL MES"
          _buildHeroPromoCard(),

          const SizedBox(height: 18),

          // 4.2 Mis Coronas Loyalty Card
          _buildMisCoronasCard(),

          const SizedBox(height: 24),

          // 4.3 Explora el Menú (Categories Horizontal Scroll)
          _buildCategoryMenuSection(),

          const SizedBox(height: 24),

          // 4.4 Ofertas de la App (Cards Horizontal Scroll)
          _buildAppOffersSection(),

          const SizedBox(height: 24),

          // 4.5 Tus Favoritos Recientes
          _buildRecentFavoritesSection(),

          const SizedBox(height: 20),

          // 4.6 Brand Seal: 100% Carne de Res a la Parrilla
          _buildBrandSealBanner(),

          const SizedBox(height: 16),

          // 4.7 Store Location Bar (BK Benavides Miraflores)
          _buildStoreLocationBar(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 4.1 MEGA PROMO DEL MES Card
  Widget _buildHeroPromoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD92300), Color(0xFF9E1500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD92300).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Flame watermark backdrop
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.local_fire_department,
              size: 150,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDE59),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: AppColors.ink),
                        SizedBox(width: 4),
                        Text(
                          'EXCLUSIVO APP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department, size: 13, color: Colors.orangeAccent),
                        SizedBox(width: 2),
                        Text(
                          '-31% DCTO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              const Text(
                'MEGA PROMO\nDEL MES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: const Text(
                  'Whopper Doble con Queso + Papas Medianas + Free Refill',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Price & Button Row with Burger graphic
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            'S/ 19.90',
                            style: TextStyle(
                              color: Color(0xFFFFDE59),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'S/ 28.90',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _addToCart('Mega Promo Whopper Doble', 19.90),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.red,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pedir Ahora',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Burger Combo Graphic
                  Container(
                    width: 95,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🍔', style: TextStyle(fontSize: 38)),
                        SizedBox(height: 2),
                        Text(
                          '🍟 + 🥤',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4.2 Mis Coronas Loyalty Card
  Widget _buildMisCoronasCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE6B5)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crown avatar
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8A3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.workspace_premium, color: Color(0xFFB06F00), size: 28),
                ),
              ),
              const SizedBox(width: 14),

              // Points info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Mis Coronas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD580),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Nivel Oro',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B4300),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 12, color: AppColors.brown),
                        children: [
                          TextSpan(text: 'Te faltan '),
                          TextSpan(
                            text: '50 coronas',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.red),
                          ),
                          TextSpan(text: ' para un Whopper Jr. gratis'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Points Counter
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '450',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6B4300),
                    ),
                  ),
                  Text(
                    'PTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Progreso: 450 / 500',
                style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600),
              ),
              Text(
                '90% completado',
                style: TextStyle(fontSize: 11, color: Color(0xFFB06F00), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.90,
              minHeight: 8,
              backgroundColor: const Color(0xFFEADBCE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC78B0E)),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFFFE6B5)),
          const SizedBox(height: 10),

          // Footer link
          Row(
            children: [
              const Icon(Icons.redeem, size: 16, color: AppColors.brown),
              const SizedBox(width: 6),
              const Text(
                'Canjea cupones desde 200 pts',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brown),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catálogo de premios con Coronas disponible pronto.')),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Ver premios',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.red,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.red),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4.3 Explora el Menú (Categories)
  Widget _buildCategoryMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Explora el Menú',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            Text(
              'Todo a la parrilla',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategoryIndex == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.red : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.red.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected ? Colors.white : AppColors.brown,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat['name'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.red : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4.4 Ofertas de la App
  Widget _buildAppOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Ofertas de la App',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Fuego BK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Ver todas (6)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildOfferProductCard(
                discountBadge: '-35% OFF',
                title: 'Combo Familiar 4x...',
                description: '4 Whoppers + 2 Papas Medianas + 10 Nuggets crocantes + Bebidas',
                price: 49.90,
                originalPrice: 76.90,
                emojiIcon: '🍔👨‍👩‍👧‍👦',
              ),
              const SizedBox(width: 14),
              _buildOfferProductCard(
                discountBadge: '2x1 DUO',
                title: '2x1 en King Pollo',
                description: 'Dos crujientes sándwiches de pechuga empanizada con lechuga y mayonesa',
                price: 18.50,
                originalPrice: 29.00,
                emojiIcon: '🍗🍔',
              ),
              const SizedBox(width: 14),
              _buildOfferProductCard(
                discountBadge: '-25% OFF',
                title: 'Mega Stacker XL',
                description: 'Carne a la parrilla con abundante tocino y salsa stacker especial',
                price: 24.90,
                originalPrice: 33.50,
                emojiIcon: '🥓🍔',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferProductCard({
    required String discountBadge,
    required String title,
    required String description,
    required double price,
    required double originalPrice,
    required String emojiIcon,
  }) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / graphic header with badge
          Stack(
            children: [
              Container(
                height: 115,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE6),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Center(
                  child: Text(
                    emojiIcon,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    discountBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'S/ ${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.red,
                          ),
                        ),
                        Text(
                          'S/ ${originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _addToCart(title, price),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 22),
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

  // 4.5 Tus Favoritos Recientes
  Widget _buildRecentFavoritesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Tus Favoritos Recientes',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            Text(
              'Reordena en 1-tap',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              // Burger icon/preview
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🍔', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDE6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Último pedido',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Hace 3 días',
                          style: TextStyle(fontSize: 10, color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Whopper Clásico',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const Text(
                      'Sin cebolla • Extra queso',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'S/ 21.50',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Reorder Button
              ElevatedButton.icon(
                onPressed: () => _addToCart('Whopper Clásico', 21.50),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'Reordenar',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDE8A),
                  foregroundColor: const Color(0xFF5A3900),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4.6 Brand Guarantee Banner
  Widget _buildBrandSealBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9EFE4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF593A31),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.outdoor_grill, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Carne de Res a la Parrilla',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sin conservantes, colorantes ni aromas artificiales. El sabor a fuego auténtico que nos hace únicos desde 1954.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.brown,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4.7 Store Location Bar (Change store / Sede)
  Widget _buildStoreLocationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: AppColors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedStoreName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  _selectedStoreHours,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _orderMode = OrderMode.restaurant);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.red,
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  // 5. Bottom Navigation Bar (Matching screen.png with Floating Cart pill)
  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Icons.home, 'Inicio'),
          _buildNavItem(1, Icons.lunch_dining, 'Menú'),
          _buildNavItem(2, Icons.local_offer, 'Cupones', badge: '6'),
          _buildNavItem(3, Icons.workspace_premium, 'Coronas'),

          // Floating Cart pill button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.red,
                  content: Text(
                    _cartItemCount == 0
                        ? 'Tu carrito está vacío. Agrega una deliciosa Whopper.'
                        : 'Tienes $_cartItemCount productos por S/ ${_cartTotal.toStringAsFixed(2)}',
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF8A1700),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'S/ ${_cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {String? badge}) {
    final isSelected = _navBarIndex == index;
    return InkWell(
      onTap: () => setState(() => _navBarIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.red : AppColors.muted,
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.red : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
