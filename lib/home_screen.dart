import 'package:flutter/material.dart';

import 'promotions_screen.dart';
import 'profile_screen.dart';
import 'restaurant_map_view.dart';
import 'cart_screen.dart';
import 'services/account_service.dart';
import 'services/order_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.accountService = const FirebaseAccountService(),
    this.orderService = const FirebaseOrderService(),
    this.session,
  });

  final AccountService accountService;
  final OrderService orderService;
  final AccountSession? session;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedOrderMode = 0; // 0: Delivery, 1: Para Llevar, 2: Auto-King
  int _selectedCategory = 0;
  int _currentNavIndex = 0;
  final List<CartItem> _cartItems = [];

  double get _cartTotal =>
      _cartItems.fold<double>(0, (total, item) => total + item.subtotal);

  int get _cartQuantity =>
      _cartItems.fold<int>(0, (total, item) => total + item.quantity);

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Lo + Pedido',
      'icon': Icons.local_fire_department,
      'active': true,
    },
    {'name': 'Whopper®', 'icon': Icons.lunch_dining, 'active': false},
    {'name': 'Pollo Crispy', 'icon': Icons.kebab_dining, 'active': false},
    {'name': 'Snacks', 'icon': Icons.fastfood, 'active': false},
    {'name': 'Postres', 'icon': Icons.icecream, 'active': false},
    {'name': 'Bebidas', 'icon': Icons.local_drink, 'active': false},
  ];

  final List<Map<String, dynamic>> _offers = [
    {
      'badge': '-35% OFF',
      'badgeColor': const Color(0xFFD62300),
      'title': 'Combo Familiar 4x Whopper',
      'desc': '4 Whoppers + 2 Papas Medianas + 10 Nuggets crocantes + Bebidas',
      'price': 49.90,
      'oldPrice': 76.90,
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCnkZbKscc3NJrN4HaFX9X5bfce7lTP1uuRTywEJobuMW43IPNiEBlo_mdgouM8dpksmVr8fRADR2c25tQpWMK-vVE21y8UX8ULr5Ny46XXEH_m5dB5hy6GTMW0A1jURgj0FneAKD-vBQ81qn3P_woEBaBfaQIEMuCy51Uyyg8RBKFW8V-bC_aIMWn-wd7dJqK2KdapLSKI0Uraml-7kw5UvII6KIDIRl-fQfTR4bRs',
    },
    {
      'badge': '2x1 DUO',
      'badgeColor': const Color(0xFF704F00),
      'title': '2x1 en King de Pollo',
      'desc': 'Dos crujientes sándwiches King de pechuga empanizada y mayonesa',
      'price': 18.50,
      'oldPrice': 29.00,
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_gqUlwfs34i3U8jFnvRgfu7gDUgZPWb3vCZ3H039KzmdcBuBc1Htr6QwYgEgN0Jwgxz2Pxbxr8_fPBZ04Gm7pIt27Eh5H30VuXQjbEr2BUGwrBN818fTAdTIKfns2CAKaZxGezuBzVAb52eqT15kGHAZ181-2syoS5W7ITavBsOYGtDe4p5wZs7LLTa-VpNkQlKhzUJR_1zW3AfgnMV1NYgt-LmEinW0RFViVRDbD',
    },
    {
      'badge': '-25% OFF',
      'badgeColor': const Color(0xFFD62300),
      'title': 'Stacker Doble Bacon Combo',
      'desc': 'Doble carne a la parrilla, salsa Stacker secreta y mucho tocino',
      'price': 23.90,
      'oldPrice': 31.90,
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA3kM3Xzz89C_pxhScBmHMt75W77wFErzhJJE1yjHYOg7OX0LWYFIfP4KEsuXV9OOAf2jAgsy2hkCSq0fVz8Ut0tHrJHgFKq-6ryx85Hj3dlHujY9tppBaLygiK2UQNBq_eprcKbFyK-wEdW-1RuaIqgSD-1KZvW30pYmVtkdzzN97DK-Dky0bQEtP1dDK9p3KxkregxBQXevLJP7g128_5e05HS2aGMJR5cd9Sf1f5',
    },
  ];

  void _addToCart(String product, double price) {
    setState(() {
      final id = product
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index < 0) {
        _cartItems.add(
          CartItem(id: id, name: product, unitPrice: price, quantity: 1),
        );
      } else {
        _cartItems[index] = _cartItems[index].copyWith(
          quantity: _cartItems[index].quantity + 1,
        );
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: const Color(0xFF353026),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFFFDEA7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡$product agregado!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD62300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'S/ ${_cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: _buildAppBar(isDesktop),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOrderModeSelector(),
                const SizedBox(height: 18),
                _buildMegaPromo(),
                const SizedBox(height: 20),
                _buildCrownsWidget(),
                const SizedBox(height: 24),
                _buildCategories(),
                const SizedBox(height: 24),
                _buildAppOffers(isDesktop),
                const SizedBox(height: 24),
                _buildRecentFavorites(),
                const SizedBox(height: 20),
                _buildQualityBanner(),
                const SizedBox(height: 16),
                _buildLocalStoreBanner(),
                const SizedBox(height: 80), // espacio extra para el bottom bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F1).withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF502314).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Logo Burger King
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD62300),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'BK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Selector de Ubicación
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.location_on,
                                color: Color(0xFFD62300),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Miraflores, Lima',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F1B12),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.expand_more,
                                size: 16,
                                color: Color(0xFF5D403A),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: Color(0xFF8F6600),
                              ),
                              SizedBox(width: 3),
                              Text(
                                '25-35 min',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF5D403A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Coronas Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF502314).withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.workspace_premium,
                        color: Color(0xFFFFBB1E),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '450',
                        style: TextStyle(
                          color: Color(0xFF704F00),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Avatar de perfil
                IconButton(
                  tooltip: 'Mi perfil',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ProfileScreen(accountService: widget.accountService),
                    ),
                  ),
                  icon: const CircleAvatar(
                    radius: 17,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCeC5OFF2oyxuGIzaBxy61vamTMVa20Lahm3ewg-YsQo6qCY2yo_4VpsTErcPpBIeO0CBdU7pjoqimrFJzBA-YMHAtN9CJrj3Z1047EBBliyk2yv5qJo0djv5gsdPKRwvBd-Aq1306V5VEHY1izfxkJxfQKwM4YOU8unoCMDcATB_9KGITi57axB7M7yrvo3GkpX48yn9sHvX19Grc-rI7a940_wTYe20PDFE2npVVm',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Segmented Switch: Delivery / Para Llevar / Auto-King
  Widget _buildOrderModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E7D8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildModeTab(0, '🛵', 'Delivery'),
          _buildModeTab(1, '🛍️', 'Para Llevar'),
          _buildModeTab(2, '🚗', 'Auto-King'),
        ],
      ),
    );
  }

  Widget _buildModeTab(int index, String emoji, String label) {
    final isSelected = _selectedOrderMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedOrderMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF502314).withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFFA91A00)
                      : const Color(0xFF5D403A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hero Promo: MEGA PROMO DEL MES
  Widget _buildMegaPromo() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFA91A00), Color(0xFFD62300), Color(0xFF88503E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA91A00).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Llamas decorativas de fondo
            Positioned(
              right: 10,
              top: 10,
              child: Opacity(
                opacity: 0.15,
                child: const Text('🔥', style: TextStyle(fontSize: 85)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDEA7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '⭐ EXCLUSIVO APP',
                          style: TextStyle(
                            color: Color(0xFF271900),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: const [
                          Icon(
                            Icons.local_fire_department,
                            color: Color(0xFFFFDEA7),
                            size: 14,
                          ),
                          SizedBox(width: 2),
                          Text(
                            '-31% DCTO',
                            style: TextStyle(
                              color: Color(0xFFFFDEA7),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MEGA PROMO DEL MES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Whopper Doble con Queso + Papas Medianas + Free Refill',
                    style: TextStyle(
                      color: Color(0xFFFFDAD3),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        'S/ 19.90',
                        style: TextStyle(
                          color: Color(0xFFFFBB1E),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'S/ 28.90',
                        style: TextStyle(
                          color: Color(0xFFFFDAD3),
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            _addToCart('Mega Promo Whopper Doble', 19.90),
                        icon: const SizedBox.shrink(),
                        label: Row(
                          children: const [
                            Text(
                              'Pedir Ahora',
                              style: TextStyle(
                                color: Color(0xFFA91A00),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Color(0xFFA91A00),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: const StadiumBorder(),
                          elevation: 3,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBXKrlPsVP_IZMYSk9cZHV0kOzLFm1eR-cANZE5RUlDDzcQ2qrXaP5mJ_zyaBOO8iBwLKlJmGcDYNHX7VFn_RB6zMmWEisvYx6Mf_RL-XjP24BnwHnu4muHBYSNwo4JtS0Wt8swothmUs2U5pB3ezcB5-g2ykggrm0ovVqHipO1kiFBW8aOHfZmVswcHgUyVtYhB-yXIbMoNAKinFgV6VuddMffdG5c-DWYp5zK_3W-',
                          width: 105,
                          height: 75,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.fastfood,
                            size: 60,
                            color: Colors.white70,
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
      ),
    );
  }

  // Mis Coronas BK
  Widget _buildCrownsWidget() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF2E3),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502314).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDEA7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFF704F00),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
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
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F1B12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDEA7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Nivel Oro',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF271900),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5D403A),
                        ),
                        children: [
                          TextSpan(text: 'Te faltan '),
                          TextSpan(
                            text: '50 coronas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA91A00),
                            ),
                          ),
                          TextSpan(text: ' para un Whopper Jr. gratis'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '450',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF704F00),
                    ),
                  ),
                  Text(
                    'PTS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D403A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Progreso: 450 / 500',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF5D403A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '90% completado',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF704F00),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.9,
              minHeight: 10,
              backgroundColor: const Color(0xFFEBE1D2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFBB1E),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.redeem, size: 15, color: Color(0xFF704F00)),
                  SizedBox(width: 4),
                  Text(
                    'Canjea cupones desde 200 pts',
                    style: TextStyle(fontSize: 11, color: Color(0xFF5D403A)),
                  ),
                ],
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  children: const [
                    Text(
                      'Ver premios',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA91A00),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFFA91A00),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Explora el Menú (Categorías)
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Explora el Menú',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F1B12),
              ),
            ),
            Text(
              'Todo a la parrilla',
              style: TextStyle(fontSize: 12, color: Color(0xFF5D403A)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_categories.length, (index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == index;
              return Padding(
                padding: EdgeInsets.only(
                  right: index == _categories.length - 1 ? 0 : 14,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFA91A00)
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? const Color(0xFFA91A00)
                                        .withValues(alpha: 0.3)
                                  : const Color(0xFF502314)
                                        .withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFFFFDAD3),
                                  width: 3,
                                )
                              : null,
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF88503E),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['name'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFA91A00)
                              : const Color(0xFF1F1B12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Ofertas de la App (Horizontales en móvil o Grid en PC)
  Widget _buildAppOffers(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Ofertas de la App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1B12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA91A00),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Fuego BK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Ver todas (6)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFA91A00),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isDesktop)
          // Grid para PC
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _offers
                .map(
                  (offer) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildOfferCard(offer),
                    ),
                  ),
                )
                .toList(),
          )
        else
          // Scroll horizontal para móvil
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _offers
                  .map(
                    (offer) => Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 14),
                      child: _buildOfferCard(offer),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502314).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  offer['image'] as String,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 120,
                    color: const Color(0xFFF1E7D8),
                    child: const Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 40,
                        color: Color(0xFF88503E),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: offer['badgeColor'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    offer['badge'] as String,
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
          const SizedBox(height: 10),
          Text(
            offer['title'] as String,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1B12),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            offer['desc'] as String,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF5D403A),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'S/ ${(offer['price'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFA91A00),
                    ),
                  ),
                  Text(
                    'S/ ${(offer['oldPrice'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF926F68),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _addToCart(
                  offer['title'] as String,
                  offer['price'] as double,
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA91A00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tus Favoritos Recientes (Reordena en 1-tap)
  Widget _buildRecentFavorites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tus Favoritos Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F1B12),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EDDE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Reordena en 1-tap',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF5D403A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF502314).withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCw10RfLKM1s0eRk1BG_qvMEevgE66j6Y1JJlhBzmkQ0hHeL7pKa-yICW3XBPoqCnuB4Kl3ex4IBxMPBwOOLSAefZKwwitKkbYDBYOJ2u-nqxBrUT1hm8x-ZzUcq3aGfpR18oiuYDkqFNp4q-0NvO48SlJXCzFnCx1lHs-DXEsHqlS67knxePmKOqzqDdZGmETuu9KkZMYvHvS0lLsAdo1bKA9yLU_KzvalzO0yxa86',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 70,
                    height: 70,
                    color: const Color(0xFFF1E7D8),
                    child: const Icon(Icons.fastfood, color: Color(0xFF88503E)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7EDDE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Último pedido',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF88503E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Hace 3 días',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF5D403A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Whopper Clásica',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F1B12),
                      ),
                    ),
                    const Text(
                      'Sin cebolla • Extra queso cheddar • Bebida Zero',
                      style: TextStyle(fontSize: 11, color: Color(0xFF5D403A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'S/ 21.50',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFA91A00),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _addToCart('Whopper Clásica Reordenada', 21.50),
                icon: const Icon(
                  Icons.replay,
                  size: 14,
                  color: Color(0xFF271900),
                ),
                label: const Text(
                  'Reordenar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF271900),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDEA7),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sello Calidad Parrilla
  Widget _buildQualityBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EDDE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF88503E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.outdoor_grill,
              color: Color(0xFFFFDEA7),
              size: 28,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1B12),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sin conservantes ni colorantes artificiales. Sabor a fuego auténtico desde 1954.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF5D403A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Micro-banner local cercano
  Widget _buildLocalStoreBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502314).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.store, color: Color(0xFFA91A00), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'BK Benavides Miraflores',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1B12),
                  ),
                ),
                Text(
                  'Abierto hoy hasta las 11:30 PM',
                  style: TextStyle(fontSize: 10, color: Color(0xFF5D403A)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Encuentra tu restaurante')),
                  body: const SafeArea(child: RestaurantMapView()),
                ),
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFDAD3),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Cambiar',
              style: TextStyle(
                color: Color(0xFFA91A00),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1).withValues(alpha: 0.98),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D160C).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Inicio'),
              _buildNavItem(1, Icons.lunch_dining, 'Menú'),
              _buildNavCouponItem(2, 'Cupones'),
              _buildNavItem(3, Icons.workspace_premium, 'Coronas'),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CartScreen(
                      items: List<CartItem>.unmodifiable(_cartItems),
                      accountService: widget.accountService,
                      orderService: widget.orderService,
                      onItemsChanged: (items) {
                        if (!mounted) return;
                        setState(() {
                          _cartItems
                            ..clear()
                            ..addAll(items);
                        });
                      },
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA91A00),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD62300).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_cartQuantity · S/ ${_cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected
                ? const Color(0xFFA91A00)
                : const Color(0xFF5D403A),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFFA91A00)
                  : const Color(0xFF5D403A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCouponItem(int index, String label) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const PromotionsScreen())),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.local_offer,
                size: 22,
                color: isSelected
                    ? const Color(0xFFA91A00)
                    : const Color(0xFF5D403A),
              ),
              Positioned(
                top: -3,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA91A00),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '🔥6',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFFA91A00)
                  : const Color(0xFF5D403A),
            ),
          ),
        ],
      ),
    );
  }
}
