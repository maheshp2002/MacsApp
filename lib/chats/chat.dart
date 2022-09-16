import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:macsapp/homepage/homeScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';


class chat extends StatefulWidget {

  final id; 
  final online;
  chat({Key? key,this.id,this.online}) : super(key: key);
  @override
  chatState createState() => chatState();
}

//popUp...........................................................................................

enum Menu { itemDelete, itemClearMsg, itemClose, itemHideOnline}

//.................................................................................................


class chatState extends State<chat> {
  TextEditingController messageController =  TextEditingController();
  
  final collectionReference = FirebaseFirestore.instance;
  var outputFormat = DateFormat('hh:mm a');
  var dateFormat = DateFormat(' yyyy-MM-dd - hh:mm a');
  PlatformFile? pickfile;
  bool isBottomSheet = false;
  //TextEditingController messageController =  TextEditingController();
  //final collectionReference = FirebaseFirestore.instance;

  ValueNotifier<bool> reply = ValueNotifier(false);
  bool isSelect = false;
  late String image;
  bool? value = false;
  User? user = FirebaseAuth.instance.currentUser;
  int cat = 1;
  bool color = true;
  bool isShowSticker = false;
  bool _show = false;
  
  

 // User? user = FirebaseAuth.instance.currentUser;
//.................................................................................................................

  @override
  void initState() {
    super.initState();
    handleScroll();
    chatView();
  }  


//chat view.........................................................................................................
    chatView() async{
                        try{
                        await FirebaseFirestore.instance.collection(Globalid).where('id', isNotEqualTo: user!.email!)
                        .get().then((snapshot) {

                          snapshot.docs.forEach((documentSnapshot) async {
                            String thisDocId = documentSnapshot.id;

                          try{
                            FirebaseFirestore.instance.collection(Globalid).doc(thisDocId).update({
                              'color': color,
                            });

                          } catch (e){
                                debugPrint("error");
                          } 

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

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }
//Scroll Controller..........................................................................................
  
  void handleScroll() async {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
          showFloationButton();
          
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
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
                        'color': false,
                        'photoname': photoname,
                        'isImage': isImage,
                        'time': outputFormat.format(DateTime.now()),
                        'sortTime': DateTime.now().toString(),
                        'id': user!.email!,   
                        'reply': reply.value,
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
                  isImage = true;
                  reply = ValueNotifier<bool>(false);
                }); 
                    
}
//..........................................................................................

// Image Picker
  File _image = File(''); // Used only if you need a single picture
  bool isloading = false;

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
        photoname = (pickedFile.path.split('/').last);

      } else {
        debugPrint('No image selected.');
      }
    });
  }

 //..........................................................................................

  @override
  Widget build(BuildContext context) {

//stickerview......................................................................................................
   _sticker(String date, String name)  async{ 
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Center(child: 
          Image.asset("assets/sticker/" + name + ".gif", width: 130, height: 130,)
          ),
          content: Text(date, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI',fontSize: 15, color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          actions: <Widget>[
          Center(child:
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor
             ),               
            child:  Text('Close',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title:  Text(msg, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonBI', fontSize: 25, color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          content:  Text(date, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', fontSize: 15, color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),          
          actions: <Widget>[
          Center(child:
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor
             ),               
            child:  Text('Close',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          )),  
          ],
        ));
  } 
// selectFile() async {
//   final result = await FilePicker.platform.pickFiles(allowMultiple: false);
//   if(result == null) return;

//   setState(() {
//     pickfile = result.files.first;
//    _image = File(pickfile!.path!);
//     photoname = pickfile!.name;
//   });
  

// }

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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text("Do you want to delete all your messages?", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          
          content: Text("This will delete all the messages you sent permenantly for both users.", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),                    
          
          actions: <Widget>[
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor
             ),               
            child: Text('Cancel',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          ),  
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor
             ),               
            child: Text('Delete',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
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
      child:Container(padding: EdgeInsets.only(bottom: 40),
      height: 85.0,
      width: 85.0,
      //padding: const EdgeInsets.only(bottom: 50.0),
      child: Container(
      child: 
      FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: Padding(padding: EdgeInsets.only(top: 3), 
        child: 
        Icon(Icons.keyboard_arrow_down, color: Colors.white,size: 40,)),
        onPressed: (){
        scrollController.jumpTo(scrollController.position.minScrollExtent);
        setState(() {
          _show = false;
        });
        },
      )))),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          // This button presents popup menu items.
          PopupMenuButton<Menu>(
              // Callback that sets the selected popup menu item.
              onSelected: (Menu item) async{   

              if (item.name == "itemClearMsg") {
              Fluttertoast.showToast(  
              msg: 'This will delete all the message you sent for both users...!',  
              toastLength: Toast.LENGTH_LONG,  
              gravity: ToastGravity.BOTTOM,  
              backgroundColor: Colors.blueGrey,  
              textColor: Colors.white);        

              ClearMessage();

              } else if (item.name == "itemHideOnline") {
              
              if (showOnline == true) {
                
                FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                  'showOnline': false
                });


              setState(() {
              showOnline =  false; 
              });

              } else {

                FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                  'showOnline': true
                });


              setState(() {
              showOnline =  true; 
              });

              }

              }
              else {      

                selectedItem(item.name);
              }
              },

              itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                     PopupMenuItem<Menu>(
                      value: Menu.itemDelete,
                      child: Row(children: [
                        Icon(Icons.delete, color: Theme.of(context).hintColor,),
                        Text("Delete message",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold))
                      ]),
                    ),
                     PopupMenuItem<Menu>(
                      value: Menu.itemClearMsg,
                      child: Row(children: [
                        Icon(Icons.delete_sweep, color: Theme.of(context).hintColor,),
                        Text("Clear all message",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold))
                      ]),
                    ),      
                     PopupMenuItem<Menu>(
                      value: Menu.itemHideOnline,
                      child: Row(children: [
                        showOnline == true ? Icon(Icons.visibility, color: Theme.of(context).hintColor,) 
                        : Icon(Icons.visibility_off, color: Theme.of(context).hintColor,),
                        Text(showOnline == true ? " Hide online" : " Show online",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold))
                      ]),
                    ),                                    
                    PopupMenuItem<Menu>(
                      value: Menu.itemClose,
                      child: Row(children: [
                        Icon(Icons.close, color: Theme.of(context).hintColor,),
                        Text("Close",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold))
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

        Column(children: [
          
        SizedBox(height: 10,),

        Text('name', textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.white70,fontWeight: FontWeight.bold)),     
        

        Text("offline",
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.white70, fontSize: 13)), 

         SizedBox(height: 10,),    

        ]),
        ]);  
        } else {
        return
        Row(children: [
        InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context)=> photoView(url: snapshot.data['img'], date: snapshot.data['name']))),
        child:  ClipRRect(
         borderRadius: BorderRadius.circular(100),child: 
        Image.network(snapshot.data['img'], width: 40, height: 40, fit: BoxFit.fill,))
        ),
        
        SizedBox(width: 10,),

        Column(children: [
        
        snapshot.data['showOnline'] == true ? SizedBox(height: 10,) : SizedBox(height: 30,),

        Text(snapshot.data['name'], textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.white70,fontWeight: FontWeight.bold)),
        
        snapshot.data['showOnline'] == true ? 
        Text(snapshot.data['isOnline'] == true ? "online" : "offline", 
          style:  TextStyle(fontFamily: 'BrandonLI', color: snapshot.data['isOnline'] == true ? Color.fromARGB(255, 4, 255, 12) : Colors.white70, fontSize: 13))

        : Text(""), 

         SizedBox(height: 10,),    
                   
        ]),
          ],);
          }}),          
      ),

      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: WillPopScope(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  Expanded(child: 
//....................................................................................................................
     StreamBuilder(
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
        reverse: true,
        children: [
        ListView.builder(
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,        
                  itemBuilder: (BuildContext context, int index) {

                  return 
                Stack(
                  children: [
                                 
                  //GestureDetector(
                
                // onHorizontalDragEnd: (DragEndDetails details) async{
                //   if (details.primaryVelocity! > 0) {

                //   if(snapshot.data.docs[index]["cat"] == 1){    
                //     setState(() {
                      
                //         reply = ValueNotifier<bool>(true);
                //         replyMsg = snapshot.data.docs[index]["sticker"];
                //         replyName = snapshot.data.docs[index]["name"];   
                //         category = 1;                                       
                //     });                
                //         Fluttertoast.showToast(  
                //                     msg:"Replying to sticker \n double tap on message to view.!",  
                //                     toastLength: Toast.LENGTH_LONG,  
                //                     gravity: ToastGravity.BOTTOM,  
                //                     backgroundColor: Colors.blueGrey,  
                //                     textColor: Colors.white); 

                //   } else if(snapshot.data.docs[index]["cat"] == 2){
                //     setState(() {
                      
                //          reply = ValueNotifier<bool>(true);
                //         replyMsg = snapshot.data.docs[index]["photo"];
                //         replyName = snapshot.data.docs[index]["name"];  
                //         category = 2;                                        
 
                //     });
                //         Fluttertoast.showToast(  
                //                     msg:"Replying to photo \n double tap on message to view.!",  
                //                     toastLength: Toast.LENGTH_LONG,  
                //                     gravity: ToastGravity.BOTTOM,  
                //                     backgroundColor: Colors.blueGrey,  
                //                     textColor: Colors.white);                     
                //   } else {
                //     setState(() {
                      
                //         reply = ValueNotifier<bool>(true);
                //         replyMsg = snapshot.data.docs[index]["msg"];
                //         replyName = snapshot.data.docs[index]["name"];   
                //         category = 3;   
                //     });
                //         Fluttertoast.showToast(  
                //                     msg:"Replying to " + replyMsg.toString() + "\n double tap on message to view.!",  
                //                     toastLength: Toast.LENGTH_LONG,  
                //                     gravity: ToastGravity.BOTTOM,  
                //                     backgroundColor: Colors.blueGrey,  
                //                     textColor: Colors.white);                     
                //   }                 
                //   }
                // if (details.primaryVelocity! < 0) {

                //     setState(() {
                //         reply = ValueNotifier<bool>(false);
                //         replyMsg = "";
                //         replyName = "";     
                //     });
                //   }
                  
                //   },
                  
                //  child: 
                 InkWell(
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
                   Color.fromARGB(200, 96, 125, 139) : Theme.of(context).scaffoldBackgroundColor ,
                    padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                    child: Align(
                      alignment: (snapshot.data.docs[index]["id"] != user!.email! ? Alignment.topLeft : Alignment.topRight),
                      child: 
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).cardColor : Colors.blue[200]),
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
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(color: Colors.blueGrey, fontSize: 10,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Image.asset("assets/sticker/" + snapshot.data.docs[index]["replyMsg"] + ".gif", width: 30, height: 30,))])

                                : snapshot.data.docs[index]["cat1"] == 2 ?
                                snapshot.data.docs[index]["isImage"] == true ?
                                Column(children: [
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child: 
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(color: Colors.blueGrey, fontSize: 15,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Image.network(snapshot.data.docs[index]["replyMsg"], width: 30, height: 30,))])

                                : Column(children: [  
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child:                               
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Text(snapshot.data.docs[index]["photoname"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonLI'),))])

                                : Column(children: [  
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child:                               
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Text(snapshot.data.docs[index]["replyMsg"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonLI'),)),
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
                        builder: (context)=> PhotoView2(url: snapshot.data.docs[index]["photo"], date: snapshot.data.docs[index]["date"],
                        name: snapshot.data.docs[index]["photoname"], isImage: snapshot.data.docs[index]["isImage"],))),
                        child: snapshot.data.docs[index]["isImage"] == true ?
                        Image.network(snapshot.data.docs[index]["photo"], width: 150, height: 150,)
                        :  SizedBox(width: 200,
                        child:
                        Row(
                        children: [
                        Icon(Icons.file_download, color: Theme.of(context).hintColor, size: 30,),
                        SizedBox(width: 10),
                        Expanded(child:
                        Text(snapshot.data.docs[index]["photoname"], style: TextStyle(color: Theme.of(context).hintColor,fontSize: 10,fontFamily: 'BrandonLI'),))]))
                        )
                        
                        : InkWell(
                        onTap: () => _messageView(snapshot.data.docs[index]["date"], snapshot.data.docs[index]["msg"]),
                        child:                          
                        Text(snapshot.data.docs[index]["msg"], style: TextStyle(color: Theme.of(context).hintColor,fontSize: 15,fontFamily: 'BrandonBI'),)),
                        
                        SizedBox(width: 80, child:
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Text(snapshot.data.docs[index]["time"], style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10,fontFamily: 'BrandonLI'),),
                        SizedBox(width: 5,),
                        Icon(Icons.check, color: snapshot.data.docs[index]["color"] == true ? Colors.blue: Colors.grey[500], size: 15,)
                        ],),),

                        ],)
                      ),
                    ),
                  )),
                  // CircleAvatar(
                  //   child:
                  SizedBox(width: 10,),  

                  ValueListenableBuilder(
                  valueListenable: reply,
                  builder: (context, value, widget) { 
                  return Align(alignment: Alignment.centerLeft,
                  child: 
                  Container(
                  padding: EdgeInsets.only(left: 10),
                  width: 40, height: 40,
                  child: FloatingActionButton(
                  backgroundColor: Color.fromARGB(200, 255, 255, 255),
                  onPressed: (){
                  if(snapshot.data.docs[index]["cat"] == 1){    
                    setState(() {
                      
                        reply = ValueNotifier<bool>(true);
                        replyMsg = snapshot.data.docs[index]["sticker"];
                        replyName = snapshot.data.docs[index]["name"];   
                        category = 1;                                       
                    });                
                        // Fluttertoast.showToast(  
                        //             msg:"Replying to sticker \n double tap on message to view.!",  
                        //             toastLength: Toast.LENGTH_LONG,  
                        //             gravity: ToastGravity.BOTTOM,  
                        //             backgroundColor: Colors.blueGrey,  
                        //             textColor: Colors.white); 

                  } else if(snapshot.data.docs[index]["cat"] == 2){
                    if(snapshot.data.docs[index]["isImage"] == true){

                    setState(() {                     
                        reply = ValueNotifier<bool>(true);
                        isImage  = snapshot.data.docs[index]["isImage"];
                        replyMsg = snapshot.data.docs[index]["photo"];
                        replyName = snapshot.data.docs[index]["name"];  
                        category = 2;                                        
 
                    });
                    //     Fluttertoast.showToast(  
                    //                 msg:"Replying to photo \n double tap on message to view.!",  
                    //                 toastLength: Toast.LENGTH_LONG,  
                    //                 gravity: ToastGravity.BOTTOM,  
                    //                 backgroundColor: Colors.blueGrey,  
                    //                 textColor: Colors.white);  
                     } else{
                    setState(() {                     
                        reply = ValueNotifier<bool>(true);
                        photoname = snapshot.data.docs[index]["photoname"];
                        isImage  = snapshot.data.docs[index]["isImage"];
                        replyMsg = snapshot.data.docs[index]["photo"];
                        replyName = snapshot.data.docs[index]["name"];  
                        category = 2;                                        
 
                    });
                        // Fluttertoast.showToast(  
                        //             msg:"Replying to doc \n double tap on message to view.!",  
                        //             toastLength: Toast.LENGTH_LONG,  
                        //             gravity: ToastGravity.BOTTOM,  
                        //             backgroundColor: Colors.blueGrey,  
                        //             textColor: Colors.white);                        
                    }                   
                  } else {
                    setState(() {                      
                        reply = ValueNotifier<bool>(true);
                        replyMsg = snapshot.data.docs[index]["msg"];
                        replyName = snapshot.data.docs[index]["name"];   
                        category = 3;   
                    });
                        // Fluttertoast.showToast(  
                        //             msg:"Replying to " + replyMsg.toString() + "\n double tap on message to view.!",  
                        //             toastLength: Toast.LENGTH_LONG,  
                        //             gravity: ToastGravity.BOTTOM,  
                        //             backgroundColor: Colors.blueGrey,  
                        //             textColor: Colors.white);                     
                  }
                  }, 
                  child: Icon(Icons.reply,color: Colors.blueGrey,))),
                  );
                  })
                  ]);
              },),

              //SizedBox(height: 50,)
              
              ]);
    
      }})
                  ),

                  // Sticker
                  isShowSticker ? buildSticker() : SizedBox.shrink(),

      Align(alignment: Alignment.bottomCenter,
      child: 
      StreamBuilder(
      stream: FirebaseFirestore.instance.collection(widget.id).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {  
        return Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(onPressed: (){

          }, 
          icon: Icon(CupertinoIcons.smiley, color: Theme.of(context).hintColor,)),

          SizedBox(width: 5,),

          IconButton(onPressed: (){

          }, 
          icon: //cat != 2 ? 
          Icon(FontAwesomeIcons.upload, color: Theme.of(context).hintColor,)
          // : isloading == false ?
          // ClipRRect( 
          //   child: Image.file(
          //     _image,
          //     width: 30,
          //     height: 30,
          //     fit: BoxFit.fill
          //     ),)
          // : CircularProgressIndicator(color: Colors.blueGrey,)
          ),

          SizedBox(width: 5,),

            Expanded(child: Container(
            constraints: BoxConstraints(maxHeight: 200),
             child:
               TextFormField(
                controller: messageController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
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
              )),

          SizedBox(width: 10,),

          IconButton(onPressed: (){

          }, 
          icon: Icon(Icons.send, color: Theme.of(context).hintColor,)),            

        ]);
        }

      else{
        return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Theme.of(context).hintColor),
          )),
        child:
        Column( mainAxisSize: MainAxisSize.min,
        children: [ 
        ValueListenableBuilder(
        valueListenable: reply,
        builder: (context, value, widget) {

        if(value == true){
                     return SizedBox(
                            width: 200,                            
                            child: 
                            Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2)
                            ),    
                              child: 
                               category == 1 ?  
                               Column(children: [
                                Container(width: 200,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child: Stack(
                                children: [ 
                                Align(alignment: Alignment.center,child:
                                Text(replyName, style: TextStyle(color: Colors.blueGrey, fontSize: 10,fontFamily: 'BrandonBI'),)),
                                Align(alignment: Alignment.centerRight,
                                child: Container(width: 20, height: 20,
                                child: FloatingActionButton(
                                backgroundColor: Color.fromARGB(200, 255, 255, 255),
                                onPressed: (){
                                  setState(() {
                                      reply = ValueNotifier<bool>(false);
                                      replyMsg = "";
                                      replyName = "";     
                                  });
                                },
                                child: Icon(Icons.close, color: Colors.blueGrey,size: 15,),
                                )))
                                ])),
                                Container(width: 200,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Image.asset("assets/sticker/" + replyMsg + ".gif", width: 30, height: 30,))])

                                : category == 2 ?
                                Column(children: [
                                Container(width: 200,alignment: Alignment.center,
                                color: Colors.blue[100],     
                                child: Stack(
                                children: [ 
                                Align(alignment: Alignment.center,child:
                                Text(replyName, style: TextStyle(color: Colors.blueGrey,fontSize: 10,fontFamily: 'BrandonBI'),)),
                                Align(alignment: Alignment.centerRight,
                                child: Container(width: 20, height: 20,
                                child: FloatingActionButton(
                                backgroundColor: Color.fromARGB(200, 255, 255, 255),
                                onPressed: (){
                                  setState(() {
                                      reply = ValueNotifier<bool>(false);
                                      replyMsg = "";
                                      replyName = "";     
                                  });
                                },
                                child: Icon(Icons.close, color: Colors.blueGrey,size: 15,),
                                )))
                                ])),
                                Container(width: 200,alignment: Alignment.center,
                                color: Colors.blue[50],     
                                child: isImage == true ?  
                                Image.network(replyMsg, width: 30, height: 30,)
                                : Text(photoname, style: TextStyle(color: Colors.blueGrey,fontSize: 10,fontFamily: 'BrandonBI')),
                                )])

                              : Column(children: [ 
                              Container(width: 200,alignment: Alignment.center,
                              color: Colors.blue[100],     
                                child: Stack(
                                children: [ 
                                Align(alignment: Alignment.center,child:
                                Text(replyName, style: TextStyle(color: Colors.blueGrey, fontSize: 10,fontFamily: 'BrandonBI'),)),
                                Align(alignment: Alignment.centerRight,
                                child: Container(width: 20, height: 20,
                                child: FloatingActionButton(
                                backgroundColor: Color.fromARGB(200, 255, 255, 255),
                                onPressed: (){
                                  setState(() {
                                      reply = ValueNotifier<bool>(false);
                                      replyMsg = "";
                                      replyName = "";     
                                  });
                                },
                                child: Icon(Icons.close, color: Colors.blueGrey,size: 15,),
                                )))
                                ])),
                              Container(width: 200,alignment: Alignment.center,
                              color: Colors.blue[50],     
                              child:                                
                              Text(replyMsg, style: TextStyle(color: Colors.blueGrey, fontSize: 15,fontFamily: 'BrandonLI'),)),
                              ],)
                            ),);

        } else {
          return Text("");
        }
        }),

        Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
//.........................................................................................................          
          IconButton(onPressed: (){
            setState(() {
              //cat = 1;
              isShowSticker == false ? isShowSticker = true : isShowSticker = false;
            });

          }, 
          icon: Icon(CupertinoIcons.smiley, color: Theme.of(context).hintColor,)),

          SizedBox(width: 5,),
// //.........................................................................................................
//           IconButton(onPressed: () async {
//             setState(() {
//               isImage = true;
//               cat = 2;
//               isShowSticker = false ;
//             });

//             getImage(true);              
//             //selectFile;

//             // final result = await FilePicker.platform.pickFiles(allowMultiple: false);
//             // if(result == null) return;

//             // setState(() {
//             //   pickfile = result.files.first;
//             // _image = File(pickfile!.path!);
//             //   photoname = pickfile!.name;
//             // });
          
            

//           }, 
//           icon: cat != 2 ? 
//           Icon(CupertinoIcons.photo, color: Colors.blueGrey,)
//           : isImage == true ? 
//           isloading == false ?         
//           ClipRRect( 
//             child: Image.file(
//               _image,
//               width: 30,
//               height: 30,
//               fit: BoxFit.fill
//               ),)
//           : CircularProgressIndicator(color: Colors.blueGrey,)
//           : Icon(CupertinoIcons.photo, color: Colors.blueGrey,)
//           ),
// //.........................................................................................................
//           SizedBox(width: 5,),

//           IconButton(onPressed: () async {
//             setState(() {
//               isImage = false;
//               cat = 2;
//               isShowSticker = false ;
//             });

//             final result = await FilePicker.platform.pickFiles(allowMultiple: false);
//             if(result == null) return;

//             setState(() {
//               pickfile = result.files.first;
//               _image = File(pickfile!.path!);
//               photoname = pickfile!.name;
//             });
                     

//           }, 
//           icon: cat != 2 ? 
//           Icon(CupertinoIcons.folder, color: Colors.blueGrey,)
//            : isImage == false ? isloading == false ?  
//           Material(
//           color: Colors.white,elevation: 10,
//           child: Text("pickfile!.name", textAlign: TextAlign.center,
//           style:  TextStyle(fontFamily: 'BrandonLI',fontSize: 10, color: Colors.blueGrey,fontWeight: FontWeight.bold)))
//           : CircularProgressIndicator(color: Colors.blueGrey,)
//           : Icon(CupertinoIcons.folder, color: Colors.blueGrey,)
//           ),
// //.........................................................................................................
          IconButton(onPressed: () async {
            setState(() {
              isShowSticker = false ;
            });
            
            Showbottomsheet(context);

          }, 
          icon: cat != 2 ? 
          Icon(FontAwesomeIcons.upload, color: Theme.of(context).hintColor)
          : isloading == false ?
          isImage == true ?          
          ClipRRect( 
            child: Image.file(
              _image,
              width: 30,
              height: 30,
              fit: BoxFit.fill
              ),)
          : Text(pickfile!.name, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI',fontSize: 10, color: Colors.blueGrey,fontWeight: FontWeight.bold))
          : CircularProgressIndicator(color: Theme.of(context).hintColor,)
          ),
//.........................................................................................................
          SizedBox(width: 5,),

              Expanded(child: 
              InkWell(child: Container(
              constraints: BoxConstraints(maxHeight: 50),
              child:
               TextFormField(
                enabled: cat == 1? true : false,
                controller: messageController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                ),
                textCapitalization: TextCapitalization.words,
                decoration:  InputDecoration(
                  hintText: cat == 1? 'Type down your message' : 'Tap here cancel media select',
                  border: UnderlineInputBorder(),
                ),
              )),
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

                  String message = messageController.text.trim();
                  messageController.clear();  

                 try{ 
                      await FirebaseFirestore.instance.collection(widget.id).add({
                        'msg': message,
                        'color': false,
                        'time': outputFormat.format(DateTime.now()),
                        'sortTime': DateTime.now().toString(),
                        'isImage': isImage,
                        'photoname': photoname,
                        'id': user!.email!,  
                        'reply': reply.value,
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


                setState(() {
                  cat = 1;
                  reply = ValueNotifier<bool>(false);
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
                  reply = ValueNotifier<bool>(false);
                  replyMsg = "";
                  replyName = "";  
                 
                  });

                }         
          },
          icon: Icon(Icons.send, color: Theme.of(context).hintColor,)),            

        ]),
        SizedBox(height: 10,)
         ]));
    
      }}))
                ],
              ),

              // Loading
              //buildLoading()
            ],
          ),
          onWillPop: onBackPress,
        ),
      ),

    );

  }

Showbottomsheet (context){
        
          showCupertinoModalPopup<void>(
              //barrierColor : Theme.of(context).scaffoldBackgroundColor,
              context: context,
              builder: (context) => Padding(padding: EdgeInsets.only(bottom: 70, left: 20, right: 20),
              child: Material(elevation: 20,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
                ),
              color: Colors.black,
              child: Container(
                decoration: BoxDecoration(              
                borderRadius: BorderRadius.circular(30.0),               
                color: Theme.of(context).scaffoldBackgroundColor,
                ),
                height: 150,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(child: 
                    IconButton(onPressed: () async {
                      Navigator.pop(context);
                    }, 
                    icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).hintColor)
                    ),),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
//.........................................................................................................
          CircleAvatar(backgroundColor: Colors.red,
          radius: 40,
          child:
          Padding(
          padding: EdgeInsets.only(bottom: 10, right: 5),
          child:
          IconButton(onPressed: () async {
            setState(() {
              isImage = true;
              cat = 2;
              isShowSticker = false ;
            });

            getImage(true);                
            Navigator.pop(context);
          }, 
          icon: 
          //cat != 2 ? 
          Icon(CupertinoIcons.photo, color: Colors.white, size: 40,)
          // : isImage == true ? 
          // isloading == false ?         
          // ClipRRect( 
          //   child: Image.file(
          //     _image,
          //     width: 30,
          //     height: 30,
          //     fit: BoxFit.fill
          //     ),)
          // : CircularProgressIndicator(color: Colors.blueGrey,)
          // : Icon(CupertinoIcons.photo, color: Colors.blueGrey,)
          ))),
//.........................................................................................................
          SizedBox(width: 5,),

          CircleAvatar(backgroundColor: Colors.blue[200],
          radius: 40,
          child:
          Padding(
          padding: EdgeInsets.only(bottom: 10, right: 5),
          child:
          IconButton(onPressed: () async {
            setState(() {
              isImage = false;
              cat = 2;
              isShowSticker = false ;
            });

            final result = await FilePicker.platform.pickFiles(allowMultiple: false);
            if(result == null) return;

            setState(() {
              pickfile = result.files.first;
              _image = File(pickfile!.path!);
              photoname = pickfile!.name;
            });
                     
            Navigator.pop(context);
          }, 
          icon: 
          //cat != 2 ? 
          Icon(CupertinoIcons.folder, color: Colors.white, size: 40,)
          //  : isImage == false ? isloading == false ?  
          // Material(
          // color: Colors.white,elevation: 10,
          // child: Text("pickfile!.name", textAlign: TextAlign.center,
          // style:  TextStyle(fontFamily: 'BrandonLI',fontSize: 10, color: Colors.blueGrey,fontWeight: FontWeight.bold)))
          // : CircularProgressIndicator(color: Colors.blueGrey,)
          // : Icon(CupertinoIcons.folder, color: Colors.blueGrey,)
          ),)),
              ],
          ),

          SizedBox(height: 10,),

          ],),

        )),));  
  }   
//.........................................................................................................

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
            border: Border(top: BorderSide(color: Colors.grey, width: 0.5)), color: Theme.of(context).scaffoldBackgroundColor ),
        padding: EdgeInsets.all(5),
        height: 180,
      ),
    );
  }

onSendMessage(String sticker) async {
                   try{ 

                      await FirebaseFirestore.instance.collection(widget.id).add({
                        'sticker': sticker,
                        'color': false,
                        'time': outputFormat.format(DateTime.now()),
                        'sortTime': DateTime.now().toString(),
                        'isImage': isImage,
                        'id': user!.email!,   
                        'reply': reply.value,
                        'replyName': replyName,
                        'replyMsg': replyMsg,  
                        'name': Globalname,                       
                        'cat': 1,
                        'photoname': photoname,
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
                        reply = ValueNotifier<bool>(false);
                        replyMsg = "";
                        replyName = "";  
                });
}

}

//global.......................................................................................................
String replyName = "";
String replyMsg = "";
int category = 0;
bool isImage = true; 
ScrollController scrollController = ScrollController();
String photoname = "";
final growableList = <String>[];


//CHAT1.........................................................................................................
// class chat1 extends StatefulWidget {
//   chat1({Key? key}) : super(key: key);

//   @override
//   _chat1State createState() => _chat1State();
// }


//class _chat1State extends State<chat1> {



// void initState(){
//   super.initState();
//   WidgetsBinding.instance?.addPostFrameCallback((_){
//   scrollController.jumpTo(scrollController.position.maxScrollExtent);
//   });
// }

  // @override
  // Widget build(BuildContext context) {





//   }
  
// }


//PhotoView for profile............................................................................................
class photoView extends StatefulWidget {

  final date;
  final url; 
  photoView({Key? key,this.date,this.url}) : super(key: key);

  @override
  photoViewState createState() => photoViewState();
}

class photoViewState extends State<photoView>{

  double? progress = null;

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
        // actions: [
        //   progress != null ? Container(width:80,padding: EdgeInsets.only(right: 20, left: 10),
        //   child: Center(child:
        //   CircularProgressIndicator(value: progress,color: Colors.blueGrey,
        //   backgroundColor: Color.fromARGB(202, 96, 125, 139),)))

        //   : IconButton(
        //     icon:  Icon(
        //       Icons.download,
        //       color: Colors.white, // Change Custom Drawer Icon Color
        //     ),
        //     onPressed: () {
        //         Permission.storage.request();
        //         Permission.accessMediaLocation;
        //         Permission.manageExternalStorage;
        //         downloadFile(widget.url, widget.date);             
        //   },),          
        // ],
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
        child: Center(child: PhotoView(
        imageProvider:
        NetworkImage(widget.url,))),
        ),
  ); 
      
  }
    // Future downloadFile(String url, String name) async {

    //    Directory tempDir = await getApplicationDocumentsDirectory();
    //    String path = '/storage/emulated/0/Download/${name}.jpeg';




    //   await Dio().download(url, path,
    //   onReceiveProgress: (received, total){
    //     double progress1 = received/ total;
    //     print(path);
    //     print(url);
    //     setState(() {
    //       //progress = progress1;
    //     });
    //   });

    // print(path);
    // OpenFile.open(path, type: "image/jpeg");

    // }

}

//PhotoView for multimedia............................................................................................
class PhotoView2 extends StatefulWidget {

  final date;
  final url; 
  final name;
  final isImage;
  PhotoView2({Key? key,this.date,this.url,this.name,this.isImage}) : super(key: key);

  @override
  PhotoView2State createState() => PhotoView2State();
}

class PhotoView2State extends State<PhotoView2>{

  double? progress = null;

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
        actions: [
          progress != null ? Container(width:80,padding: EdgeInsets.only(right: 20, left: 10),
          child: Center(child:
          CircularProgressIndicator(value: progress,color: Colors.blueGrey,
          backgroundColor: Color.fromARGB(202, 96, 125, 139),)))

          : IconButton(
            icon:  Icon(
              Icons.download,
              color: Colors.white, // Change Custom Drawer Icon Color
            ),
            onPressed: () {
                Permission.storage.request();
                Permission.accessMediaLocation;
                Permission.manageExternalStorage;
                downloadFile(widget.url, widget.name);             
          },),          
        ],
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

        
        widget.isImage == true ? PhotoView(
        imageProvider:
        NetworkImage(widget.url))
        : Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Icon(Icons.folder_open, size: 200, color: Colors.white),
        Text(widget.name, style: TextStyle(fontSize: 15,fontFamily: 'BrandonLI', color: Colors.white),)],),
        ),
        ),
  ); 
      
  }
    Future downloadFile(String url, String name) async {

       Directory tempDir = await getApplicationDocumentsDirectory();
       String path = '/storage/emulated/0/Download/${name}';




      await Dio().download(url, path,
      onReceiveProgress: (received, total){
        double progress1 = received/ total;
        //print(path);
        //print(url);
        setState(() {
          //progress = progress1;
        });
      });

   // print(path);
    OpenFile.open(path, type: "*/*");
    // } catch(e) {
    //   try{
    //   OpenFile.open(path, type: "video/mp4");
    //   } catch(e) {
    //     try{
    //     OpenFile.open(path, type: "application/pdf");
    //     } catch(e) {
    //       OpenFile.open(path, type: "*/*");
    //     }
    //   }
    // }

  }

}