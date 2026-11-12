import 'dart:async';

import 'package:bod_burguer/services/account_service.dart';
import 'package:bod_burguer/services/order_service.dart';

class FakeAccountService implements AccountService {
  FakeAccountService({this.session});

  AccountSession? session;
  String? rememberedEmail;
  final List<String> events = [];
  final _authChanges = StreamController<AccountSession?>.broadcast();

  @override
  bool get isConfigured => true;

  @override
  AccountSession? get currentSession => session;

  @override
  Stream<AccountSession?> get authStateChanges async* {
    yield session;
    yield* _authChanges.stream;
  }

  @override
  Future<String?> loadRememberedEmail() async => rememberedEmail;

  @override
  Future<void> rememberEmail(String? email) async {
    rememberedEmail = email;
  }

  @override
  Future<AccountSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    events.add('account_created');
    session = AccountSession(uid: 'user-1', email: email, displayName: name);
    _authChanges.add(session);
    return session!;
  }

  @override
  Future<AccountSession> signIn({
    required String email,
    required String password,
  }) async {
    events.add('sign_in');
    session = AccountSession(
      uid: 'user-1',
      email: email,
      displayName: 'Alex Parrilla',
    );
    _authChanges.add(session);
    return session!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    session = null;
    _authChanges.add(null);
  }
}

class FakeOrderService implements OrderService {
  String? lastUserId;
  List<CartItem>? lastItems;
  String orderId = 'order-test-1234';

  @override
  Future<String> createOrder({
    required String userId,
    required List<CartItem> items,
  }) async {
    lastUserId = userId;
    lastItems = List<CartItem>.of(items);
    return orderId;
  }
}
