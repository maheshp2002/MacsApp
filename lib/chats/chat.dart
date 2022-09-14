import 'dart:io';

import 'package:flutter/rendering.dart';
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

  final id; 
  chat({Key? key,this.id}) : super(key: key);
  @override
  chatState createState() => chatState();
}

//popUp...........................................................................................

enum Menu { itemDelete, itemClearMsg, itemClose}

//.................................................................................................


class chatState extends State<chat> {
  TextEditingController messageController =  TextEditingController();
  
  final collectionReference = FirebaseFirestore.instance;
  var outputFormat = DateFormat('hh:mm a');
  var dateFormat = DateFormat(' yyyy-MM-dd - hh:mm a');

  int cat = 1;
  late String image;
  bool isShowSticker = false;
  bool _show = false;
  
  

  User? user = FirebaseAuth.instance.currentUser;
//..............................................................................................................

  @override
  void initState() {
    super.initState();
    handleScroll();
    print("################################################");
  }  

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

//Show/hide floating button..........................................................................................
  
  void showFloationButton() {
    setState(() {
      _show = true;
    });
  }

  void hideFloationButton() {
    setState(() {
      _show = false;
    });
  }

//Scroll Controller..........................................................................................
  
  void handleScroll() async {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
          showFloationButton();
          
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
          hideFloationButton();
      }
    });
  }


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
                        'sortTime': DateTime.now().toString(),
                        'id': user!.email!,   
                        'reply': reply,
                        'replyName': replyName,
                        'replyMsg': replyMsg,
                        'name': Globalname, 
                        'cat': 2,   
                        'cat1': category,      
                        'isSelected': false,   
                        'date': dateFormat.format(DateTime.now())    
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

selectedItem(String name) async{


  String imgUrl = "";
  if (name == "itemDelete") {
    
  Fluttertoast.showToast(  
  msg: 'Deleting message may take a while...!',  
  toastLength: Toast.LENGTH_LONG,  
  gravity: ToastGravity.BOTTOM,  
  backgroundColor: Colors.blueGrey,  
  textColor: Colors.white);  

    for (var i = 0 ; i <= growableList.length - 1 ; i++){
       try{
            await collectionReference.collection(widget.id).doc(growableList[i]).get()
            .then((snapshot) {
              setState(() {
              imgUrl = snapshot.get('photo');                
              });
        });  
        await FirebaseStorage.instance.refFromURL(imgUrl).delete(); 

     } catch (e){
          debugPrint("error");
     } 

      FirebaseFirestore.instance.collection(widget.id).doc(growableList[i]).delete();

    } 
        
    }else {
      Navigator.of(context).pop();
    }
}
ClearMessage() async{
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromARGB(223, 255, 254, 254),
          title: const Text("Do you want to delete all your messages?", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonBI', color: Colors.blueGrey,fontWeight: FontWeight.bold)),
          
          content: const Text("This will delete all the messages you sent permenantly for both users.", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey,fontWeight: FontWeight.bold)),                    
          
          actions: <Widget>[
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(223, 255, 254, 254)
             ),               
            child: const Text('Cancel',style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey)),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          ),  
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(223, 255, 254, 254)
             ),               
            child: const Text('Delete',style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey)),  
            onPressed: () async { 
              String imgUrl = "";
                        try{
                        await FirebaseFirestore.instance.collection(Globalid).where('id', isEqualTo: user!.email!)
                        .get().then((snapshot) {

                          snapshot.docs.forEach((documentSnapshot) async {
                            String thisDocId = documentSnapshot.id;

                            try{
                                  await collectionReference.collection(Globalid).doc(thisDocId).get()
                                  .then((snapshot) {
                                    setState(() {
                                    imgUrl = snapshot.get('photo');                
                                    });
                              });  
                              await FirebaseStorage.instance.refFromURL(imgUrl).delete(); 

                          } catch (e){
                                debugPrint("error");
                          } 

                         FirebaseFirestore.instance.collection(Globalid).doc(thisDocId).delete();

                        });
                        }
                        );
                        }catch(e){
                          Fluttertoast.showToast(  
                          msg: 'error occured..!',  
                          toastLength: Toast.LENGTH_LONG,  
                          gravity: ToastGravity.BOTTOM,  
                          backgroundColor: Colors.blueGrey,  
                          textColor: Colors.white  
                          );                            
                        }   
            Navigator.of(context).pop();  

            Fluttertoast.showToast(  
            msg: 'Deleting messages may take a while..!',  
            toastLength: Toast.LENGTH_LONG,  
            gravity: ToastGravity.BOTTOM,  
            backgroundColor: Colors.blueGrey,  
            textColor: Colors.white  
            );  
            }, 
            ),

          ],
        ));  
}
//..........................................................................................
    return Scaffold(
      floatingActionButton:  Visibility(
      visible: _show,
      child:Container(
      height: 100.0,
      width: 100.0,
      padding: const EdgeInsets.only(bottom: 50.0),
      child: FloatingActionButton(
        child: Icon(Icons.keyboard_arrow_down, color: Colors.white,),
        onPressed: (){
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        setState(() {
          _show = false;
        });
        },
      ))),
      appBar: AppBar(
        actions: <Widget>[
          // This button presents popup menu items.
          PopupMenuButton<Menu>(
              // Callback that sets the selected popup menu item.
              onSelected: (Menu item) {   

              if (item.name == "itemClearMsg"){
              Fluttertoast.showToast(  
              msg: 'This will delete all the message you sent for both users...!',  
              toastLength: Toast.LENGTH_LONG,  
              gravity: ToastGravity.BOTTOM,  
              backgroundColor: Colors.blueGrey,  
              textColor: Colors.white);        

              ClearMessage();

              }else {      

                selectedItem(item.name);
              }
              },

              itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                     PopupMenuItem<Menu>(
                      value: Menu.itemDelete,
                      child: Row(children: [
                        Icon(Icons.delete, color: Colors.blueGrey,),
                        Text("Delete message",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey,fontWeight: FontWeight.bold))
                      ]),
                    ),
                     PopupMenuItem<Menu>(
                      value: Menu.itemClearMsg,
                      child: Row(children: [
                        Icon(Icons.delete_sweep, color: Colors.blueGrey,),
                        Text("Clear all message",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey,fontWeight: FontWeight.bold))
                      ]),
                    ),                    
                    PopupMenuItem<Menu>(
                      value: Menu.itemClose,
                      child: Row(children: [
                        Icon(Icons.close, color: Colors.blueGrey,),
                        Text("Close",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey,fontWeight: FontWeight.bold))
                      ]),
                    ),
                  ]),
        ],     
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white60,),
        onPressed: () => Navigator.of(context).pop(),
        ),
        title: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").doc(Globalmail)
        .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  
        if (!snapshot.hasData) {   
        return Row(children: [
        InkWell(
        child:  ClipRRect(
         borderRadius: BorderRadius.circular(100),child: 
        Image.network("https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e",
        width: 40, height: 40, fit: BoxFit.fill,))
        ),

        SizedBox(width: 10,),

        Text('name', textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.white70,fontWeight: FontWeight.bold))]);        
        } else {
        return
        Row(children: [
        InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context)=> PhotoView(url: snapshot.data['img'], date: snapshot.data['name']))),
        child:  ClipRRect(
         borderRadius: BorderRadius.circular(100),child: 
        Image.network(snapshot.data['img'], width: 40, height: 40, fit: BoxFit.fill,))
        ),
        
        SizedBox(width: 10,),

        Text(snapshot.data['name'], textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.white70,fontWeight: FontWeight.bold))],);
          }}),          
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
        Column( mainAxisSize: MainAxisSize.min,
        children: [ 
        if(reply == true)...[
                            SizedBox(
                            width: 150,                            
                            child: Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2)
                            ),    
                              child: 
                               category == 1 ?  
                               Column(children: [
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child: 
                                Text(replyName, style: TextStyle(fontSize: 10,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Image.asset("assets/sticker/" + replyMsg + ".gif", width: 30, height: 30,))])

                                : category == 2 ?
                                Column(children: [
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],     
                                child:                             
                                Text(replyName, style: TextStyle(fontSize: 15,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],     
                                child:  
                                Image.network(replyMsg, width: 30, height: 30,))])

                              : Column(children: [ 
                              Container(width: 150,alignment: Alignment.center,
                              color: Colors.blue[100],     
                               child:                                                                 
                              Text(replyName, style: TextStyle(fontSize: 15,fontFamily: 'BrandonBI')),),
                              Container(width: 150,alignment: Alignment.center,
                              color: Colors.blue[50],     
                              child:                                
                              Text(replyMsg, style: TextStyle(fontSize: 15,fontFamily: 'BrandonLI'),)),
                              ],)
                            ),)

        ] else...[

        ],

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
                        'sortTime': DateTime.now().toString(),
                        'id': user!.email!,  
                        'reply': reply,
                        'replyName': replyName,
                        'replyMsg': replyMsg,  
                        'name': Globalname,                       
                        'cat': 3,
                        'cat1': category,
                        'isSelected': false,
                        'date': dateFormat.format(DateTime.now())                  
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
                  reply = false;
                  replyMsg = "";
                  replyName = "";  
                
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
                  reply = false;
                  replyMsg = "";
                  replyName = "";  
                 
                  });

                }         
          },
          icon: Icon(Icons.send, color: Colors.blueGrey,)),            

        ])
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
                        'sortTime': DateTime.now().toString(),
                        'id': user!.email!,   
                        'reply': reply,
                        'replyName': replyName,
                        'replyMsg': replyMsg,  
                        'name': Globalname,                       
                        'cat': 1,
                        'cat1': category,
                        'isSelected': false,
                        'date': dateFormat.format(DateTime.now())                  
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
                        reply = false;
                        replyMsg = "";
                        replyName = "";  
                });
}

}

//global.......................................................................................................
String replyName = "";
String replyMsg = "";
int category = 0;
bool reply = false;
ScrollController scrollController = ScrollController();


//CHAT1.........................................................................................................
class chat1 extends StatefulWidget {
  chat1({Key? key}) : super(key: key);

  @override
  _chat1State createState() => _chat1State();
}

  final growableList = <String>[];

class _chat1State extends State<chat1> {
  TextEditingController messageController =  TextEditingController();
  final collectionReference = FirebaseFirestore.instance;


  bool isSelect = false;
  late String image;
  bool? value = false;
  User? user = FirebaseAuth.instance.currentUser;



  @override
  Widget build(BuildContext context) {

//stickerview......................................................................................................
   _sticker(String date, String name)  async{ 
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromARGB(223, 255, 254, 254),
          title: Center(child: 
          Image.asset("assets/sticker/" + name + ".gif", width: 130, height: 130,)
          ),
          content: Text(date, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI',fontSize: 15, color: Colors.blueGrey,fontWeight: FontWeight.bold)),
          actions: <Widget>[
          Center(child:
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(223, 255, 254, 254)
             ),               
            child: const Text('Close',style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey)),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          )),  
          ],
        ));
  } 
//stickerview......................................................................................................
   _messageView(String date, String msg)  async{ 
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromARGB(223, 255, 254, 254),
          title:  Text(msg, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonBI', fontSize: 25, color: Colors.blueGrey,fontWeight: FontWeight.bold)),
          content:  Text(date, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', fontSize: 15, color: Colors.blueGrey,fontWeight: FontWeight.bold)),          
          actions: <Widget>[
          Center(child:
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(223, 255, 254, 254)
             ),               
            child: const Text('Close',style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey)),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          )),  
          ],
        ));
  } 

//....................................................................................................................
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(Globalid).orderBy("sortTime").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {   
        return  Center(child: 
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Text("Noting is here!", style: TextStyle(color: Colors.grey, fontSize: 20, fontFamily: 'BrandonLI') )
          ],));
        }

      else{
        return ListView(
        controller: scrollController,
        children: [
        ListView.builder(
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,        
                  itemBuilder: (BuildContext context, int index) {

                  return GestureDetector(
                
                onHorizontalDragEnd: (DragEndDetails details) async{
                  if (details.primaryVelocity! > 0) {

                  if(snapshot.data.docs[index]["cat"] == 1){    
                    setState(() {
                      
                        reply = true;
                        replyMsg = snapshot.data.docs[index]["sticker"];
                        replyName = snapshot.data.docs[index]["name"];   
                        category = 1;                                       
                    });                
                        Fluttertoast.showToast(  
                                    msg:"Replying to photo \n double tap on message to view.!",  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white); 

                  } else if(snapshot.data.docs[index]["cat"] == 2){
                    setState(() {
                      
                        reply = true;
                        replyMsg = snapshot.data.docs[index]["photo"];
                        replyName = snapshot.data.docs[index]["name"];  
                        category = 2;                                        
 
                    });
                        Fluttertoast.showToast(  
                                    msg:"Replying to sticker \n double tap on message to view.!",  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white);                     
                  } else {
                    setState(() {
                      
                        reply = true;
                        replyMsg = snapshot.data.docs[index]["msg"];
                        replyName = snapshot.data.docs[index]["name"];   
                        category = 3;   
                    });
                        Fluttertoast.showToast(  
                                    msg:"Replying to " + replyMsg.toString() + "\n double tap on message to view.!",  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white);                     
                  }                 
                  }
                if (details.primaryVelocity! < 0) {

                    setState(() {
                        reply = false;
                        replyMsg = "";
                        replyName = "";     
                    });
                  }
                  
                  },
                  
                 child: InkWell(
                  onLongPress: () async {
                  if (snapshot.data.docs[index]["id"] == user!.email!){
                    if(snapshot.data.docs[index]["isSelected"] == true){
                     
                     for (var i = 0 ; i <= growableList.length - 1 ; i++){
                     await FirebaseFirestore.instance.collection(Globalid).doc(growableList[i]).update({
                        'isSelected': false                
                      });  
                     }
                     setState(() {                    
                     growableList.clear();
                       
                     });

                    }  
                  }                 
                  },                    
                  onDoubleTap: () async{ 
                  if (snapshot.data.docs[index]["id"] == user!.email!){

                    if(snapshot.data.docs[index]["isSelected"] == true){

                     await FirebaseFirestore.instance.collection(Globalid).doc(snapshot.data.docs[index].id).update({
                        'isSelected': false                
                      });  

                     setState(() {                    
                     growableList.remove(snapshot.data.docs[index].id);
                       
                     });

                    } else {

                     await FirebaseFirestore.instance.collection(Globalid).doc(snapshot.data.docs[index].id).update({
                        'isSelected': true                
                      });  

                    setState(() {
                      growableList.add(snapshot.data.docs[index].id);
                    });                   
                    
                    }
                    }
                  },

                  child: 
                  Container(
                    color: snapshot.data.docs[index]["isSelected"] == true ?
                   Color.fromARGB(200, 96, 125, 139) : Colors.white,
                    padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                    child: Align(
                      alignment: (snapshot.data.docs[index]["id"] != user!.email! ? Alignment.topLeft : Alignment.topRight),
                      child: 
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (snapshot.data.docs[index]["id"] != user!.email! ? Colors.grey.shade200 : Colors.blue[200]),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(children: [                       

                          if(snapshot.data.docs[index]["reply"] == true)...[
                            SizedBox(
                            width: 150,                            
                            child: Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2)
                            ),    
                              child: 
                               snapshot.data.docs[index]["cat1"] == 1 ?  
                               Column(children: [
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child: 
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(fontSize: 10,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Image.asset("assets/sticker/" + snapshot.data.docs[index]["replyMsg"] + ".gif", width: 30, height: 30,))])

                                : snapshot.data.docs[index]["cat1"] == 2 ?
                                Column(children: [
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child: 
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(fontSize: 15,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Image.network(snapshot.data.docs[index]["replyMsg"], width: 30, height: 30,))])

                              : Column(children: [  
                              Container(width: 150,alignment: Alignment.center,
                              color: Colors.blue[100],
                              child:                               
                              Text(snapshot.data.docs[index]["replyName"], style: TextStyle(fontSize: 15,fontFamily: 'BrandonBI'),)),
                              Container(width: 150,alignment: Alignment.center,
                              color: Colors.blue[50],
                              child: 
                              Text(snapshot.data.docs[index]["replyMsg"], style: TextStyle(fontSize: 15,fontFamily: 'BrandonLI'),)),
                              ],)
                            ),)
                          ]else...[
                            Text("")
                          ],

                        snapshot.data.docs[index]["cat"] == 1 ? 
                        InkWell(
                        onTap: () => _sticker(snapshot.data.docs[index]["date"], snapshot.data.docs[index]["sticker"]),
                        child:                         
                        Image.asset("assets/sticker/" + snapshot.data.docs[index]["sticker"] + ".gif", width: 80, height: 80,))

                        : snapshot.data.docs[index]["cat"] == 2 ?
                        InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context)=> PhotoView(url: snapshot.data.docs[index]["photo"], date: snapshot.data.docs[index]["date"]))),
                        child: 
                        Image.network(snapshot.data.docs[index]["photo"], width: 150, height: 150,),)
                        
                        : InkWell(
                        onTap: () => _messageView(snapshot.data.docs[index]["date"], snapshot.data.docs[index]["msg"]),
                        child:                          
                        Text(snapshot.data.docs[index]["msg"], style: TextStyle(fontSize: 15,fontFamily: 'BrandonBI'),)),
                        
                        SizedBox(width: 80, child:
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Text(snapshot.data.docs[index]["time"], style: TextStyle(fontSize: 10,fontFamily: 'BrandonLI'),)],),),

                        ],)
                      ),
                    ),
                  )));
              },),

              SizedBox(height: 50,)
              
              ]);
    
      }});

  }
  
}

//PhotoView............................................................................................
class PhotoView extends StatefulWidget {

  final date;
  final url; 
  PhotoView({Key? key,this.date,this.url}) : super(key: key);

  @override
  PhotoViewState createState() => PhotoViewState();
}

class PhotoViewState extends State<PhotoView>{
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
        backgroundColor: Colors.black,    
        leading: IconButton(
              icon:  Icon(
                Icons.arrow_back,
                color: Colors.white, // Change Custom Drawer Icon Color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },),
        title:  Text(
          widget.date,
          style: TextStyle(
            color: Colors.white,fontFamily: 'BrandonBIBI',
            fontSize: 18,
          ),
        ),
        elevation: 5.0,
        centerTitle: true,
      ),

      backgroundColor: Colors.black,

      body: Container(
        color: Colors.black,
        child: Center(child:
        Image.network(widget.url)),
        ),
  ); 
      
  }


}