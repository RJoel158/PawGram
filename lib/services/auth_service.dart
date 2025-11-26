import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  Future<User?> register(String username, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    await _db.child("users/${user!.uid}").set({
      "uid": user.uid,
      "email": email.trim(),
      "username": username,
      "bio": "",
      "photoUrl": "",
      "createdAt": DateTime.now().toIso8601String(),
    });

    return user;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> logout() => _auth.signOut();
}
