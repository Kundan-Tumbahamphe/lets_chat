import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/user_data.dart';
import 'package:lets_chat/screens/home_screen.dart';
import 'package:lets_chat/screens/login_screen.dart';
import 'package:lets_chat/services/auth_services.dart';
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
        primaryColor: Colors.white,
      ),
      home: StreamBuilder<FirebaseUser>(
        stream: Provider.of<AuthService>(context, listen: false).user,
        builder: (_, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Provider.of<UserData>(context, listen: false).currentUserID =
                snapshot.data.uid;
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
