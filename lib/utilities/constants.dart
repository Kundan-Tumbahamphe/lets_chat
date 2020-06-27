import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

final Firestore _db = Firestore.instance;
final CollectionReference usersRef = _db.collection('users');
final CollectionReference chatsRef = _db.collection('chats');

final FirebaseStorage _storage = FirebaseStorage.instance;
final StorageReference storageRef = _storage.ref();

final DateFormat timeFormat = DateFormat('E, h:mm a');
