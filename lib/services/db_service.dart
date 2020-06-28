import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/models/chat_model.dart';
import 'package:lets_chat/models/message_model.dart';
import 'package:lets_chat/models/user_model.dart';
import 'package:lets_chat/utilities/constants.dart';

class DatabaseService {
  Future<List<User>> searchUsers({String name, String userId}) async {
    QuerySnapshot usersQuerySnap = await usersRef
        .where('name', isGreaterThanOrEqualTo: name)
        .getDocuments();

    List<User> users = [];
    usersQuerySnap.documents.forEach((doc) {
      User user = User.fromDoc(doc);
      if (user.id != userId) {
        users.add(user);
      }
    });
    return users;
  }

  Future<User> _getUser(String userId) async {
    DocumentSnapshot userDoc = await usersRef.document(userId).get();
    return User.fromDoc(userDoc);
  }

  Future<bool> createChat(
      {String name, String imageUrl, List<String> usersIds}) async {
    List<dynamic> memberIds = [];
    Map<String, dynamic> memberInfo = {};
    Map<String, dynamic> readStatus = {};

    for (String id in usersIds) {
      memberIds.add(id);

      User user = await _getUser(id);
      Map<String, dynamic> userDetail = {
        'name': user.name,
        'email': user.email,
        'token': user.token,
      };

      memberInfo[id] = userDetail;
      readStatus[id] = false;
    }

    await chatsRef.add({
      'name': name,
      'imageUrl': imageUrl,
      'recentMessage': 'Chat created',
      'recentSender': ' ',
      'recentTimestamp': Timestamp.now(),
      'memberIds': memberIds,
      'memberInfo': memberInfo,
      'readStatus': readStatus,
    });

    return true;
  }

  void sendChatMessage({Chat chat, Message message}) {
    chatsRef.document(chat.id).collection('messages').add({
      'senderId': message.senderId,
      'text': message.text,
      'imageUrl': message.imageUrl,
      'timestamp': message.timestamp
    });
  }

  void setChatRead({String userId, Chat chat, bool read}) {
    chatsRef.document(chat.id).updateData({'readStatus.$userId': read});
  }
}
