import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/components/message_bubble.dart';
import 'package:lets_chat/models/chat_model.dart';
import 'package:lets_chat/models/message_model.dart';
import 'package:lets_chat/services/db_service.dart';
import 'package:lets_chat/services/storage_service.dart';
import 'package:lets_chat/utilities/constants.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen(this.chat);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DatabaseService _databaseService;
  final _messageController = TextEditingController();
  bool _isComposingMessage = false;

  @override
  void initState() {
    super.initState();

    String currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserID;

    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _databaseService.setChatRead(
        userId: currentUserId, chat: widget.chat, read: true);
  }

  _buildMessageTF() {
    return TextField(
      controller: _messageController,
      onChanged: (input) {
        setState(() {
          _isComposingMessage = input.isNotEmpty;
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        fillColor: Colors.grey[300],
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        hintText: 'Send a message',
        hintStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        prefixIcon: IconButton(
          onPressed: () async {
            PickedFile pickedFile =
                await ImagePicker().getImage(source: ImageSource.gallery);

            if (pickedFile != null) {
              String imageUrl = await Provider.of<StorageService>(context,
                      listen: false)
                  .uploadMessageImageAndGetDownloadUrl(File(pickedFile.path));
              _sendMessage(null, imageUrl);
            }
          },
          icon: Icon(
            Icons.photo,
            size: 22.0,
            color: Theme.of(context).primaryColor,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: _isComposingMessage
              ? () => _sendMessage(_messageController.text.trim(), null)
              : null,
          icon: Icon(
            Icons.send,
            size: 22.0,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  _sendMessage(String text, String imageUrl) {
    if (text != null || imageUrl != null) {
      if (imageUrl == null) {
        setState(() {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _messageController.clear());
        });
      }

      Message message = Message(
        senderId: Provider.of<UserData>(context, listen: false).currentUserID,
        text: text,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
      );

      _databaseService.sendChatMessage(chat: widget.chat, message: message);
    }
  }

  _buildMessagesStream() {
    return StreamBuilder(
      stream: chatsRef
          .document(widget.chat.id)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Expanded(child: SizedBox.shrink());
        }

        return Expanded(
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            physics: AlwaysScrollableScrollPhysics(),
            reverse: true,
            children: _buildMessageBubble(snapshot),
          ),
        );
      },
    );
  }

  _buildMessageBubble(AsyncSnapshot<QuerySnapshot> messages) {
    List<MessageBubble> messageBubbles = [];

    messages.data.documents.forEach((doc) {
      Message message = Message.fromDoc(doc);
      MessageBubble messageBubble =
          MessageBubble(chat: widget.chat, message: message);
      messageBubbles.add(messageBubble);
    });

    return messageBubbles;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        String currentUserId =
            Provider.of<UserData>(context, listen: false).currentUserID;

        _databaseService.setChatRead(
            userId: currentUserId, chat: widget.chat, read: true);
        return Future.value(true); //true ?
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chat.name),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      _buildMessagesStream(),
                      _buildMessageTF(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
