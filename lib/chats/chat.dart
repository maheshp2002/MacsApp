import 'dart:io';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:macsapp/homepage/homeScreen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


class chat extends StatefulWidget {
  final name;
  final about; 
  final img; 
  final id; 
  chat({Key? key,this.name,this.about,this.img,this.id}) : super(key: key);
  @override
  _chatState createState() => _chatState();
}

class _chatState extends State<chat> {
  TextEditingController messageController =  TextEditingController();
  final collectionReference = FirebaseFirestore.instance;
  var outputFormat = DateFormat('hh:mm a');

  String datetime = DateTime.now().toString();
  
  late String image;

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white60,),
        onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.name, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.white70,fontWeight: FontWeight.bold)),          
      ),
      backgroundColor: Colors.white,
      body: //ListView(
        //children: [
          chat1(),
      //   ],
      // ),
      bottomSheet: StreamBuilder(
      stream: FirebaseFirestore.instance.collection(widget.id).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {   
        return Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(onPressed: (){

          }, 
          icon: Icon(CupertinoIcons.smiley, color: Colors.blueGrey,)),

          SizedBox(width: 10,),

              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
               child:
               TextFormField(
                controller: messageController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                ),
                textCapitalization: TextCapitalization.words,
                decoration:  InputDecoration(
                  hintText: 'Type down your message',
                  prefixIcon: Icon(Icons.person),
                  border: UnderlineInputBorder(),
                ),
              ),
              ),

          SizedBox(width: 10,),

          IconButton(onPressed: (){

          }, 
          icon: Icon(Icons.send, color: Colors.blueGrey,)),            

        ]);
        }

      else{
        return 
        
        Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(onPressed: (){

          }, 
          icon: Icon(CupertinoIcons.smiley, color: Colors.blueGrey,)),

          SizedBox(width: 5,),

               Expanded(child: 
               TextFormField(
                controller: messageController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                ),
                textCapitalization: TextCapitalization.words,
                decoration:  InputDecoration(
                  hintText: 'Type down your message',
                  border: UnderlineInputBorder(),
                ),
              ),
              ),

          SizedBox(width: 10,),

          IconButton(onPressed: () async{
                 try{
                      await FirebaseFirestore.instance.collection(widget.id).add({
                        'msg': messageController.text.trim(),
                        'time': outputFormat.format(DateTime.now()),
                        'id': user!.email!,                   
                      });  
                     
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white); 
                                    }   
                      messageController.clear();           
          },
          icon: Icon(Icons.send, color: Colors.blueGrey,)),            

        ]);
    
      }})
    );

  }
}

//CHAT1.........................................................................................................
class chat1 extends StatefulWidget {
  chat1({Key? key}) : super(key: key);

  @override
  _chat1State createState() => _chat1State();
}

class _chat1State extends State<chat1> {
  TextEditingController messageController =  TextEditingController();
  final collectionReference = FirebaseFirestore.instance;

  late String image;

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(Globalid).where('id', isEqualTo: user!.email!).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {   
        return  Center(child: 
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Text("Noting is here!", style: TextStyle(color: Colors.grey, fontSize: 20, fontFamily: 'BrandonLI') )
          ],));
        }

      else{
        return ListView.builder(
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,        
                  itemBuilder: (BuildContext context, int index) {

                  return Container(
                    padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                    child: Align(
                      alignment: (snapshot.data.docs[index]["id"] != user!.email!?Alignment.topLeft:Alignment.topRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(children: [
                        Text(snapshot.data.docs[index]["msg"], style: TextStyle(fontSize: 15,fontFamily: 'BrandonBI'),),
                        SizedBox(width: 80, child:
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Text(snapshot.data.docs[index]["time"], style: TextStyle(fontSize: 10,fontFamily: 'BrandonLI'),)],),),

                        ],)
                      ),
                    ),
                  );
              },);
    
      }});

  }
}

