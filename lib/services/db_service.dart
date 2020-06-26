import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/chat_model.dart';
import 'package:lets_chat/models/message_mode.dart';
import 'package:lets_chat/models/user_model.dart';
import 'package:lets_chat/services/storage_service.dart';
import 'package:lets_chat/utilities/constants.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';

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
    //made private
    DocumentSnapshot userDoc = await usersRef.document(userId).get();
    return User.fromDoc(userDoc);
  }

  Future<bool> createChat(
      {BuildContext context,
      String name,
      File file,
      List<String> usersIds}) async {
    String imageUrl = await Provider.of<StorageService>(context, listen: false)
        .uploadChatImageAndGetDownloadUrl(
            imageFile: file, url: null); //fix this, don't rely on provider

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

  void setChatRead({BuildContext context, Chat chat, bool read}) {
    String currentUserId = Provider.of<UserData>(context)
        .currentUserID; //fix this, don't rely on provider
    chatsRef.document(chat.id).updateData({'readStatus.$currentUserId': read});
  }
}
