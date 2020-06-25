import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/utilities/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging();

  Future<void> signUp({String name, String email, String password}) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (authResult.user != null) {
        String token = await _messaging.getToken();
        usersRef
            .document(authResult.user.uid)
            .setData({'name': name, 'email': email, 'token': token});
      }
    } on PlatformException catch (e) {
      throw e;
    }
  }

  Future<void> signIn({String email, String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on PlatformException catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    Future.wait([_auth.signOut()]);
  }

  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;
}
