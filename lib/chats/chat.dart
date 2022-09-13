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

  int cat = 1;
  bool isShowSticker = false;
  late String image;
  String datetime = DateTime.now().toString();
  

  User? user = FirebaseAuth.instance.currentUser;
//..........................................................................................
Future<String> uploadFile(_image) async {

              FirebaseStorage storage = FirebaseStorage.instance;
              Reference ref = storage.ref().child(user!.email! + "- chat -" + DateTime.now().toString());
              await ref.putFile(File(_image.path));
              String returnURL = await ref.getDownloadURL();
              return returnURL;
            }

//..........................................................................................

  Future<void> saveImages(File _image) async {
               
              //_image.forEach((image) async {
              String imageURL = await uploadFile(_image);

                  try{
                      await FirebaseFirestore.instance.collection(widget.id).add({
                        'photo': imageURL,
                        'time': outputFormat.format(DateTime.now()),
                        'id': user!.email!,   
                        'cat': 2                
                      });  
                     
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white); 
                                    }   
                setState(() {
                  cat = 1;
                }); 
                    
}
//..........................................................................................

// Image Picker
  File _image = File(''); // Used only if you need a single picture
  bool isloading = false;
//..........................................................................................

  @override
  Widget build(BuildContext context) {

//........................................................................................

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if(gallery) {
      pickedFile = (await picker.getImage(
          source: ImageSource.gallery))!;
    } 
    // Otherwise open camera to get new photo
    else{
      pickedFile = (await picker.getImage(
          source: ImageSource.camera,))!;
    }

    setState(() {
      if (pickedFile != null) {
        //_images.add(File(pickedFile.path));
        _image= File(pickedFile.path); // Use if you only need a single picture
      } else {
        debugPrint('No image selected.');
      }
    });
  }

 //..........................................................................................
  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {

      Navigator.pop(context);
    }

    return Future.value(false);
  }
//..........................................................................................
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white60,),
        onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(children: [
        ClipRRect(
         borderRadius: BorderRadius.circular(100),child: 
        Image.network(widget.img, width: 40, height: 40, fit: BoxFit.fill,)),
        SizedBox(width: 10,),
        Text(widget.name, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.white70,fontWeight: FontWeight.bold))],),          
      ),

      backgroundColor: Colors.white,

      body: SafeArea(
        child: WillPopScope(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  Expanded(child: 
                  chat1()
                  ),

                  // Sticker
                  isShowSticker ? buildSticker() : SizedBox.shrink(),

                ],
              ),

              // Loading
              //buildLoading()
            ],
          ),
          onWillPop: onBackPress,
        ),
      ),

      bottomSheet: StreamBuilder(
      stream: FirebaseFirestore.instance.collection(widget.id).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {   
        return Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(onPressed: (){

          }, 
          icon: Icon(CupertinoIcons.smiley, color: Colors.blueGrey,)),

          SizedBox(width: 5,),

          IconButton(onPressed: (){

          }, 
          icon: cat != 2 ? Icon(CupertinoIcons.photo, color: Colors.blueGrey,)
          : isloading == false ?
          ClipRRect( 
            child: Image.file(
              _image,
              width: 30,
              height: 30,
              fit: BoxFit.fill
              ),)
          : CircularProgressIndicator(color: Colors.blueGrey,)
          ),

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
            setState(() {
              //cat = 1;
              isShowSticker == false ? isShowSticker = true : isShowSticker = false;
            });

          }, 
          icon: Icon(CupertinoIcons.smiley, color: Colors.blueGrey,)),

          SizedBox(width: 5,),

          IconButton(onPressed: (){
            setState(() {
              cat = 2;
              isShowSticker = false ;
            });

            getImage(true);

          }, 
          icon: cat != 2 ? Icon(CupertinoIcons.photo, color: Colors.blueGrey,)
          : isloading == false ?
          ClipRRect( 
            child: Image.file(
              _image,
              width: 30,
              height: 30,
              fit: BoxFit.fill
              ),)
          : CircularProgressIndicator(color: Colors.blueGrey,)
          ),

          SizedBox(width: 5,),

               Expanded(child: 
               InkWell(child: 
               TextFormField(
                enabled: cat == 1? true : false,
                controller: messageController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                ),
                textCapitalization: TextCapitalization.words,
                decoration:  InputDecoration(
                  hintText: cat == 1? 'Type down your message' : 'Tap here cancel image',
                  border: UnderlineInputBorder(),
                ),
              ),
              onTap: () {
                setState(() {
                  cat = 1;
                });
              }
               ),
              ),

          SizedBox(width: 10,),

          IconButton(onPressed: () async{

                setState(() {
                  isShowSticker = false;
                });            
                if (cat == 1){
                 if (messageController.text.trim().isNotEmpty)
                 {
                 try{ 

                      await FirebaseFirestore.instance.collection(widget.id).add({
                        'msg': messageController.text.trim(),
                        'time': outputFormat.format(DateTime.now()),
                        'id': user!.email!,   
                        'cat': 3                
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

                setState(() {
                  cat = 1;
                });  
                } else {
                
                debugPrint("no message");

                }
                } else {

                  setState(() {                    
                  isloading = true;
                  });

                  await saveImages(_image);

                  setState(() {                    
                  isloading = false;
                  });

                }         
          },
          icon: Icon(Icons.send, color: Colors.blueGrey,)),            

        ]);
    
      }})
    );

  }
  Widget buildSticker() {
    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi1'),
                  child: Image.asset(
                    'assets/sticker/mimi1.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi2'),
                  child: Image.asset(
                    'assets/sticker/mimi2.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi3'),
                  child: Image.asset(
                    'assets/sticker/mimi3.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi4'),
                  child: Image.asset(
                    'assets/sticker/mimi4.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi5'),
                  child: Image.asset(
                    'assets/sticker/mimi5.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi6'),
                  child: Image.asset(
                    'assets/sticker/mimi6.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi7'),
                  child: Image.asset(
                    'assets/sticker/mimi7.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi8'),
                  child: Image.asset(
                    'assets/sticker/mimi8.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi9'),
                  child: Image.asset(
                    'assets/sticker/mimi9.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
        padding: EdgeInsets.all(5),
        height: 180,
      ),
    );
  }

onSendMessage(String sticker) async {
                   try{ 

                      await FirebaseFirestore.instance.collection(widget.id).add({
                        'sticker': sticker,
                        'time': outputFormat.format(DateTime.now()),
                        'id': user!.email!,   
                        'cat': 1                
                      });  
                     
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white); 
                                    }    
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
      stream: FirebaseFirestore.instance.collection(Globalid).orderBy("time").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {   
        return  Center(child: 
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Text("Noting is here!", style: TextStyle(color: Colors.grey, fontSize: 20, fontFamily: 'BrandonLI') )
          ],));
        }

      else{
        return ListView(children: [
                  
        ListView.builder(
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,        
                  itemBuilder: (BuildContext context, int index) {

                  return Container(
                    padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                    child: Align(
                      alignment: (snapshot.data.docs[index]["id"] != user!.email! ? Alignment.topLeft : Alignment.topRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (snapshot.data.docs[index]["id"] != user!.email! ? Colors.grey.shade200 : Colors.blue[200]),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(children: [
                        snapshot.data.docs[index]["cat"] == 1 ? 
                        Image.asset("assets/sticker/" + snapshot.data.docs[index]["sticker"] + ".gif", width: 80, height: 80,)

                        : snapshot.data.docs[index]["cat"] == 2 ?
                        Image.network(snapshot.data.docs[index]["photo"], width: 150, height: 150,)
                        
                        : Text(snapshot.data.docs[index]["msg"], style: TextStyle(fontSize: 15,fontFamily: 'BrandonBI'),),
                        
                        SizedBox(width: 80, child:
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Text(snapshot.data.docs[index]["time"], style: TextStyle(fontSize: 10,fontFamily: 'BrandonLI'),)],),),

                        ],)
                      ),
                    ),
                  );
              },),

              SizedBox(height: 50,)
              
              ]);
    
      }});

  }
}

