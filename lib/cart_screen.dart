import 'package:flutter/material.dart';

import 'services/account_service.dart';
import 'services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.accountService,
    required this.orderService,
  });

  final List<CartItem> items;
  final ValueChanged<List<CartItem>> onItemsChanged;
  final AccountService accountService;
  final OrderService orderService;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isSaving = false;
  late List<CartItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List<CartItem>.of(widget.items);
  }

  double get _total =>
      _items.fold<double>(0, (total, item) => total + item.subtotal);

  void _updateItem(CartItem item, int quantity) {
    final items = _items
        .where((current) => current.id != item.id || quantity > 0)
        .map(
          (current) => current.id == item.id
              ? current.copyWith(quantity: quantity)
              : current,
        )
        .toList();
    setState(() => _items = items);
    widget.onItemsChanged(items);
  }

  Future<void> _placeOrder() async {
    final session = widget.accountService.currentSession;
    if (session == null) {
      _showMessage('Inicia sesión para guardar tu pedido.');
      return;
    }
    if (_items.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final orderId = await widget.orderService.createOrder(
        userId: session.uid,
        items: List<CartItem>.unmodifiable(_items),
      );
      if (!mounted) return;
      setState(() => _items = const []);
      widget.onItemsChanged(const []);
      _showMessage('Pedido guardado en tu cuenta: ${orderId.substring(0, 8)}');
    } on OrderServiceException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tu carrito')),
    body: _items.isEmpty
        ? const Center(
            child: Text('Tu carrito está vacío. Agrega algo del menú.'),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  Text(
                                    'S/ ${item.unitPrice.toStringAsFixed(2)} c/u',
                                  ),
                                  Text(
                                    'Subtotal: S/ ${item.subtotal.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Quitar una unidad de ${item.name}',
                              onPressed: () =>
                                  _updateItem(item, item.quantity - 1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              tooltip: 'Agregar una unidad de ${item.name}',
                              onPressed: item.quantity >= 20
                                  ? null
                                  : () => _updateItem(item, item.quantity + 1),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            IconButton(
                              tooltip: 'Eliminar ${item.name}',
                              onPressed: () => _updateItem(item, 0),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: S/ ${_total.toStringAsFixed(2)}',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pedido de demostración: no incluye pago ni envío real.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _placeOrder,
                        icon: _isSaving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          _isSaving ? 'Guardando...' : 'Guardar pedido',
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
