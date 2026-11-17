import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';

class AccountSession {
  const AccountSession({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  final String uid;
  final String email;
  final String displayName;

  factory AccountSession.fromUser(User user) => AccountSession(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName ?? '',
  );
}

class AccountServiceException implements Exception {
  const AccountServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AccountService {
  bool get isConfigured;
  AccountSession? get currentSession;
  Stream<AccountSession?> get authStateChanges;

  Future<String?> loadRememberedEmail();
  Future<void> rememberEmail(String? email);
  Future<AccountSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<AccountSession> signIn({
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

class FirebaseAccountService implements AccountService {
  const FirebaseAccountService();

  static const _rememberedEmailKey = 'remembered_login_email';

  @override
  bool get isConfigured =>
      Firebase.apps.isNotEmpty && DefaultFirebaseOptions.isConfigured;

  FirebaseAuth get _auth {
    _ensureConfigured();
    return FirebaseAuth.instance;
  }

  FirebaseFirestore get _firestore {
    _ensureConfigured();
    return FirebaseFirestore.instance;
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw const AccountServiceException(
        'Firebase todavía no está configurado. Sigue la guía de configuración '
        'incluida en el proyecto para habilitar cuentas y pedidos.',
      );
    }
  }

  @override
  AccountSession? get currentSession {
    if (!isConfigured) {
      return null;
    }
    final user = FirebaseAuth.instance.currentUser;
    return user == null ? null : AccountSession.fromUser(user);
  }

  @override
  Stream<AccountSession?> get authStateChanges {
    if (!isConfigured) {
      return Stream<AccountSession?>.value(null);
    }
    return FirebaseAuth.instance.authStateChanges().map(
      (user) => user == null ? null : AccountSession.fromUser(user),
    );
  }

  @override
  Future<String?> loadRememberedEmail() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_rememberedEmailKey);
  }

  @override
  Future<void> rememberEmail(String? email) async {
    final preferences = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await preferences.remove(_rememberedEmailKey);
    } else {
      await preferences.setString(_rememberedEmailKey, email);
    }
  }

  @override
  Future<AccountSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    late final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AccountServiceException(_authErrorMessage(error.code));
    }

    final user = credential.user;
    if (user == null) {
      throw const AccountServiceException(
        'Firebase no devolvió la cuenta creada. Inténtalo nuevamente.',
      );
    }

    try {
      await user.updateDisplayName(name.trim());
      final userReference = _firestore.collection('users').doc(user.uid);
      final loginReference = userReference.collection('loginEvents').doc();
      final batch = _firestore.batch()
        ..set(userReference, {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        })
        ..set(loginReference, {
          'event': 'account_created',
          'method': 'email_password',
          'createdAt': FieldValue.serverTimestamp(),
        });
      await batch.commit();
    } on FirebaseException catch (error) {
      try {
        await user.delete();
      } on FirebaseAuthException {
        throw const AccountServiceException(
          'No se pudo guardar el perfil en Firestore y Firebase no permitió '
          'revertir la cuenta. Contacta al administrador antes de registrarte '
          'de nuevo.',
        );
      }
      throw AccountServiceException(
        'No se pudo guardar el perfil en Firestore (${error.code}). '
        'La cuenta se revirtió; inténtalo nuevamente.',
      );
    }

    return AccountSession.fromUser(user);
  }

  @override
  Future<AccountSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AccountServiceException(
          'Firebase no devolvió la sesión iniciada. Inténtalo nuevamente.',
        );
      }

      try {
        await _recordLogin(user.uid);
      } on FirebaseException catch (error) {
        await _auth.signOut();
        throw AccountServiceException(
          'No se pudo guardar el registro de acceso (${error.code}). '
          'Inténtalo nuevamente.',
        );
      }

      return AccountSession.fromUser(user);
    } on FirebaseAuthException catch (error) {
      throw AccountServiceException(_authErrorMessage(error.code));
    }
  }

  Future<void> _recordLogin(String uid) async {
    await _firestore.collection('users').doc(uid).collection('loginEvents').add(
      {
        'event': 'sign_in',
        'method': 'email_password',
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AccountServiceException(_authErrorMessage(error.code));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AccountServiceException(_authErrorMessage(error.code));
    }
  }

  String _authErrorMessage(String code) => switch (code) {
    'email-already-in-use' => 'Ese correo ya tiene una cuenta.',
    'invalid-email' => 'Ingresa un correo electrónico válido.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Correo o contraseña incorrectos.',
    'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
    'too-many-requests' =>
      'Demasiados intentos. Espera un momento y vuelve a probar.',
    'network-request-failed' =>
      'No hay conexión. Revisa internet e inténtalo de nuevo.',
    'operation-not-allowed' =>
      'Firebase no tiene habilitado el acceso con correo y contraseña.',
    _ => 'Firebase no pudo completar la operación ($code).',
  };
}
