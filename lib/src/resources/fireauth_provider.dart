import 'package:firebase_auth/firebase_auth.dart';

class FireAuthProvider {
  FirebaseAuth _fireAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signInWithCredential(AuthCredential credential) async {
    return _fireAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    return _fireAuth.signOut();
  }
}
