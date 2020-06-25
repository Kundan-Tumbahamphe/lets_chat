import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/models/user_model.dart';
import 'package:lets_chat/utilities/constants.dart';

class DatabaseService {
  Future<User> getUser(String userId) async {
    DocumentSnapshot userDoc = await usersRef.document(userId).get();
    return User.fromDoc(userDoc);
  }

  Future<List<User>> searchUsers(String name, String currentUserId) async {
    QuerySnapshot usersQuerySnap = await usersRef
        .where('name', isGreaterThanOrEqualTo: name)
        .getDocuments();

    List<User> users = [];
    usersQuerySnap.documents.forEach((doc) {
      User user = User.fromDoc(doc);
      if (user.id != currentUserId) {
        users.add(user);
      }
    });
    return users;
  }
}
