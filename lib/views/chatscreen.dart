import 'package:chat_app/helperfunction/sharedpref_helper.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername,name;
  ChatScreen(this.chatWithUsername,this.name) ;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatRoomId,messageId="";
  String myName ,myProfilePic,myUserName,myEmail;
  Stream msgStream;
  TextEditingController messageTextEditingController=TextEditingController();

  
  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername, myUserName);
  }
  getChatRoomIdByUsernames(String a, String b){
    if(a.substring(0,1).codeUnitAt(0)>b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";    
    }else{
      return "$a\_$b";

    }
  }
  addMessage(bool sendClicked){
    if(messageTextEditingController.text != ""){
      String message = messageTextEditingController.text;
      var lastMsgTs=DateTime.now();
      Map<String,dynamic> messageInfo= {
        "message":message,
        "sendBy":myUserName,
        "ts":lastMsgTs,
        "imgUrl":myProfilePic,
      };
      if(messageId== ""){
        messageId =randomAlphaNumeric(12);
      }
      DataBaseServices().addMessageToDb(chatRoomId, messageId, messageInfo).then((value) {
      
      Map<String,dynamic> lastMessageInfo = {
        "lastMessage":message,
        "lastMessageSendTs":lastMsgTs,
        "LastMessageSendBy":myUserName

      };
       DataBaseServices().updateLastMessageSend(chatRoomId,lastMessageInfo);

       if(sendClicked){
         messageTextEditingController.text = "";
         messageId="";
       }
      }
      );
    }

  }
Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0),
                ),
                color: sendByMe ? Colors.blue : Color(0xfff1f0f0),
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }
  Widget chatMessages(){
    return StreamBuilder(
      stream:msgStream,
      builder: (context,snapshot){
        return snapshot.hasData?ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context,index){
            DocumentSnapshot ds =snapshot.data.docs[index];
            return chatMessageTile(
                  ds["message"], myUserName == ds["sendBy"]);
                }):Center(child: CircularProgressIndicator());

      },
    );
  }

  getAndSetMessage() async{
    msgStream=await DataBaseServices().getChatRoomMessages(chatRoomId);
    setState(() {
      
    });
  }

  doThisOnLaunch() async{
    await getMyInfoFromSharedPreference();
    getAndSetMessage();

  }


 @override
  void initState() {
    doThisOnLaunch();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: Container(
        child:Stack(
          
          children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey[400].withOpacity(0.7),
                padding: EdgeInsets.symmetric(horizontal:20,vertical:8),
              child:Row(
                children: [
                  Expanded(child:TextField(
                     onChanged: (value) {
                        addMessage(false);
                      },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "type a message....",
                      
                      ),
                      controller: messageTextEditingController,
                  )),
                  GestureDetector(
                    onTap: (){
                      addMessage(true);
                    },
                    child: Icon(Icons.send)),
                ],

              )
              ),
          )
          ],
        ),
      ),
    );
  }
}