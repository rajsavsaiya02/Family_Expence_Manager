import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/FireStore_Database/Family_Profile/family_profile_manage.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OneToOneChatScreen extends StatefulWidget {
  final name;
  final profileImg;
  final roomId;
  const OneToOneChatScreen(this.name, this.profileImg, this.roomId, {Key? key}) : super(key: key);

  @override
  State<OneToOneChatScreen> createState() => _OneToOneChatScreenState();
}

class _OneToOneChatScreenState extends State<OneToOneChatScreen> {
  final commanValue cValue = Get.put(commanValue());
  final FamilyGroupKey gValue = Get.put(FamilyGroupKey());
  final GroupController groupController = Get.put(GroupController());
  final TextEditingController _message = TextEditingController();
  final firestore = FirebaseFirestore.instance.collection("family");
  String chatRoomId = "";
  var dateNote;

  void onSendMessage() async {
    if(_message.text.isNotEmpty){
      await firestore.doc(groupController.familyid).collection("chatroom").doc(chatRoomId).collection("chats").orderBy("time",descending: true).limit(1).get().then((value) async {
      if(value.docs.isNotEmpty){
        var data = value.docs[0].data() as Map<String, dynamic>;
        DateTime lastDate = DateTime.parse(data["time"].toString());
        if( DateTime(lastDate.day,lastDate.month,lastDate.year) != DateTime(DateTime.now().day,DateTime.now().month,DateTime.now().year)){
          Map<String, dynamic> date = {
            "sendBy": encryptData("Date", gValue.familyKey.value.key),
            "message" : encryptData(" ", gValue.familyKey.value.key),
            "time": DateTime.now().toIso8601String(),
          };
          await firestore.doc(groupController.familyid).collection("chatroom").doc(chatRoomId.toString())
              .collection("chats").add(date);
        }
      } else{
        Map<String, dynamic> date = {
          "sendBy": encryptData("Date", gValue.familyKey.value.key),
          "message" : encryptData(" ", gValue.familyKey.value.key),
          "time": DateTime.now().toIso8601String(),
        };
        await firestore.doc(groupController.familyid).collection("chatroom").doc(chatRoomId.toString())
            .collection("chats").add(date);
      }
      });
      Map<String, dynamic> messages = {
        "sendBy": encryptData(cValue.currentUser.value.uid.toString(), gValue.familyKey.value.key),
        "message" : encryptData(_message.text.trim().toString(), gValue.familyKey.value.key),
        "time": DateTime.now().toIso8601String(),
      };
      await firestore.doc(groupController.familyid).collection("chatroom").doc(chatRoomId.toString()).set({
        "lastMessage": encryptData(_message.text.trim().toString(),gValue.familyKey.value.key),
        "time": FieldValue.serverTimestamp(),
      });
      await firestore.doc(groupController.familyid).collection("chatroom").doc(chatRoomId.toString())
          .collection("chats").add(messages);
      _message.clear();
    } else {
      showTopTitleSnackBar(context, Icons.message, "Enter some text");
    }
  }

  @override
  void initState() {
    super.initState();
    chatRoomId = widget.roomId.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 5,
        leadingWidth: 30,
        title: Row(
          children: [
            (widget.profileImg.toString() != " " && widget.profileImg.toString().isNotEmpty)
                ? CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.profileImg.toString(),
              imageBuilder: (context, imageProvider) => CircleAvatar(
                backgroundColor: Colors.indigo.shade900,
                radius: 24,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => CircleAvatar(
                backgroundColor: Colors.indigo.shade900,
                radius: 24,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                backgroundColor: Colors.indigo.shade900,
                radius: 24,
                child: Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            )
                : CircleAvatar(
              backgroundColor: Colors.indigo.shade900,
              radius: 24,
              child: Icon(Icons.account_circle,
                  color: Colors.white, size: 50),
            ),
            SizedBox(width: 20,),
            Text(widget.name,overflow: TextOverflow.ellipsis,),
            // IconButton(
            //   icon: Icon(Icons.more_vert),
            //   onPressed: () {
            //     // TODO: Implement more options functionality
            //   },
            // ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.doc(groupController.familyid).collection("chatroom").doc(chatRoomId).collection("chats").orderBy("time",descending: true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if( snapshot.data != null){
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> map = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      if( map.isNotEmpty){
                        return message(map,index);
                      }
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),

          //bottom
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _message,
                    style: TextStyle(fontSize: 18),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    onSendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget message(Map<String, dynamic> map, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenWidth(context),
          child: Column(
            children: [
              if(decryptData(map["sendBy"].toString(),gValue.familyKey.value.key) == "Date")...[
                Align(alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54,width: 0.5),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(map["time"].toString())),
                        style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    )
                ),
              ] else ...[
                Align(
                  alignment: decryptData(map["sendBy"].toString(),gValue.familyKey.value.key) == cValue.currentUser.value.uid.toString()
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 180),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54,width: 0.5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                        bottomLeft:
                        Radius.circular(decryptData(map["sendBy"].toString(),gValue.familyKey.value.key) == cValue.currentUser.value.uid.toString() ? 8.0 : 0),
                        bottomRight:
                        Radius.circular(decryptData(map["sendBy"].toString(),gValue.familyKey.value.key) != cValue.currentUser.value.uid.toString() ? 8.0 : 0),
                      ),
                      color: Colors.white70,
                    ),
                    child: Column(
                      children: [
                        Align(alignment: Alignment.bottomRight,child: Text(DateFormat('hh:mm a').format(DateTime.parse(map["time"].toString())),style: TextStyle(fontSize: 11, color: Colors.black45),),),
                        Align(alignment: Alignment.bottomLeft,child: Text(decryptData(map["message"].toString(),gValue.familyKey.value.key),style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),)),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}