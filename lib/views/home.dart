import 'package:chat_app/helperfunction/sharedpref_helper.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatscreen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
   String myName, myProfilePic, myUserName, myEmail;
  Stream usersStream, chatRoomsStream;
  

  TextEditingController searchUsernameEditingController =
  TextEditingController();
  
  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchBtnClicked() async{
    isSearching=true;
    usersStream= await DataBaseServices().getUserByUserName(searchUsernameEditingController.text);
    setState(() {});
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget searchListUserTile({String profileUrl,name,username,email}){
    return GestureDetector(
      onTap: (){
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };
        DataBaseServices().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(context,MaterialPageRoute(builder: (context)=>ChatScreen(username,name)));
      },
        child: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
              profileUrl,
              height:30,
              width:30
            ),
          ),
          SizedBox(width:12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),Text(email)
            ],
          ),
        ],
      ),
    );
  }
  
  Widget searchUserList(){
   return StreamBuilder(
     stream: usersStream,
     builder: (context,snapshot){
       return snapshot.hasData?ListView.builder(
         itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
         itemBuilder: (context,index){
          DocumentSnapshot ds=snapshot.data.docs[index];
          return searchListUserTile(profileUrl:ds["imgUrl"],name:ds["name"],username:ds["username"],email:ds["email"]);
         },

       ):Center(
         child: CircularProgressIndicator(),
       );
     },


   );
  }
getChatRooms() async {
    chatRoomsStream = await DataBaseServices().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Chat App'),
      centerTitle: true,
      actions: [
        InkWell(
          onTap: (){
            Authentication().signOut().then((value) =>  Navigator.pushReplacement(context,
             MaterialPageRoute(builder: (context)=> SignIn())));
          },
          child: Container(
            padding:EdgeInsets.symmetric(horizontal:12),
            child: Icon(Icons.exit_to_app)
            ),
        )],
      ),
      body:Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child:Column(
          children: [
            Row(
              children: [
                isSearching ?
                GestureDetector(
                  onTap: (){
                    isSearching=false;
                    searchUsernameEditingController.text = "";
                    setState((){});
                  },
                  child: Padding(
                  padding:EdgeInsets.only(right:12),
                  child: Icon(Icons.arrow_back)
                  ),
                )
                :Container(),
                SizedBox(width:12),
                Expanded(
                    child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration:BoxDecoration(
                      border: Border.all(color:Colors.black,width:1,style: BorderStyle.solid),
                      borderRadius:BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      Expanded(
                      child: TextField(
                      controller:searchUsernameEditingController,
                      decoration: InputDecoration(
                        border:InputBorder.none,
                        hintText:"Search Freinds",
                      ),
                    )),
                    GestureDetector(
                      onTap: (){
                        if(searchUsernameEditingController.text != ""){
                          isSearching=true;
                          onSearchBtnClicked();
                        }
                      },
                      child: Icon( Icons.search))],
                      ),
                  ),
                ),
              ],
            ),
            isSearching ?searchUserList()
            :chatRoomsList(),
          ],
        ),
      ),
    );
  }
}
class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DataBaseServices().getUserInfo(username);
    print(
        "something bla bla ${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["name"]}  ${querySnapshot.docs[0]["imgUrl"]}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                profilePicUrl,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 3),
                Text(widget.lastMessage)
              ],
            )
          ],
        ),
      ),
    );
  }
}