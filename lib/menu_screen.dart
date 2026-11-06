import 'package:flutter/material.dart';

/// Paleta de colores oficial extraída del Tailwind Config original
class MenuColors {
  static const primary = Color(0xFFA91A00);
  static const primaryContainer = Color(0xFFD62300);
  static const primaryFixed = Color(0xFFFFDAD3);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF88503E);
  static const secondaryContainer = Color(0xFFFEB59E);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF7A4433);
  static const surface = Color(0xFFFFF8F1);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFFCF2E3);
  static const surfaceContainer = Color(0xFFF7EDDE);
  static const surfaceContainerHigh = Color(0xFFF1E7D8);
  static const surfaceContainerHighest = Color(0xFFEBE1D2);
  static const onSurface = Color(0xFF1F1B12);
  static const onSurfaceVariant = Color(0xFF5D403A);
  static const tertiary = Color(0xFF704F00);
  static const tertiaryContainer = Color(0xFF8F6600);
  static const onTertiaryContainer = Color(0xFFFFEFD9);
  static const tertiaryFixedDim = Color(0xFFFFBB1E);
  static const tertiaryFixed = Color(0xFFFFDEA7);
  static const inverseSurface = Color(0xFF353026);
  static const inverseOnSurface = Color(0xFFFAEFE0);
}

/// Modelo de Producto del Menú
class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category; // 'whopper', 'chicken', 'combos', 'sides', 'desserts'
  final List<String> tags; // 'offers', 'plant', 'crispy', 'bestseller'
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextColor;
  final String image;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.tags,
    required this.badgeText,
    required this.badgeBg,
    this.badgeTextColor = Colors.white,
    required this.image,
  });
}

/// Elemento en el carrito
class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

class MenuScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHome;
  final VoidCallback? onNavigateToCoupons;
  final VoidCallback? onNavigateToRewards;

  const MenuScreen({
    super.key,
    this.onNavigateToHome,
    this.onNavigateToCoupons,
    this.onNavigateToRewards,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedDiet = 'all';
  int _navIndex = 1; // 1 = Menú activo por defecto

  // Carrito inicial con 2 items tal como en el mockup HTML original (Total S/ 37.80)
  late List<CartItem> _cart;

  // Catálogo completo con los 6 items originales + menú completo + bebidas expandidas
  static const List<MenuItem> _catalog = [
    // ------------------- 1. ITEMS ORIGINALES DEL HTML -------------------
    MenuItem(
      id: 1,
      name: 'Whopper® Clásica',
      description:
          'Carne 100% res a la parrilla, tomate jugoso, lechuga fresca, mayonesa y pepinillos.',
      price: 17.90,
      category: 'whopper',
      tags: ['offers', 'bestseller'],
      badgeText: '🔥 Bestseller',
      badgeBg: MenuColors.primary,
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDpTTwv0U_45DADsnQRuSmRXlMR0FLERZBGYclQuURnxN_iP7KMAucP4iWWpe1JRbEDM3oRlX6ttuqDJnZSnB1jh4O5aQeaVNXcT-klQB1mcYrqg6saPUmXRDN3AWZSALMoifiklanzcTVFY7AINuhTuL5QramDsHlA7mFL-ua_yEhwEP3EC1Ot2Qz5QvntkwqqyY9ypBS77QDgnkTR8PFu9tSkiLGBLNHqOv10zQRq',
    ),
    MenuItem(
      id: 2,
      name: 'Whopper® Doble Queso',
      description:
          'Dos carnes jugosas a la parrilla y doble queso cheddar fundido artesanal.',
      price: 24.90,
      category: 'whopper',
      tags: ['bestseller'],
      badgeText: '🧀 Extra Cheddar',
      badgeBg: MenuColors.secondary,
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCKd9tP7bf3k5DDrKlO03TBlHQu9EffnpJ3XbsN2jLvWOrG5r4e3SpyK90BxhyZ8rwFjI-IboHOjyfPGke__hdl5HOtsbvFtVFfyXxZRRHO21jLDhFlC4XJov1wBM8az3RtB8aY8zJJC-QUqMwOW_Oq2anBRqfPfN97rd4YwLk7_tS--IKh6W0V2xDDtaGOAA7uQTnOSd3Jq96sKrLzkaqWPkfxokrguafjgQ0B7Kvp',
    ),
    MenuItem(
      id: 3,
      name: 'Rodeo King BBQ',
      description:
          'Carne a la parrilla, aros de cebolla crocantes, salsa BBQ ahumada y queso suizo.',
      price: 21.90,
      category: 'whopper',
      tags: ['crispy', 'offers'],
      badgeText: '⭐ Nuevo',
      badgeBg: MenuColors.tertiary,
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBSJ9oe33HcoOTVsbrw_Egnmeg2bbLClxlFfTybnJ684g8wl_YiblQ66pP5TtDZL4ZYpFHoDDtWLXjKA9_NH4XLW8hf7LSHFpD1p9zQNpo9gqfdfbRYctF7YafKCHkE7M2WuUKE9H5rS2ziMXtVBMIgMIPwwjCEgJRSOZfMGUhdd8B-KsGux-2X4V7mSi3d6uXk2cF3mmqa_1Ppx1GWqf09Uj7kp6ZoCBSzlFEqMKWF',
    ),
    MenuItem(
      id: 4,
      name: 'King de Pollo Crispy',
      description:
          'Pechuga empanizada con sazón secreta, lechuga y mayonesa suave.',
      price: 15.90,
      category: 'chicken',
      tags: ['crispy'],
      badgeText: '🍗 Extra Crujiente',
      badgeBg: MenuColors.onSecondaryContainer,
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDKESd0UX3xmBjnROCRLxryzCZDTRiTn2zMOKEd62nYuC6FT7fLNcFKGUhFHn-OWU1-gNCR43C_Y2RM308xnbNeqadRU7iBFVTrgpnuG17Q-TnYKNRsHoRTjqmhS6SJiXQuhgIBWIwZvIqRh9hXw5BbeB8TDwZVFwHF83Wn9WNLkueeWl8x7hNfwvRsE5K9TToD5JNkV5yFkYdxJWThP1ZbHA14tt_glZKlHGONKJOw',
    ),
    MenuItem(
      id: 5,
      name: 'Whopper® Vegetal',
      description:
          '0% carne, 100% sabor a la parrilla. Creada con medallón NotCo.',
      price: 18.90,
      category: 'whopper',
      tags: ['plant'],
      badgeText: '🌱 100% Plant-Based',
      badgeBg: MenuColors.tertiaryContainer,
      badgeTextColor: MenuColors.onTertiaryContainer,
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD1_S7TOJuygOafFWRNY8X3rXe3bB798jNYrYkTErVW6Yb278catTfaml_3NYkB2xjkCpG6xku9zhg7DEUvjGXvTCP8Jzk5Q9sqWmeK2nYzxr41g28dsDTuVepM2gur_bU4LJdA00bE-r0SyrzLwJRsIrt5lBTsUiNO943CZx_kvTahk-7ongy2hmFr8dfVj2xA4cuEyqYbk7jXyZAAmSte3u1qo38YXeobANy41uHH',
    ),
    MenuItem(
      id: 6,
      name: 'Mozzarella Sticks (4 uds)',
      description:
          '4 bastones crocantes rellenos de queso fundido con salsa marinara italiana.',
      price: 9.90,
      category: 'sides',
      tags: ['crispy', 'offers'],
      badgeText: '🧀 Snack Favorito',
      badgeBg: MenuColors.secondaryContainer,
      badgeTextColor: MenuColors.onSecondaryContainer,
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC_lBzxqlCyFavvn8SPBS7azUJR96hUKsxl3ow-rlVVCC8AsDXOGhp27C6KPG_yvpcgxqprC4AUDIhfQFqWjWqYp2P6---ynAl_M1GNOeb3GuEfnYe98hhiCbMXYaV8dOq7OU0CnW4p0uuVgv84FCcXq_BRB0-1t7tVphZqB56P2-Dm3aw4LbTWaXtqU1heycmPKen6bHhY40aM2GrMC7QCiZbgNCm1jFeW0YqlltA_',
    ),

    // ------------------- 2. MENÚ COMPLETO: HAMBURGUESAS Y COMBOS -------------------
    MenuItem(
      id: 7,
      name: 'Whopper® Tejano Bacon',
      description:
          'Carne a la parrilla con abundante tocino ahumado, queso cheddar, cebolla crisp y salsa BBQ.',
      price: 22.90,
      category: 'whopper',
      tags: ['offers', 'crispy'],
      badgeText: '🥓 Doble Bacon',
      badgeBg: MenuColors.primary,
      image:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 8,
      name: 'Mega Stacker® Doble',
      description:
          'Dos carnes a la parrilla, salsa Stacker secreta, queso cheddar fundido y tiras de tocino crocante.',
      price: 25.90,
      category: 'whopper',
      tags: ['bestseller'],
      badgeText: '👑 Mega King',
      badgeBg: MenuColors.secondary,
      image:
          'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 9,
      name: 'Whopper® Jr. Queso',
      description:
          'Tamaño compacto ideal: carne a la parrilla, queso cheddar derretido, lechuga y tomate.',
      price: 13.90,
      category: 'whopper',
      tags: ['offers'],
      badgeText: '🍔 Clásico Jr',
      badgeBg: MenuColors.tertiary,
      image:
          'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 10,
      name: 'Chicken Royale Bacon',
      description:
          'Pechuga de pollo alargada empanizada, tiras de tocino ahumado, queso y mayonesa suave.',
      price: 18.90,
      category: 'chicken',
      tags: ['crispy'],
      badgeText: '🍗 Favorito Pollo',
      badgeBg: MenuColors.onSecondaryContainer,
      image:
          'https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 11,
      name: 'King Fish Fillet',
      description:
          'Filete de pescado blanco con empanizado crocante, salsa tártara y queso americano en pan suave.',
      price: 17.50,
      category: 'chicken',
      tags: ['offers'],
      badgeText: '🐟 Mar y Fuego',
      badgeBg: MenuColors.secondary,
      image:
          'https://images.unsplash.com/photo-1521305916504-4a1121188589?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 12,
      name: 'Crispy Tender Strips (5 uds)',
      description:
          '5 tiras de pechuga de pollo marinada con doble apanado extra crujiente y salsa miel-mostaza.',
      price: 16.90,
      category: 'chicken',
      tags: ['crispy'],
      badgeText: '✨ Extra Crunch',
      badgeBg: MenuColors.primary,
      image:
          'https://images.unsplash.com/photo-1562967914-608f82629710?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 13,
      name: 'Combo Whopper® Clásica',
      description:
          'Whopper Clásica a la parrilla + Papas medianas doradas + Gaseosa fría 500ml.',
      price: 26.90,
      category: 'combos',
      tags: ['bestseller', 'offers'],
      badgeText: '🔥 Combo Top',
      badgeBg: MenuColors.primary,
      image:
          'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 14,
      name: 'Combo Stacker® Doble',
      description:
          'Stacker doble carne y tocino + Papas medianas extra crocantes + Gaseosa 500ml a elección.',
      price: 28.90,
      category: 'combos',
      tags: ['bestseller'],
      badgeText: '⭐ Más Vendido',
      badgeBg: MenuColors.secondary,
      image:
          'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 15,
      name: 'Combo Familiar 4x Whopper',
      description:
          '4 Whoppers Clásicas + 2 Papas Medianas + 10 Nuggets crocantes + 4 Bebidas medianas.',
      price: 49.90,
      category: 'combos',
      tags: ['offers'],
      badgeText: '👨‍👩‍👧‍👦 Ahorro Pack',
      badgeBg: MenuColors.primary,
      image:
          'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 16,
      name: 'Combo King de Pollo Dúo',
      description:
          'Sandwich King de pollo crispy dorado + Papas medianas + Gaseosa 500ml helada.',
      price: 22.90,
      category: 'combos',
      tags: ['crispy'],
      badgeText: '🍗 Combo Dúo',
      badgeBg: MenuColors.onSecondaryContainer,
      image:
          'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600&auto=format&fit=crop&q=80',
    ),

    // ------------------- 3. SIDES & DIPS -------------------
    MenuItem(
      id: 17,
      name: 'King Nuggets (10 uds) + Dip',
      description:
          '10 tiernos nuggets de pechuga de pollo con rebozado crujiente y salsa barbacoa.',
      price: 14.90,
      category: 'sides',
      tags: ['crispy', 'offers'],
      badgeText: '✨ Crujientes',
      badgeBg: MenuColors.tertiary,
      image:
          'https://images.unsplash.com/photo-1562967914-608f82629710?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 18,
      name: 'Papas Supremas Cheddar & Bacon',
      description:
          'Papas fritas doradas bañadas en queso cheddar tibio y trocitos de tocino ahumado.',
      price: 13.90,
      category: 'sides',
      tags: ['crispy'],
      badgeText: '🍟 Supremas',
      badgeBg: MenuColors.primary,
      image:
          'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 19,
      name: 'Aros de Cebolla Dorados (8 uds)',
      description:
          'Aros de cebolla enteros dorados y crujientes acompañados de salsa ranch cremosa.',
      price: 8.90,
      category: 'sides',
      tags: ['crispy'],
      badgeText: '🧅 Dorados',
      badgeBg: MenuColors.secondary,
      image:
          'https://images.unsplash.com/photo-1639024471285-0afc385d714b?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 20,
      name: 'Papas Fritas Clásicas Grandes',
      description:
          'Nuestras papas corte recto, doradas por fuera y suaves por dentro con el toque justo de sal.',
      price: 8.50,
      category: 'sides',
      tags: ['offers'],
      badgeText: '🍟 Clásicas',
      badgeBg: MenuColors.tertiary,
      image:
          'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&auto=format&fit=crop&q=80',
    ),

    // ------------------- 4. BEBIDAS EXPANDIDAS & POSTRES -------------------
    MenuItem(
      id: 21,
      name: 'Inca Kola Original (500ml)',
      description:
          'La bebida de sabor nacional peruano servida bien helada para acompañar tu Whopper.',
      price: 6.50,
      category: 'desserts',
      tags: ['bestseller'],
      badgeText: '🇵🇪 La del Perú',
      badgeBg: Color(0xFFD4A017),
      image:
          'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 22,
      name: 'Inca Kola Sin Azúcar (500ml)',
      description:
          'El inconfundible sabor nacional con cero azúcar y máxima frescura burbujeante.',
      price: 6.50,
      category: 'desserts',
      tags: ['offers', 'plant'],
      badgeText: '🌱 Cero Azúcar',
      badgeBg: Color(0xFF388E3C),
      image:
          'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 23,
      name: 'Coca-Cola Sabor Original (500ml)',
      description:
          'La gaseosa más famosa del mundo servida con abundante hielo para refrescarte al 100%.',
      price: 6.50,
      category: 'desserts',
      tags: ['bestseller'],
      badgeText: '🥤 Helada',
      badgeBg: MenuColors.primary,
      image:
          'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 24,
      name: 'Coca-Cola Sin Azúcar (500ml)',
      description:
          'Toda la frescura original de Coca-Cola con 0 calorías y gas ultra refrescante.',
      price: 6.50,
      category: 'desserts',
      tags: ['offers'],
      badgeText: '🖤 Zero Azúcar',
      badgeBg: Color(0xFF212121),
      image:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 25,
      name: 'Chicha Morada Artesanal (16oz)',
      description:
          'Elaborada artesanalmente con maíz morado, piña, canela, clavo de olor y toque de limón fresco.',
      price: 7.50,
      category: 'desserts',
      tags: ['bestseller', 'offers'],
      badgeText: '🍇 Tradicional',
      badgeBg: Color(0xFF4A148C),
      image:
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 26,
      name: 'Jugo de Maracuyá Natural (16oz)',
      description:
          'Puro jugo de maracuyá fresco, cítrico y dulce, servido con abundante hielo picado.',
      price: 7.50,
      category: 'desserts',
      tags: ['offers'],
      badgeText: '🍹 100% Fruta',
      badgeBg: Color(0xFFE65100),
      image:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 27,
      name: 'Sprite Lima-Limón (500ml)',
      description:
          'Refresco transparente de lima-limón con burbujas intensas para calmar la sed al instante.',
      price: 6.50,
      category: 'desserts',
      tags: [],
      badgeText: '🍋 Cítrica',
      badgeBg: Color(0xFF2E7D32),
      image:
          'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 28,
      name: 'Fanta Naranja (500ml)',
      description:
          'Sabor intenso frutal a naranja con efervescencia dulce y refrescante.',
      price: 6.50,
      category: 'desserts',
      tags: [],
      badgeText: '🍊 Frutal',
      badgeBg: Color(0xFFEF6C00),
      image:
          'https://images.unsplash.com/photo-1624517452488-04869289c4ca?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 29,
      name: 'Milkshake Chocolate Belga',
      description:
          'Espeso batido cremoso elaborado con helado de vainilla, fudge de chocolate y crema chantilly.',
      price: 11.90,
      category: 'desserts',
      tags: ['bestseller'],
      badgeText: '🍫 Cremoso',
      badgeBg: Color(0xFF4E342E),
      image:
          'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 30,
      name: 'Milkshake Fresa Silvestre',
      description:
          'Batido espeso con helado de crema, salsa de frutilla natural y corona de crema chantilly.',
      price: 11.90,
      category: 'desserts',
      tags: [],
      badgeText: '🍓 Con Chantilly',
      badgeBg: Color(0xFFC2185B),
      image:
          'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 31,
      name: 'King Fusión Oreo® Supremo',
      description:
          'Copa de suave helado de vainilla con trozos crujientes de galleta Oreo y salsa de chocolate.',
      price: 9.90,
      category: 'desserts',
      tags: ['bestseller', 'crispy'],
      badgeText: '🍪 Tentación',
      badgeBg: Color(0xFF263238),
      image:
          'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 32,
      name: 'Sundae Dulce de Leche y Maní',
      description:
          'Copa helada con salsa caliente de dulce de leche artesanal y lluvia de maní tostado crocante.',
      price: 6.90,
      category: 'desserts',
      tags: ['offers'],
      badgeText: '🍨 Dulce Placer',
      badgeBg: MenuColors.tertiary,
      image:
          'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=600&auto=format&fit=crop&q=80',
    ),
    MenuItem(
      id: 33,
      name: 'Agua San Mateo Sin Gas (600ml)',
      description:
          'Agua mineral pura de manantial para una hidratación limpia, fresca y ligera.',
      price: 5.00,
      category: 'desserts',
      tags: ['plant'],
      badgeText: '💧 De Manantial',
      badgeBg: Color(0xFF0288D1),
      image:
          'https://images.unsplash.com/photo-1560023907-5f339617ea30?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Inicialización del carrito idéntico al código HTML:
    // Item 1: Whopper Clásica (17.90) + Item 6: Mozzarella Sticks (19.90 mockup = 37.80)
    final whopper = _catalog.firstWhere((p) => p.id == 1);
    final sticks = _catalog.firstWhere((p) => p.id == 6);
    _cart = [
      CartItem(item: whopper, quantity: 1),
      CartItem(
        item: MenuItem(
          id: 6,
          name: sticks.name,
          description: sticks.description,
          price: 19.90, // Precio que suma 37.80 con la Whopper como en el HTML original
          category: sticks.category,
          tags: sticks.tags,
          badgeText: sticks.badgeText,
          badgeBg: sticks.badgeBg,
          image: sticks.image,
        ),
        quantity: 1,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _cartTotal {
    double total = 0.0;
    for (var c in _cart) {
      total += c.item.price * c.quantity;
    }
    return total;
  }

  int get _cartItemCount {
    int count = 0;
    for (var c in _cart) {
      count += c.quantity;
    }
    return count;
  }

  void _addToCart(MenuItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.item.id == item.id);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(item: item, quantity: 1));
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
          backgroundColor: MenuColors.inverseSurface,
          duration: const Duration(milliseconds: 1800),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: MenuColors.tertiaryFixed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡${item.name} agregado!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: MenuColors.primary,
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
        ),
      );
  }

  List<MenuItem> get _filteredProducts {
    final query = _searchQuery.toLowerCase().trim();

    return _catalog.where((product) {
      // Búsqueda por texto
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.tags.any((t) => t.toLowerCase().contains(query));

      // Filtro de categorías
      final matchesCategory =
          (_selectedCategory == 'all') ||
          (product.category == _selectedCategory);

      // Filtro dietario / etiquetas
      bool matchesDiet = true;
      if (_selectedDiet == 'offers') {
        matchesDiet = product.tags.contains('offers');
      } else if (_selectedDiet == 'plant') {
        matchesDiet = product.tags.contains('plant');
      } else if (_selectedDiet == 'crispy') {
        matchesDiet = product.tags.contains('crispy');
      }

      return matchesSearch && matchesCategory && matchesDiet;
    }).toList();
  }

  void _resetSearchAndFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'all';
      _selectedDiet = 'all';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;

    return Scaffold(
      backgroundColor: MenuColors.surface,
      appBar: _buildHeader(isDesktop),
      body: Stack(
        children: [
          // Scrollable Menu Content
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Buscador y Filtros Dietarios
                      _buildSearchAndDietFilters(isDesktop),
                      const SizedBox(height: 14),

                      // 2. Category Nav Pills (Sticky/Desplazables)
                      _buildCategoryPills(),
                      const SizedBox(height: 14),

                      // 3. Flame Delivery Promo Callout Pill ("100% Carne a la Parrilla")
                      _buildFlamePromoBanner(),
                      const SizedBox(height: 18),

                      // 4. Product Section Heading ("Favoritos del Menú")
                      _buildSectionHeader(),
                      const SizedBox(height: 14),

                      // 5. Grid de Productos o Estado Vacío
                      _buildProductGrid(isDesktop, screenWidth),

                      // Espacio al final para que el Floating Cart Dock no tape items
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 6. Floating Active Order Dock ("Mi Bandeja • BK Miraflores")
          if (_cartItemCount > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildFloatingCartDock(),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ----------------- HEADER / APP BAR -----------------
  PreferredSizeWidget _buildHeader(bool isDesktop) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(74),
      child: Container(
        decoration: BoxDecoration(
          color: MenuColors.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF502314).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BK Logo (Imagen original con fallback a circulo estilizado)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCpHEFD-EnG2Qg2UPaHOkkc7QvTDEUlpShV5f5DxNo_7AnDToPGbTocCYoTdbzkWN8E32X1UBuFEoMDJrv7eVxlhT88AouoCWFhyWYroaSGoxCPbuZs5wzN9CxGjPyMatdJWNYoJ1iqcMon5_o1k8ZdpyS2KzzZmobCITaGeL3f349MkjVY0aLZQbbMLyJn65Rh5QBM3-1ykFj-_I63NtDjRLYNcUF186xYdGWkK1m4',
                            height: 38,
                            width: 38,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: MenuColors.primaryContainer,
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
                          ),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 12),
                          const Text(
                            'BURGER KING®',
                            style: TextStyle(
                              color: MenuColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Selector de Ubicación ("Miraflores, Lima" + "25-35 min")
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '📍 Restaurante: BK Miraflores, Lima (Abierto)',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.location_on,
                                  color: MenuColors.primary,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Miraflores, Lima',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: MenuColors.onSurface,
                                  ),
                                ),
                                Icon(
                                  Icons.expand_more,
                                  size: 16,
                                  color: MenuColors.onSurfaceVariant,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: MenuColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.schedule,
                                    size: 11,
                                    color: MenuColors.tertiary,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    '25-35 min',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: MenuColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Badge de Coronas + Avatar de Perfil
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: MenuColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF502314,
                                ).withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.workspace_premium,
                                color: MenuColors.tertiaryFixedDim,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '450',
                                style: TextStyle(
                                  color: MenuColors.tertiary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Avatar Profile
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCeC5OFF2oyxuGIzaBxy61vamTMVa20Lahm3ewg-YsQo6qCY2yo_4VpsTErcPpBIeO0CBdU7pjoqimrFJzBA-YMHAtN9CJrj3Z1047EBBliyk2yv5qJo0djv5gsdPKRwvBd-Aq1306V5VEHY1izfxkJxfQKwM4YOU8unoCMDcATB_9KGITi57axB7M7yrvo3GkpX48yn9sHvX19Grc-rI7a940_wTYe20PDFE2npVVm',
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const CircleAvatar(
                              radius: 17,
                              backgroundColor: MenuColors.surfaceContainerHigh,
                              child: Icon(
                                Icons.person,
                                color: MenuColors.onSurfaceVariant,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- BUSCADOR & FILTROS DIETARIOS -----------------
  Widget _buildSearchAndDietFilters(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input de Búsqueda
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: MenuColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF502314).withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.search,
                color: MenuColors.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(
                    fontSize: 14,
                    color: MenuColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Buscar hamburguesas, combos, postres...',
                    hintStyle: TextStyle(
                      color: Color(0xFF926F68),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: MenuColors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Quick Badges / Dietary Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildDietBadge(
                key: 'all',
                label: 'Todos los gustos',
                icon: Icons.restaurant_menu,
              ),
              const SizedBox(width: 8),
              _buildDietBadge(
                key: 'offers',
                label: 'Ofertas 🔥',
                icon: Icons.local_fire_department,
                iconColor: MenuColors.primary,
              ),
              const SizedBox(width: 8),
              _buildDietBadge(
                key: 'plant',
                label: 'Plant-Based 🌱',
                icon: Icons.eco,
                iconColor: MenuColors.tertiary,
              ),
              const SizedBox(width: 8),
              _buildDietBadge(
                key: 'crispy',
                label: 'Crujientes',
                icon: Icons.bakery_dining,
                iconColor: MenuColors.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDietBadge({
    required String key,
    required String label,
    required IconData icon,
    Color? iconColor,
  }) {
    final isSelected = _selectedDiet == key;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedDiet = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? MenuColors.primary
              : MenuColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? MenuColors.primary.withValues(alpha: 0.25)
                  : const Color(0xFF502314).withValues(alpha: 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : (iconColor ?? MenuColors.onSurface),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : MenuColors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- CATEGORY PILLS -----------------
  Widget _buildCategoryPills() {
    final categories = [
      {'key': 'all', 'label': 'Todos'},
      {'key': 'whopper', 'label': 'Whopper® Parrilla'},
      {'key': 'chicken', 'label': 'Pollo & Pescado'},
      {'key': 'combos', 'label': 'Combos'},
      {'key': 'sides', 'label': 'Sides & Dips'},
      {'key': 'desserts', 'label': 'Postres & Bebidas'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => setState(() => _selectedCategory = cat['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MenuColors.secondary
                      : MenuColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF502314).withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : MenuColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ----------------- FLAME DELIVERY CALLOUT PROMO -----------------
  Widget _buildFlamePromoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MenuColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502314).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: MenuColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.whatshot,
                color: MenuColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '100% Carne a la Parrilla',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: MenuColors.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sabor ahumado icónico desde 1954',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: MenuColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: MenuColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'FRESCO AL INSTANTE',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: MenuColors.primary,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- SECTION HEADING -----------------
  Widget _buildSectionHeader() {
    final count = _filteredProducts.length;
    final countText = count == 1 ? '1 delicia' : '$count delicias';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Favoritos del Menú',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: MenuColors.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              countText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: MenuColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: const [
            Icon(Icons.tune, size: 15, color: MenuColors.onSurfaceVariant),
            SizedBox(width: 4),
            Text(
              'Orden: Popular',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: MenuColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ----------------- PRODUCT GRID RESPONSIVE (PC / MOBILE) -----------------
  Widget _buildProductGrid(bool isDesktop, double screenWidth) {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    // Determinamos número de columnas responsivas:
    // Mobile: 2 columnas exactas como el screenshot de móvil
    // Tablet: 3 columnas
    // PC / Desktop amplio: 4 columnas como el screenshot de PC
    int columns = 2;
    if (screenWidth >= 1000) {
      columns = 4;
    } else if (screenWidth >= 650) {
      columns = 3;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;
        
        // Relación de aspecto calculada para que no haya overflow
        // Imagen cuadrada + titulo + desc + precio y boton
        final itemHeight = itemWidth + 148;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        );
      },
    );
  }

  // ----------------- TARJETA DE PRODUCTO INDIVIDUAL -----------------
  Widget _buildProductCard(MenuItem product) {
    return Container(
      decoration: BoxDecoration(
        color: MenuColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF502314).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF502314).withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto con badge flotante
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: MenuColors.surfaceContainer,
                      child: const Center(
                        child: Icon(
                          Icons.lunch_dining,
                          size: 44,
                          color: MenuColors.secondary,
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: MenuColors.surfaceContainer,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MenuColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Badge overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: product.badgeBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      product.badgeText,
                      style: TextStyle(
                        color: product.badgeTextColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Título
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: MenuColors.onSurface,
              height: 1.15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),

          // Descripción
          Expanded(
            child: Text(
              product.description,
              style: const TextStyle(
                fontSize: 11,
                color: MenuColors.onSurfaceVariant,
                height: 1.25,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Fila inferior: Precio y Botón Agregar (+)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Precio',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: MenuColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'S/ ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: MenuColors.primary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                // Botón circular "+" con animación háptica visual
                Material(
                  color: MenuColors.primary,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _addToCart(product),
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- ESTADO VACÍO (EMPTY STATE) -----------------
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: MenuColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.lunch_dining,
                size: 38,
                color: MenuColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '¡No encontramos esa corona!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: MenuColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Prueba buscando con otras palabras como Whopper, Pollo, Papas o Bebidas.',
            style: TextStyle(
              fontSize: 12.5,
              color: MenuColors.onSurfaceVariant,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _resetSearchAndFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: MenuColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              elevation: 3,
            ),
            child: const Text(
              'Ver todo el menú',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- FLOATING ACTIVE ORDER DOCK -----------------
  Widget _buildFloatingCartDock() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 7, bottom: 7),
      decoration: BoxDecoration(
        color: MenuColors.inverseSurface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F1B12).withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Conteo y Total
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: MenuColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_cartItemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Mi Bandeja',
                        style: TextStyle(
                          color: MenuColors.inverseOnSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '• BK Miraflores',
                        style: TextStyle(
                          color: MenuColors.tertiaryFixedDim,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'S/ ${_cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Botón "Ver pedido ->"
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _showCartModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: MenuColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: MenuColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Ver pedido',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------- MODAL DETALLADO DE CARRITO / BANDEJA -----------------
  void _showCartModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: MenuColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Barra de agarre
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MenuColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Encabezado
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag,
                              color: MenuColors.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Mi Bandeja de Pedido',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: MenuColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Lista de productos
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(
                            child: Text(
                              'Tu bandeja está vacía',
                              style: TextStyle(
                                color: MenuColors.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: _cart.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 12),
                            itemBuilder: (context, i) {
                              final cartItem = _cart[i];
                              return Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      cartItem.item.image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 50,
                                        height: 50,
                                        color: MenuColors.surfaceContainer,
                                        child: const Icon(Icons.lunch_dining),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem.item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: MenuColors.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'S/ ${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: MenuColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Controles - / +
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          size: 20,
                                          color: MenuColors.onSurfaceVariant,
                                        ),
                                        onPressed: () {
                                          setModalState(() {
                                            if (cartItem.quantity > 1) {
                                              cartItem.quantity--;
                                            } else {
                                              _cart.removeAt(i);
                                            }
                                          });
                                          setState(() {});
                                        },
                                      ),
                                      Text(
                                        '${cartItem.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: MenuColors.primary,
                                        ),
                                        onPressed: () {
                                          setModalState(() {
                                            cartItem.quantity++;
                                          });
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                  ),

                  // Resumen y botón Checkout
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total a Pagar:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: MenuColors.onSurface,
                                ),
                              ),
                              Text(
                                'S/ ${_cartTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: MenuColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MenuColors.primary,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: _cart.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: MenuColors.primary,
                                          content: Text(
                                            '🎉 ¡Pedido realizado con éxito a BK Miraflores!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                              child: const Text(
                                'Confirmar Pedido a Domicilio',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ----------------- BARRA INFERIOR DE NAVEGACIÓN -----------------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: MenuColors.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D160C).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                0,
                Icons.home,
                'Inicio',
                onTap: widget.onNavigateToHome,
              ),
              _buildNavItem(1, Icons.lunch_dining, 'Menú'),
              _buildNavCouponItem(
                2,
                'Cupones',
                onTap: widget.onNavigateToCoupons,
              ),
              _buildNavItem(
                3,
                Icons.workspace_premium,
                'Coronas',
                onTap: widget.onNavigateToRewards,
              ),
              // Botón Carrito en Barra
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _showCartModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: MenuColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: MenuColors.primaryContainer.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'S/ ${_cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
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

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    final isSelected = _navIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _navIndex = index);
        if (onTap != null) onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? MenuColors.primary
                  : MenuColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? MenuColors.primary
                    : MenuColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCouponItem(
    int index,
    String label, {
    VoidCallback? onTap,
  }) {
    final isSelected = _navIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _navIndex = index);
        if (onTap != null) onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      ? MenuColors.primary
                      : MenuColors.onSurfaceVariant,
                ),
                Positioned(
                  top: -2,
                  right: -7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: MenuColors.primary,
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
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? MenuColors.primary
                    : MenuColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
