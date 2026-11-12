import 'package:flutter/material.dart';
import 'app_theme.dart';

class RestaurantInfo {
  final String id;
  final String name;
  final String address;
  final String district;
  final double distanceKm;
  final String openHours;
  final bool isOpen;
  final bool hasDineIn;
  final Offset mapPosition; // Relative position 0.0 to 1.0 on canvas

  const RestaurantInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.distanceKm,
    required this.openHours,
    required this.isOpen,
    required this.hasDineIn,
    required this.mapPosition,
  });
}

class RestaurantMapView extends StatefulWidget {
  final RestaurantInfo? selectedRestaurant;
  final ValueChanged<RestaurantInfo>? onSelectRestaurant;
  final VoidCallback? onBackToMenu;

  const RestaurantMapView({
    super.key,
    this.selectedRestaurant,
    this.onSelectRestaurant,
    this.onBackToMenu,
  });

  @override
  State<RestaurantMapView> createState() => _RestaurantMapViewState();
}

class _RestaurantMapViewState extends State<RestaurantMapView> {
  final List<RestaurantInfo> _restaurants = const [
    RestaurantInfo(
      id: 'bk_benavides',
      name: 'BK Benavides Miraflores',
      address: 'Av. Alfredo Benavides 1590, Miraflores',
      district: 'Miraflores',
      distanceKm: 0.8,
      openHours: '10:00 AM - 11:30 PM',
      isOpen: true,
      hasDineIn: true,
      mapPosition: Offset(0.48, 0.44),
    ),
    RestaurantInfo(
      id: 'bk_larcomar',
      name: 'BK Larcomar',
      address: 'Malecón de la Reserva 610, Miraflores',
      district: 'Miraflores',
      distanceKm: 1.4,
      openHours: '11:00 AM - 12:00 AM',
      isOpen: true,
      hasDineIn: true,
      mapPosition: Offset(0.28, 0.65),
    ),
    RestaurantInfo(
      id: 'bk_san_isidro',
      name: 'BK Javier Prado San Isidro',
      address: 'Av. Javier Prado Este 2050, San Isidro',
      district: 'San Isidro',
      distanceKm: 2.8,
      openHours: '09:30 AM - 11:00 PM',
      isOpen: true,
      hasDineIn: true,
      mapPosition: Offset(0.62, 0.22),
    ),
    RestaurantInfo(
      id: 'bk_higuereta',
      name: 'BK Óvalo Higuereta Surco',
      address: 'Av. Alfredo Benavides 3899, Santiago de Surco',
      district: 'Santiago de Surco',
      distanceKm: 3.2,
      openHours: '10:00 AM - 11:30 PM',
      isOpen: true,
      hasDineIn: true,
      mapPosition: Offset(0.78, 0.55),
    ),
    RestaurantInfo(
      id: 'bk_salaverry',
      name: 'BK Real Plaza Salaverry',
      address: 'Av. General Salaverry 2370, Jesús María',
      district: 'Jesús María',
      distanceKm: 4.5,
      openHours: '10:30 AM - 10:30 PM',
      isOpen: true,
      hasDineIn: true,
      mapPosition: Offset(0.35, 0.12),
    ),
  ];

  late RestaurantInfo _active;
  String _searchQuery = '';
  String _activeFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _active = widget.selectedRestaurant ?? _restaurants.first;
  }

  List<RestaurantInfo> get _filteredRestaurants {
    return _restaurants.where((r) {
      final matchesSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.district.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.address.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_activeFilter == 'Abiertos ahora') {
        return r.isOpen;
      } else if (_activeFilter == 'Con Salón') {
        return r.hasDineIn;
      }
      return true;
    }).toList();
  }

  void _chooseRestaurant(RestaurantInfo restaurant) {
    setState(() => _active = restaurant);
    widget.onSelectRestaurant?.call(restaurant);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.brown,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.amberAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sede seleccionada: ${restaurant.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
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
    return Column(
      children: [
        // Top search and chips bar
        _buildSearchAndFilters(),

        // Interactive Map
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              _buildMapCanvas(),
              _buildMapOverlayControls(),
            ],
          ),
        ),

        // Bottom Restaurant Cards Sheet
        Expanded(
          flex: 6,
          child: _buildRestaurantCardsList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Buscar por distrito o avenida...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.muted),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: const Icon(Icons.search, color: AppColors.red),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos'),
                const SizedBox(width: 8),
                _buildFilterChip('Abiertos ahora'),
                const SizedBox(width: 8),
                _buildFilterChip('Con Salón'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeFilter = label),
      selectedColor: AppColors.red,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isSelected ? Colors.white : AppColors.brown,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.red : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildMapCanvas() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE5EDE6), // Soft map land color
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: [
                // Base Vector Map Painter
                CustomPaint(
                  size: Size(w, h),
                  painter: _LimaCityMapPainter(),
                ),

                // User Location Pin
                Positioned(
                  left: w * 0.45 - 18,
                  top: h * 0.52 - 18,
                  child: Tooltip(
                    message: 'Tu ubicación actual',
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pins for each restaurant
                ..._filteredRestaurants.map((restaurant) {
                  final isSelected = restaurant.id == _active.id;
                  final px = w * restaurant.mapPosition.dx;
                  final py = h * restaurant.mapPosition.dy;

                  return Positioned(
                    left: px - 24,
                    top: py - 46,
                    child: GestureDetector(
                      onTap: () => setState(() => _active = restaurant),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.red : AppColors.ink,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 4),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lunch_dining, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '${restaurant.distanceKm} km',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Icon(
                            Icons.location_on,
                            size: isSelected ? 42 : 32,
                            color: isSelected ? AppColors.red : const Color(0xFFC4302B),
                            shadows: const [
                              Shadow(color: Colors.black45, blurRadius: 6),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapOverlayControls() {
    return Positioned(
      top: 12,
      right: 12,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                IconButton(
                  tooltip: 'Mi ubicación',
                  icon: const Icon(Icons.my_location, color: AppColors.red, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Centrando en tu ubicación (Miraflores, Lima)...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                IconButton(
                  tooltip: 'Ver todos los locales',
                  icon: const Icon(Icons.layers_outlined, color: AppColors.brown, size: 20),
                  onPressed: () {
                    setState(() => _activeFilter = 'Todos');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCardsList() {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: Row(
              children: [
                const Icon(Icons.storefront, color: AppColors.red, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Restaurantes cercanos (${_filteredRestaurants.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Ordenado por distancia',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _filteredRestaurants.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];
                final isSelected = restaurant.id == _active.id;

                return InkWell(
                  onTap: () => setState(() => _active = restaurant),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.red : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppColors.red.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.red
                                    : AppColors.beige,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lunch_dining,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.brown,
                                  size: 24,
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
                                      Expanded(
                                        child: Text(
                                          restaurant.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.green.shade200),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade700,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Abierto',
                                              style: TextStyle(
                                                color: Colors.green.shade800,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    restaurant.address,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Horario / Schedules row
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 15, color: AppColors.brown),
                            const SizedBox(width: 6),
                            Text(
                              'Horario: ${restaurant.openHours}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'A ${restaurant.distanceKm} km',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.red,
                              ),
                            ),
                          ],
                        ),

                        if (restaurant.hasDineIn) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(Icons.chair_alt,
                                  size: 15, color: AppColors.brown),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Servicio: Consumo en salón y para llevar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.brown,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Obteniendo ruta a ${restaurant.name}...'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.directions, size: 16),
                                label: const Text('Cómo llegar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.brown,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () => _chooseRestaurant(restaurant),
                                icon: const Icon(Icons.check, size: 16),
                                label: Text(
                                  isSelected
                                      ? 'Sede activa • Pedir aquí'
                                      : 'Seleccionar sede',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? AppColors.red
                                      : AppColors.ink,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  elevation: isSelected ? 3 : 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that creates an artistic vector map representing Lima's coastline and main avenues
class _LimaCityMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ocean (Costa Verde / Pacific Ocean) on left/bottom-left
    final oceanPaint = Paint()
      ..color = const Color(0xFFC7DEEC)
      ..style = PaintingStyle.fill;

    final coastPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.18, 0)
      ..quadraticBezierTo(w * 0.22, h * 0.40, w * 0.15, h * 0.70)
      ..quadraticBezierTo(w * 0.10, h * 0.85, 0, h)
      ..close();

    canvas.drawPath(coastPath, oceanPaint);

    // Green cliffs / Malecón strip
    final cliffPaint = Paint()
      ..color = const Color(0xFFB9D8B6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawPath(coastPath, cliffPaint);

    // Parks (e.g. Parque Kennedy, Olivar)
    final parkPaint = Paint()
      ..color = const Color(0xFFD4E6CF)
      ..style = PaintingStyle.fill;

    // Parque Kennedy area
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.48, h * 0.46), width: 36, height: 26),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // El Olivar area
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.52, h * 0.20), width: 44, height: 28),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Minor streets grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.0;

    for (double y = 20; y < h; y += 35) {
      canvas.drawLine(Offset(w * 0.16, y), Offset(w, y), gridPaint);
    }
    for (double x = w * 0.22; x < w; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    // Main Avenues (Av. Larco, Av. Benavides, Av. Javier Prado, Vía Expresa)
    final mainAvePaint = Paint()
      ..color = const Color(0xFFFFF7C2) // classic map yellow avenue
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final mainAveOutline = Paint()
      ..color = const Color(0xFFDFCE98)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    // Vía Expresa Paseo de la República (diagonal)
    final viaExpresa = Path()
      ..moveTo(w * 0.60, 0)
      ..quadraticBezierTo(w * 0.58, h * 0.45, w * 0.52, h);

    canvas.drawPath(viaExpresa, mainAveOutline);
    canvas.drawPath(viaExpresa, mainAvePaint);

    // Av. Benavides (horizontal-ish)
    final benavides = Path()
      ..moveTo(w * 0.22, h * 0.46)
      ..lineTo(w, h * 0.52);

    canvas.drawPath(benavides, mainAveOutline);
    canvas.drawPath(benavides, mainAvePaint);

    // Av. Javier Prado (top)
    final javierPrado = Path()
      ..moveTo(w * 0.20, h * 0.18)
      ..lineTo(w, h * 0.22);

    canvas.drawPath(javierPrado, mainAveOutline);
    canvas.drawPath(javierPrado, mainAvePaint);

    // Av. Larco
    final larco = Path()
      ..moveTo(w * 0.48, h * 0.45)
      ..lineTo(w * 0.28, h * 0.65);

    canvas.drawPath(larco, mainAveOutline);
    canvas.drawPath(larco, mainAvePaint);

    // Avenue Labels
    const labelStyle = TextStyle(
      color: Color(0xFF7A685B),
      fontSize: 9,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    void drawLabel(String text, Offset pos) {
      textPainter.text = TextSpan(text: text, style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, pos);
    }

    drawLabel('Av. Benavides', Offset(w * 0.65, h * 0.49));
    drawLabel('Av. Javier Prado', Offset(w * 0.68, h * 0.19));
    drawLabel('Vía Expresa', Offset(w * 0.56, h * 0.70));
    drawLabel('Océano Pacífico', Offset(w * 0.03, h * 0.40));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
