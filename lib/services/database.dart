import 'package:chat_app/helperfunction/sharedpref_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataBaseServices{

  Future addUserInfotofDb(String userId,Map<String,dynamic>userInfoMap ) async{
    return await FirebaseFirestore.instance.collection('users').doc(userId).set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String userName) async{
    return  FirebaseFirestore.instance
    .collection("users")
    .where("username",isEqualTo:userName)
    .snapshots();

  }

  Future addMessageToDb(String chatRoomId,String messageId , Map<String,dynamic> messageInfo) async{
    return FirebaseFirestore.instance
    .collection("chatrooms")
    .doc(chatRoomId)
    .collection("chats")
    .doc(messageId).set(messageInfo);
  }
  updateLastMessageSend(String chatRoomId, Map<String,dynamic> lastMessageInfo){
    return FirebaseFirestore.instance
    .collection("chatrooms")
    .doc(chatRoomId).update(lastMessageInfo);
  }

    createChatRoom(String chatRoomId, Map chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom does not exists
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }
  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async{
    return FirebaseFirestore.instance
    .collection("chatrooms")
    .doc(chatRoomId)
    .collection("chats")
    .orderBy("ts",descending: true)
    .snapshots();
  }

  getChatRooms() async  {
    String myUsername=await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
    .collection("chatrooms")
    .orderBy("lastMessageSendTs",descending: true)
    .where("users",arrayContains:myUsername)
    .snapshots();
  }
  
  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }

}