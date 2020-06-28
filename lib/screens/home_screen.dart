import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/chat_model.dart';
import 'package:lets_chat/models/user_data.dart';
import 'package:lets_chat/screens/search_user_screen.dart';
import 'package:lets_chat/services/auth_service.dart';
import 'package:lets_chat/utilities/constants.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _buildChat(Chat chat, String currentUserId) {
    final bool isRead = chat.readStatus[currentUserId];

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        radius: 28.0,
        backgroundImage: CachedNetworkImageProvider(chat.imageUrl),
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          chat.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: Theme.of(context).primaryColor),
        ),
      ),
      subtitle: chat.recentSender == ' '
          ? Text(
              'Chat Created',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            )
          : chat.recentMessage != null //error prone?
              ? Text(
                  '${chat.memberInfo[chat.recentSender]['name']}: ${chat.recentMessage}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Text(
                  '${chat.memberInfo[chat.recentSender]['name']} sent an image',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              timeFormat.format(chat.recentTimestamp.toDate()),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          isRead
              ? Text('')
              : Container(
                  alignment: Alignment.center,
                  height: 20.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(48, 51, 107, 0.8),
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
        ],
      ),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ChatScreen(chat))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserID;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).signOut();
          },
        ),
        title: Text('Let\'s Chat'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => SearchUserScreen())),
          ),
        ],
      ),
      body: StreamBuilder(
        //old state error (doesn't extract old data when app is re-installed)
        stream: chatsRef
            .where('memberIds', arrayContains: currentUserId)
            .orderBy('recentTimestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
                //what about newly created users
//              child: CircularProgressIndicator(),
                );
          }

          return ListView.separated(
            itemCount: snapshot.data.documents.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(thickness: 1.0);
            },
            itemBuilder: (BuildContext context, int index) {
              Chat chat = Chat.fromDoc(snapshot.data.documents[index]);
              return _buildChat(chat, currentUserId);
            },
          );
        },
      ),
    );
  }
}
