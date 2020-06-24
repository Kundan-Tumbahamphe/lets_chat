import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore _db = Firestore.instance;
final CollectionReference usersRef = _db.collection('users');
final CollectionReference chatsRef = _db.collection('chats');
