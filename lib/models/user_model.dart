import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String token;

  User({this.id, this.name, this.email, this.token});

  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      name: doc['name'],
      email: doc['email'],
      token: doc['token'],
    );
  }
}
