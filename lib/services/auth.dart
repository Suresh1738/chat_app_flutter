import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_app/helperfunction/sharedpref_helper.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication{
  final FirebaseAuth auth=FirebaseAuth.instance;
  final gooleSignIn = GoogleSignIn();


  getCurrentUser() async{
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async{
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn=GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount =await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
         GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        
      final AuthCredential credential=GoogleAuthProvider.credential(idToken:googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken);

      UserCredential result=await _firebaseAuth.signInWithCredential(credential);
      User userDetails= result.user;
      
     if(result != null){
      SharedPreferenceHelper().saveUserEmail(userDetails.email);
      SharedPreferenceHelper().saveUserId(userDetails.uid);
      SharedPreferenceHelper().saveUserName(userDetails.email.replaceAll("@gmail.com", ""));
      SharedPreferenceHelper().saveDisplayName(userDetails.displayName);
      SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL);
      
      Map<String ,dynamic> userInfoMap={
        "email":userDetails.email,
        "username":userDetails.email.replaceAll("@gmail.com", ""),
        "name":userDetails.displayName,
        "imgUrl":userDetails.photoURL
      };
      DataBaseServices().addUserInfotofDb(userDetails.uid, userInfoMap).then((value) => 
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home())));

     }
      }
  }
  Future signOut() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }

}