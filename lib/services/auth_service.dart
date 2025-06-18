import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Auth durumu stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password ile giriş
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email/Password ile kayıt
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String sicilNo,
    required String ekip,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Kullanıcı profilini Firestore'a kaydet
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': email.trim(),
        'fullName': fullName,
        'sicilNo': sicilNo,
        'ekip': ekip,
        'rol': 'operator',
        'createdAt': DateTime.now(),
        'isActive': true,
      });

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kullanıcı verilerini al
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Firebase Auth hatalarını Türkçe mesajlara çevir
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu email adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      case 'invalid-email':
        return 'Geçersiz email adresi.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}