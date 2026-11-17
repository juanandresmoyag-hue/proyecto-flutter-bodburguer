import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.removedIngredients = const [],
    this.extras = const [],
  });

  final String id;
  final String name;
  final double unitPrice;
  final int quantity;
  final List<String> removedIngredients;
  final List<String> extras;

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    name: name,
    unitPrice: unitPrice,
    quantity: quantity ?? this.quantity,
    removedIngredients: removedIngredients,
    extras: extras,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'removedIngredients': removedIngredients,
    'extras': extras,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final unitPrice = json['unitPrice'];
    final quantity = json['quantity'];
    final removedIngredients = json['removedIngredients'] ?? const [];
    final extras = json['extras'] ?? const [];
    if (id is! String ||
        name is! String ||
        unitPrice is! num ||
        quantity is! int ||
        id.isEmpty ||
        name.isEmpty ||
        !unitPrice.toDouble().isFinite ||
        unitPrice <= 0 ||
        quantity < 1 ||
        quantity > 20 ||
        removedIngredients is! List ||
        extras is! List ||
        removedIngredients.any((item) => item is! String) ||
        extras.any((item) => item is! String)) {
      throw const FormatException(
        'El carrito guardado contiene datos inválidos.',
      );
    }
    return CartItem(
      id: id,
      name: name,
      unitPrice: unitPrice.toDouble(),
      quantity: quantity,
      removedIngredients: List<String>.from(removedIngredients),
      extras: List<String>.from(extras),
    );
  }
}

class OrderServiceException implements Exception {
  const OrderServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class OrderService {
  Future<String> createOrder({
    required String userId,
    required List<CartItem> items,
  });
}

class FirebaseOrderService implements OrderService {
  const FirebaseOrderService();

  @override
  Future<String> createOrder({
    required String userId,
    required List<CartItem> items,
  }) async {
    if (Firebase.apps.isEmpty || !DefaultFirebaseOptions.isConfigured) {
      throw const OrderServiceException(
        'Firebase todavía no está configurado. No se guardó el pedido.',
      );
    }
    if (FirebaseAuth.instance.currentUser?.uid != userId) {
      throw const OrderServiceException(
        'Inicia sesión con tu cuenta antes de guardar un pedido.',
      );
    }
    if (items.isEmpty ||
        items.length > 30 ||
        items.any(
          (item) =>
              item.id.isEmpty ||
              item.name.isEmpty ||
              item.name.length > 120 ||
              !item.unitPrice.isFinite ||
              item.unitPrice <= 0 ||
              item.quantity < 1 ||
              item.quantity > 20,
        )) {
      throw const OrderServiceException(
        'El carrito tiene datos inválidos. Revisa los productos e inténtalo de nuevo.',
      );
    }

    final total = items.fold<double>(
      0,
      (runningTotal, item) => runningTotal + item.subtotal,
    );
    final order = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc();
    try {
      await order.set({
        'status': 'received',
        'items': items
            .map(
              (item) => {
                'productId': item.id,
                'name': item.name,
                'unitPrice': item.unitPrice,
                'quantity': item.quantity,
                'subtotal': item.subtotal,
                'removedIngredients': item.removedIngredients,
                'extras': item.extras,
              },
            )
            .toList(),
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw OrderServiceException(
        'No se pudo guardar el pedido (${error.code}). Inténtalo nuevamente.',
      );
    }

    return order.id;
  }
}
