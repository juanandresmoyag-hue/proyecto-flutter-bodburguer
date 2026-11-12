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
  });

  final String id;
  final String name;
  final double unitPrice;
  final int quantity;

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    name: name,
    unitPrice: unitPrice,
    quantity: quantity ?? this.quantity,
  );
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
