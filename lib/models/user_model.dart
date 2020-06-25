import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
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

  @override
  List<Object> get props => [id, name, email, token];
}
