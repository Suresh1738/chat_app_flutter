import 'package:chat_app/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: (){
          Authentication().signInWithGoogle(context);
        },
              child: Center(
          child: Container(
            decoration: BoxDecoration(color: Colors.redAccent,borderRadius: BorderRadius.circular(24)),
            padding: EdgeInsets.symmetric(horizontal: 16,vertical:9),
            child: Text("Sign In With Google",style:TextStyle(fontSize: 18,color: Colors.white)),
          ),
        ),
      ),


    );
  }
}