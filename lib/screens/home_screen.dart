import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/chat_model.dart';
import 'package:lets_chat/models/user_data.dart';
import 'package:lets_chat/screens/search_user_screen.dart';
import 'package:lets_chat/services/auth_service.dart';
import 'package:lets_chat/utilities/constants.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _buildChat(Chat chat, String currentUserId) {
    final bool isRead = chat.readStatus[currentUserId];
    final TextStyle readStyle = TextStyle(
      fontWeight: isRead ? FontWeight.w400 : FontWeight.bold,
    );

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        radius: 28.0,
        backgroundImage: CachedNetworkImageProvider(chat.imageUrl),
      ),
      title: Text(
        chat.name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: chat.recentSender == ' '
          ? Text(
              'Chat Created',
              overflow: TextOverflow.ellipsis,
              style: readStyle,
            )
          : chat.recentMessage != null //error prone?
              ? Text(
                  '${chat.memberInfo[chat.recentSender]['name']}: ${chat.recentMessage}',
                  overflow: TextOverflow.ellipsis,
                  style: readStyle,
                )
              : Text(
                  '${chat.memberInfo[chat.recentSender]['name']} sent an image',
                  overflow: TextOverflow.ellipsis,
                  style: readStyle,
                ),
      trailing: Text(
        timeFormat.format(chat.recentTimestamp.toDate()),
        style: readStyle,
      ),
//      onTap: () => Navigator.push(
//          context, MaterialPageRoute(builder: (_) => ChatScreen(chat))),
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
        //old state error
        stream: chatsRef
            .where('memberIds', arrayContains: currentUserId)
            .orderBy('recentTimestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(//what about newly created users
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
