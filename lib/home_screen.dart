import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'cart_screen.dart';
import 'crowns_screen.dart';
import 'promotions_screen.dart';
import 'profile_screen.dart';
import 'restaurant_map_view.dart';
import 'section_navigation_bar.dart';
import 'services/account_service.dart';
import 'services/order_service.dart';

enum OrderMode { delivery, restaurant }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.accountService = const FirebaseAccountService(),
    this.orderService = const FirebaseOrderService(),
    this.session,
    this.openMenuOnStart = false,
  });

  final AccountService accountService;
  final OrderService orderService;
  final AccountSession? session;
  final bool openMenuOnStart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OrderMode _orderMode = OrderMode.delivery;
  int _selectedCategoryIndex = 0;
  int _navBarIndex = 0;
  final _menuSectionKey = GlobalKey();
  late final Future<void> _cartRestore;
  final List<CartItem> _cartItems = [];
  String _selectedStoreName = 'BK Benavides Miraflores';
  String _selectedStoreHours = 'Abierto hoy hasta las 11:30 PM';

  @override
  void initState() {
    super.initState();
    _cartRestore = _restoreCart();
    if (widget.openMenuOnStart) {
      _navBarIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final menuContext = _menuSectionKey.currentContext;
        if (mounted && menuContext != null) {
          Scrollable.ensureVisible(
            menuContext,
            duration: const Duration(milliseconds: 350),
            alignment: 0.1,
          );
        }
      });
    }
  }

  final List<Map<String, dynamic>> _categories = const [
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

  static const _menuProducts = [
    {
      'category': 'Whopper®',
      'name': 'Whopper Clásico',
      'price': 21.50,
      'description': 'Carne a la parrilla, tomate, lechuga y mayonesa.',
      'emoji': '🍔',
      'ingredients': ['Lechuga', 'Tomate', 'Cebolla', 'Pepinillos', 'Mayonesa'],
      'extras': ['Queso extra', 'Tocino'],
    },
    {
      'category': 'Whopper®',
      'name': 'Whopper Doble con Queso',
      'price': 28.90,
      'description': 'Doble carne a la parrilla, queso y vegetales frescos.',
      'emoji': '🍔',
      'ingredients': ['Lechuga', 'Tomate', 'Cebolla', 'Pepinillos', 'Mayonesa'],
      'extras': ['Queso extra', 'Tocino'],
    },
    {
      'category': 'Pollo Crispy',
      'name': 'King de Pollo',
      'price': 18.50,
      'description': 'Pechuga crocante, lechuga fresca y mayonesa.',
      'emoji': '🍗',
      'ingredients': ['Lechuga', 'Tomate', 'Mayonesa'],
      'extras': ['Queso extra', 'Tocino'],
    },
    {
      'category': 'Snacks',
      'name': 'King Nuggets (6 unidades)',
      'price': 12.90,
      'description': 'Nuggets de pollo crocantes con salsa a elección.',
      'emoji': '🍗',
      'ingredients': ['Salsa BBQ'],
      'extras': ['Salsa adicional'],
    },
    {
      'category': 'Snacks',
      'name': 'Papas clásicas',
      'price': 8.90,
      'description': 'Papas doradas y crujientes.',
      'emoji': '🍟',
      'ingredients': ['Sal'],
      'extras': ['Salsa adicional'],
    },
    {
      'category': 'Postres',
      'name': 'Sundae de chocolate',
      'price': 6.90,
      'description': 'Helado suave de vainilla con salsa de chocolate.',
      'emoji': '🍨',
      'ingredients': ['Salsa de chocolate'],
      'extras': ['Salsa de caramelo'],
    },
    {
      'category': 'Bebidas',
      'name': 'Gaseosa mediana',
      'price': 6.50,
      'description': 'Elige tu bebida fría favorita.',
      'emoji': '🥤',
      'ingredients': ['Hielo'],
      'extras': ['Sin hielo'],
    },
  ];

  Future<void> _restoreCart() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString('bod_burguer_cart');
      if (encoded == null) return;
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        throw const FormatException('El carrito guardado no es una lista.');
      }
      if (decoded.any((item) => item is! Map<String, dynamic>)) {
        throw const FormatException(
          'El carrito guardado contiene productos inválidos.',
        );
      }
      final items = decoded
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(
          () => _cartItems
            ..clear()
            ..addAll(items),
        );
      }
    } on FormatException catch (error) {
      if (mounted) _showMessage('No se pudo recuperar el carrito: $error');
    } on Exception catch (error) {
      if (mounted) _showMessage('Error al recuperar el carrito: $error');
    }
  }

  Future<void> _persistCart() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        'bod_burguer_cart',
        jsonEncode(_cartItems.map((item) => item.toJson()).toList()),
      );
      if (!saved) throw StateError('El dispositivo no guardó los cambios.');
    } on Exception catch (error) {
      if (mounted) _showMessage('No se pudo guardar el carrito: $error');
    }
  }

  void _onCartItemsChanged(List<CartItem> items) {
    setState(() {
      _cartItems
        ..clear()
        ..addAll(items);
    });
    unawaited(_persistCart());
  }

  Future<void> _openCart() async {
    await _cartRestore;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(
          items: List<CartItem>.unmodifiable(_cartItems),
          onItemsChanged: _onCartItemsChanged,
          accountService: widget.accountService,
          orderService: widget.orderService,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addToCart(
    String itemName,
    double price, {
    String description = 'Personaliza tu pedido antes de agregarlo al carrito.',
    String emoji = '🍔',
    List<String> ingredients = const [
      'Lechuga',
      'Tomate',
      'Cebolla',
      'Pepinillos',
      'Mayonesa',
    ],
    List<String> extras = const ['Queso extra', 'Tocino'],
  }) async {
    await _cartRestore;
    if (!mounted) return;
    final chosenItem = await showModalBottomSheet<CartItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailsSheet(
        name: itemName,
        description: description,
        emoji: emoji,
        price: price,
        ingredients: ingredients,
        extras: extras,
      ),
    );
    if (chosenItem == null || !mounted) return;

    final existingIndex = _cartItems.indexWhere(
      (item) => item.id == chosenItem.id,
    );
    if (existingIndex >= 0 && _cartItems[existingIndex].quantity >= 20) {
      _showMessage('No puedes agregar más de 20 unidades del mismo producto.');
      return;
    }

    setState(() {
      if (existingIndex == -1) {
        _cartItems.add(chosenItem);
      } else {
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + 1,
        );
      }
    });
    unawaited(_persistCart());

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          duration: const Duration(milliseconds: 1800),
          content: Text(
            'Agregado: ${chosenItem.name} (S/ ${chosenItem.unitPrice.toStringAsFixed(2)})',
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
                          _selectedStoreHours =
                              'Abierto hoy: ${restaurant.openHours}';
                          _orderMode = OrderMode
                              .delivery; // Return to menu with selected store
                        });
                      },
                    )
                  : _buildHomeDeliveryFeed(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SectionNavigationBar(
        selectedIndex: _navBarIndex,
        onSelect: _selectNavigation,
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
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.red,
                        ),
                        const SizedBox(width: 4),
                        const Flexible(
                          child: Text(
                            'Miraflores, Lima',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.ink,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: AppColors.muted,
                          ),
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
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CrownsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD580)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFE08700),
                    size: 18,
                  ),
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
          ),
          const SizedBox(width: 10),

          // User Profile Avatar
          IconButton(
            tooltip: 'Mi perfil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ProfileScreen(accountService: widget.accountService),
              ),
            ),
            icon: const CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.beige,
              child: Icon(Icons.person, color: AppColors.brown),
            ),
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
                  ),
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

          const SizedBox(height: 16),

          _buildMenuProducts(),

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 13,
                          color: Colors.orangeAccent,
                        ),
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
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
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
                          const SizedBox(width: 4),
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
                        onPressed: () =>
                            _addToCart('Mega Promo Whopper Doble', 19.90),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.red,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
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
                  // Burger Combo Graphic
                  Container(
                    width: 95,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🍔', style: TextStyle(fontSize: 38)),
                        SizedBox(height: 2),
                        Text('🍟 + 🥤', style: TextStyle(fontSize: 16)),
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
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
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
                  child: Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFB06F00),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Points info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Mis Coronas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.red,
                            ),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            children: const [
              Text(
                'Progreso: 450 / 500',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '90% completado',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB06F00),
                  fontWeight: FontWeight.bold,
                ),
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFC78B0E),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFFFE6B5)),
          const SizedBox(height: 10),

          // Footer link
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              const Icon(Icons.redeem, size: 16, color: AppColors.brown),
              const Text(
                'Canjea cupones desde 200 pts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brown,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CrownsScreen()),
                ),
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
    return KeyedSubtree(
      key: _menuSectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE6B8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.red,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explora el menú',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Todo a la parrilla, hecho a tu manera',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategoryIndex == index;
                return ChoiceChip(
                  selected: isSelected,
                  showCheckmark: false,
                  avatar: Icon(
                    category['icon'] as IconData,
                    size: 17,
                    color: isSelected ? Colors.white : AppColors.brown,
                  ),
                  label: Text(category['name'] as String),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.brown,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.red,
                  side: BorderSide(
                    color: isSelected ? AppColors.red : const Color(0xFFEADFD4),
                  ),
                  shape: const StadiumBorder(),
                  onSelected: (_) =>
                      setState(() => _selectedCategoryIndex = index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuProducts() {
    final selectedCategory = _categories[_selectedCategoryIndex]['name'];
    final products = _selectedCategoryIndex == 0
        ? _menuProducts
        : _menuProducts
              .where((product) => product['category'] == selectedCategory)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2DF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.red,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _selectedCategoryIndex == 0
                      ? 'Lo más pedido'
                      : '$selectedCategory',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                '${products.length} opciones',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        for (final product in products)
          Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 11),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFF0E6DC)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _addToCart(
                product['name']! as String,
                product['price']! as double,
                description: product['description']! as String,
                emoji: product['emoji']! as String,
                ingredients: product['ingredients']! as List<String>,
                extras: product['extras']! as List<String>,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: AppColors.beige,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            product['emoji']! as String,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name']! as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                product['description']! as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.25,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFF0E6DC)),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.tune,
                          size: 15,
                          color: AppColors.brown,
                        ),
                        const SizedBox(width: 5),
                        const Expanded(
                          child: Text(
                            'Personaliza tu pedido',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.brown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'S/ ${(product['price']! as double).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.red,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Ofertas de la App',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
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
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: Center(
                  child: Text(emojiIcon, style: const TextStyle(fontSize: 48)),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
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

  // 4.5 Tus Favoritos Recientes
  Widget _buildRecentFavoritesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 4,
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
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
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
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.muted,
                              ),
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
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
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
                ],
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
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
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _selectNavigation(int index) {
    setState(() => _navBarIndex = index);
    switch (index) {
      case 0:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final menuContext = _menuSectionKey.currentContext;
          if (menuContext != null) {
            Scrollable.ensureVisible(
              menuContext,
              duration: const Duration(milliseconds: 350),
              alignment: 0.1,
            );
          }
        });
        break;
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CrownsScreen()));
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PromotionsScreen()),
        );
        break;
      case 3:
        _openCart();
        break;
      case 4:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ProfileScreen(accountService: widget.accountService),
          ),
        );
        break;
    }
  }
}

class _ProductDetailsSheet extends StatefulWidget {
  const _ProductDetailsSheet({
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    required this.ingredients,
    required this.extras,
  });

  final String name;
  final String description;
  final String emoji;
  final double price;
  final List<String> ingredients;
  final List<String> extras;

  @override
  State<_ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<_ProductDetailsSheet> {
  final Set<String> _removedIngredients = {};
  final Set<String> _selectedExtras = {};

  double get _totalPrice =>
      widget.price +
      _selectedExtras.fold<double>(
        0,
        (total, extra) => total + _extraPrice(extra),
      );

  double _extraPrice(String extra) {
    if (extra.toLowerCase().contains('queso')) return 3;
    if (extra.toLowerCase().contains('tocino')) return 4;
    if (extra.toLowerCase().contains('salsa')) return 1;
    return 0;
  }

  CartItem _buildCartItem() {
    final removed = _removedIngredients.toList()..sort();
    final extras = _selectedExtras.toList()..sort();
    final configuration = [...removed.map((item) => 'sin-$item'), ...extras];
    final baseId = widget.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final id = [baseId, ...configuration].join('-');
    return CartItem(
      id: id,
      name: widget.name,
      unitPrice: _totalPrice,
      quantity: 1,
      removedIngredients: removed,
      extras: extras,
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                children: [
                  Row(
                    children: [
                      Text(widget.emoji, style: const TextStyle(fontSize: 46)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.description),
                  const SizedBox(height: 20),
                  const Text(
                    'Quita lo que no te gusta',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  for (final ingredient in widget.ingredients)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: !_removedIngredients.contains(ingredient),
                      title: Text(ingredient),
                      subtitle: const Text('Incluido'),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (included) => setState(() {
                        if (included == true) {
                          _removedIngredients.remove(ingredient);
                        } else {
                          _removedIngredients.add(ingredient);
                        }
                      }),
                    ),
                  if (widget.extras.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Personaliza con extras',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    for (final extra in widget.extras)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _selectedExtras.contains(extra),
                        title: Text(extra),
                        subtitle: Text(
                          _extraPrice(extra) == 0
                              ? 'Sin costo adicional'
                              : '+ S/ ${_extraPrice(extra).toStringAsFixed(2)}',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (selected) => setState(() {
                          if (selected == true) {
                            _selectedExtras.add(extra);
                          } else {
                            _selectedExtras.remove(extra);
                          }
                        }),
                      ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).pop(_buildCartItem()),
                child: Text('Agregar · S/ ${_totalPrice.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
