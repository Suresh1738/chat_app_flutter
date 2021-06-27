import 'package:chat_app/services/auth.dart';
import 'package:chat_app/views/home.dart';
import 'package:chat_app/views/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: Authentication().getCurrentUser(),
        builder: (context,AsyncSnapshot< dynamic> snapshot){
          if(snapshot.hasData){
            return Home();
          }else{
            return SignIn();
          }
        },
      ),
    );
  }
}


