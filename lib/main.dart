import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/user_data.dart';
import 'package:lets_chat/screens/home_screen.dart';
import 'package:lets_chat/screens/welcome_screen.dart';
import 'package:lets_chat/services/auth_service.dart';
import 'package:lets_chat/services/db_service.dart';
import 'package:lets_chat/services/storage_service.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => AuthService(),
          ),
          ChangeNotifierProvider<UserData>(
            create: (_) => UserData(),
          ),
          Provider<DatabaseService>(
            create: (_) => DatabaseService(),
          ),
          Provider<StorageService>(
            create: (_) => StorageService(),
          )
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Let\'s Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromRGBO(48, 51, 107, 1),
      ),
      home: StreamBuilder<FirebaseUser>(
        stream: Provider.of<AuthService>(context, listen: false).user,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Provider.of<UserData>(context, listen: false).currentUserID =
                snapshot.data.uid;
            return HomeScreen();
          } else {
            return WelcomeScreen();
          }
        },
      ),
    );
  }
}
