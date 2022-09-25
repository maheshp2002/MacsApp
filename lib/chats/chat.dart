import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
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
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:assets_audio_player/assets_audio_player.dart';


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
  UploadTask? task;
  bool isBottomSheet = false;
  bool isPause = false;
  bool isRecorderReady = false;
  
  //recording audio
  final recordingSession = FlutterSoundRecorder();
  //create a new player
  final assetsAudioPlayer = AssetsAudioPlayer();
  //late String pathToAudio;
  bool isRecPause = false;
  bool _playAudio = false;
  Stream<RecordingDisposition>? recordingStream;
  double playbackSpeed = 1;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  ValueNotifier<bool> reply = ValueNotifier(false);
  bool isSelect = false;
  late String image;
  bool? value = false;
  User? user = FirebaseAuth.instance.currentUser;
  int cat = 1;
  bool color = true;
  bool isShowSticker = false;
  bool _show = false;
  

//.................................................................................................................

  @override
  void initState() {
    super.initState();
    handleScroll();
    chatView();
    initializer();
  }  

//initialize...........................................................................................................
  Future initializer() async {
    //pathToAudio = '/sdcard/Download/audio${DateTime.now()}.wav';
    await recordingSession.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    isRecorderReady = true;
    recordingSession.setSubscriptionDuration(const Duration(milliseconds: 500));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    directoryPath = await _directoryPath();
    completePath = await _completePath(directoryPath);
    _createDirectory();
    _createFile();
  }


  String completePath = "";
  String directoryPath = "";

  Future<String> _completePath(String directory) async {
    var fileName = _fileName();
    return "$directory$fileName";
  }

  Future<String> _directoryPath() async {
    var directory = await getExternalStorageDirectory();
    var directoryPath = directory!.path;
    return "$directoryPath/MacsApp/records/";
  }

  String _fileName() {
    return "audio${DateTime.now()}.wav";
  }

//create file.....................................................................
  Future _createFile() async {
    File(completePath)
        .create(recursive: true)
        .then((File file) async {
      //write to file
      Uint8List bytes = await file.readAsBytes();
      file.writeAsBytes(bytes);
      print("FILE CREATED AT : "+file.path);
    });
  }

//create directory.....................................................................

void _createDirectory() async {
    bool isDirectoryCreated = await Directory(directoryPath).exists();
    if (!isDirectoryCreated) {
      Directory(directoryPath).create()
          .then((Directory directory) {
        print("DIRECTORY CREATED AT : " +directory.path);
      });
    }

    bool isDownloadreated = await Directory('/sdcard/MacsApp/').exists();
    if (!isDownloadreated) {
      Directory('/sdcard/MacsApp/').create()
          .then((Directory directory) {
      });
    }
  
  }
//start record...........................................................................................................
 
  Future<void> startRecording() async {

    if(!isRecorderReady) return;

    setState(() {
      _playAudio = true;
    });

    Directory directory = Directory(path.dirname(completePath));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    recordingSession.openAudioSession();
    await recordingSession.startRecorder(
      toFile: completePath,
      codec: Codec.pcm16WAV,
    );

    StreamSubscription _recorderSubscription =
      recordingSession.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(
      e.duration.inMilliseconds,
          isUtc: true);
      var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
    });
    _recorderSubscription.cancel();

    setState(() {
      recordingStream = recordingSession.onProgress;
    });
    Showbottomsheet(context);
  }

 
//stop record...........................................................................................................
 
  Future<String?> stopRecording() async {
    
    if(!isRecorderReady) {print("null");};

    recordingSession.closeAudioSession();
    setState(() {
      _playAudio = false;
      isAudioLoading = true;
    });
    File file = File(completePath);

    String fileName = file.path.split('/').last;

    saveAudio(file, fileName);

    return await recordingSession.stopRecorder();
  }

// //Play audio preview...........................................................................................................
//   Future<void> playFunc() async {
//     recordingPlayer.open(
//       Audio.file(pathToAudio),
//       autoStart: true,
//       showNotification: true,
//     );
//   }

//Play audio network...........................................................................................................
 
  Future<void> playFuncNetwork(String url, artist, title, id) async {


    FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
    .collection(Globalid).doc(id).update({
        'isPlaying': true
    });

    assetsAudioPlayer.open(
      Audio.network(url,
          metas: Metas(
            title:  title,
            artist: artist,
            image: MetasImage.asset("assets/logo.png"),
          ),
      playSpeed: playbackSpeed,
      ),
      notificationSettings: NotificationSettings(
          nextEnabled: false,
          prevEnabled: false,
          customStopAction: (AssetsAudioPlayer) async{

          FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
          .collection(Globalid).doc(id).update({
              'isPlaying': false
          });
            assetsAudioPlayer.stop(); 
          }
      ),
      autoStart: true,
      showNotification: true,
      
    );

  }

//stop play...........................................................................................................
 
  Future<void> stopPlayFunc(String id) async {
    FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
    .collection(Globalid).doc(id).update({
        'isPlaying': false
    });
    assetsAudioPlayer.stop();
  }

// //pause play...........................................................................................................
//   pausePlayFunc() {
//     setState(() {
//       NetworkAudioPlay = false;
//     });
//     assetsAudioPlayer.pause();
//   }

//chat view.........................................................................................................
   
    chatView() async{
                        try{
                        await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                        .collection(Globalid).where('id', isNotEqualTo: user!.email!)
                        .get().then((snapshot) {

                          snapshot.docs.forEach((documentSnapshot) async {
                            String thisDocId = documentSnapshot.id;

                          try{
                            FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                            .collection(Globalid).doc(thisDocId).update({
                              'color': color,
                            });

                            FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("chat").doc("Users")
                            .collection(user!.email!).doc(thisDocId).update({
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
                          backgroundColor: Color.fromARGB(255, 248, 17, 0),  
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
    recordingSession.closeAudioSession();
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
              Reference ref = storage.ref().child(user!.email! + "/" + "chat" + "/" + user!.email! + "- chat -" + DateTime.now().toString());
              task = ref.putFile(File(_image.path));
              
              setState(() {});

              String returnURL;

              if (task == null) {print("null");};

              final snapshot = await task!.whenComplete(() => {});
              returnURL = await snapshot.ref.getDownloadURL();
              
              return returnURL;

            }

//..........................................................................................

  Future<void> saveImages(File _image) async {
    String id = ""; //for saving to other collection with same doc id
    String isChattingWith = "";

              //_image.forEach((image) async {
              String imageURL = await uploadFile(_image);
              try{
              await collectionReference.collection("Users").doc(widget.id).get()
                .then((snapshot) {
                setState(() {
                isChattingWith = snapshot.get('isChattingWith');                
              });
              });
              } catch (e){
                debugPrint("error");
              }

                  try{
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                      .collection(widget.id).add({
                        'photo': imageURL,
                        'color': isChattingWith == user!.email! ? true : false,
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
                      }).then((value) =>(

                       id = value.id

                      )).catchError((error) => debugPrint("Failed to add user: $error"));  
                     
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white); 
                                    }   
//........................................................................................................
                  try{
                      await FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("chat").doc("Users")
                      .collection(user!.email!).doc(id).set({
                        'photo': imageURL,
                        'color': isChattingWith == user!.email! ? true : false,
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
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white); 
                                    }  
//for home page.............................................................................                                         
                try {
                 FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("friends")
                 .doc(widget.id).update({
                  'msg': photoname
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }
//...............................................................................................................

                try {
                 FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("friends")
                 .doc(user!.email!).update({
                  'msg': photoname
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }

//...............................................................................................................                                                       


                                     
                setState(() {
                  cat = 1;
                  isImage = true;
                  reply = ValueNotifier<bool>(false);
                  //multiPick = false;
                }); 
                    
}

//..........................................................................................

  Future<void> saveAudio(File _audio, String fileName) async {
    String id = ""; //for saving to other collection with same doc id
    String isChattingWith = "";
               
              String audioURL = await uploadFile(_audio);

              try{
              await collectionReference.collection("Users").doc(widget.id).get()
                .then((snapshot) {
                setState(() {
                isChattingWith = snapshot.get('isChattingWith');                
              });
              });
              } catch (e){
                debugPrint("error");
              }


                  try{
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                      .collection(widget.id).add({
                        'photo': audioURL,   
                        'audioname': fileName,
                        'color': isChattingWith == user!.email! ? true : false,
                        'time': outputFormat.format(DateTime.now()),
                        'sortTime': DateTime.now().toString(),
                        'id': user!.email!,   
                        'reply': reply.value,
                        'replyName': replyName,
                        'replyMsg': replyMsg,
                        'name': Globalname, 
                        'cat1': category,      
                        'isSelected': false,  
                        'cat': 4, 
                        'isPlaying': false,
                        'isPause': false,
                        'date': dateFormat.format(DateTime.now())    
                      }).then((value) =>(

                       id = value.id

                      )).catchError((error) => debugPrint("Failed to add user: $error"));  
                     
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white); 
                                    }   
//...............................................................................................................
     

                  try{
                      await FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("chat").doc("Users")
                      .collection(user!.email!).doc(id).set({
                        'photo': audioURL,   
                        'audioname': fileName,
                        'color': isChattingWith == user!.email! ? true : false,
                        'time': outputFormat.format(DateTime.now()),
                        'sortTime': DateTime.now().toString(),
                        'id': user!.email!,   
                        'reply': reply.value,
                        'replyName': replyName,
                        'replyMsg': replyMsg,
                        'name': Globalname, 
                        'cat1': category,      
                        'isSelected': false,  
                        'cat': 4, 
                        'isPlaying': false,
                        'isPause': false,
                        'date': dateFormat.format(DateTime.now())    
                      });  
                     
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white); 
                                    }        
//for home page.............................................................................                                         
                try {
                 FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("friends")
                 .doc(widget.id).update({
                  'msg': fileName
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }
//...............................................................................................................

                try {
                 FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("friends")
                 .doc(user!.email!).update({
                  'msg': fileName
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }

//...............................................................................................................

                                                                   
                setState(() {
                  cat = 1;
                  isImage = true;
                  reply = ValueNotifier<bool>(false);
                  isAudioLoading = false; 
                }); 
                    
}
//..........................................................................................

// Image Picker
  File _image = File(''); // Used only if you need a single picture
  //bool multiPick = false; 
  //late Map<String, String> _paths;
  Map<String, String>? _paths;
  bool isloading = false;
  bool isAudioLoading = false;

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
        //multiPick = false;
      } else {
        debugPrint('No image selected.');
      }
    });
  }

 //..........................................................................................

  @override
  Widget build(BuildContext context) {

//upload widget photo...........................................................................................................

Widget buildUploadStatus(UploadTask? task) => StreamBuilder<TaskSnapshot>(
  stream: task!.snapshotEvents,
  builder: (context, snapshot){

  if (snapshot.hasData){
    final snap = snapshot.data!;
    final progress = snap.bytesTransferred / snap.totalBytes;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Stack(
          children: <Widget>[
          Center(child:
          CircularProgressIndicator(value: progress , color: Color.fromARGB(255, 0, 255, 8),
          backgroundColor: Color.fromARGB(61, 0, 255, 8),)),
          
          Center(child: Text(percentage + "%", textAlign: TextAlign.end,
          style: TextStyle(
            color: Color.fromARGB(213, 0, 255, 8),
            fontFamily: 'BrandonL',
            fontSize: 10,
          ),)),
          
          ]);

  } else {
    return Container();
  }

  }
  );


//upload widget audio...........................................................................................................

Widget buildUploadStatusAudio(UploadTask? task) => StreamBuilder<TaskSnapshot>(
  stream: task!.snapshotEvents,
  builder: (context, snapshot){

  if (snapshot.hasData){
    final snap = snapshot.data!;
    final progress = snap.bytesTransferred / snap.totalBytes;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Stack(
          children: <Widget>[
          Center(child:
          CircularProgressIndicator(value: progress , color: Color.fromARGB(255, 0, 255, 8),
          backgroundColor: Color.fromARGB(61, 0, 255, 8),)),
          
          Center(child:Padding(padding: EdgeInsets.only(top: 10, left: 7),
          child:
          Text(percentage + "%", textAlign: TextAlign.end,
          style: TextStyle(
            color: Color.fromARGB(213, 0, 255, 8),
            fontFamily: 'BrandonL',
            fontSize: 10,
          ),))),
          
          ]);

  } else {
    return Container();
  }

  }
  );
//format duration..................................................................................................
  String formatDuration(Duration? duration) {
  String hours = duration!.inHours.toString().padLeft(0, '2');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "$hours:$minutes:$seconds";
}  
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

selectedItem() async{
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text("Do you want to delete your messages?", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          
          content: Text("This will delete all the selected messages. Media will be deleted for both users..!", textAlign: TextAlign.center,
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
          
          SizedBox(width: 30,),

          Column(children: [
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor
             ),               
            child: Text('Delete for me',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () async { 
//..............................................................................................
              String imgUrl = "";
              String id = ""; //for saving to other collection with same doc id
              Navigator.of(context).pop();  
              Fluttertoast.showToast(  
              msg: 'Deleting message may take a while...!\n Media will be deleted for both users..!',  
              toastLength: Toast.LENGTH_LONG,  
              gravity: ToastGravity.BOTTOM,  
              backgroundColor: Colors.blueGrey,  
              textColor: Colors.white);  

                for (var i = 0 ; i <= growableList.length - 1 ; i++){
                  try{
                        await collectionReference.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                        .collection(widget.id).doc(growableList[i]).get()
                        .then((snapshot) {
                          setState(() {
                          imgUrl = snapshot.get('photo');
                          id = snapshot.get('id');                
                          });
                    }); 
                    if(id == user!.email!){ 
                    await FirebaseStorage.instance.refFromURL(imgUrl).delete(); 
                    }

                } catch (e){
                      debugPrint("error");
                } 

                  FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                  .collection(widget.id).doc(growableList[i]).delete();

                } 
              growableList.clear();
            // print(widget.id);                
//..............................................................................................            

            // Fluttertoast.showToast(  
            // msg: 'Deleting messages may take a while..!',  
            // toastLength: Toast.LENGTH_LONG,  
            // gravity: ToastGravity.BOTTOM,  
            // backgroundColor: Colors.blueGrey,  
            // textColor: Colors.white  
            // );  
            }, 
            ),
          
          SizedBox(height: 10,),

          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor
             ),               
            child: Text('Delete for everyone',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () async { 
//..............................................................................................
              String imgUrl = "";
              String id = ""; //for saving to other collection with same doc id
              Navigator.of(context).pop();  
              Fluttertoast.showToast(  
              msg: 'Deleting message may take a while...\n Only messages that you sent will be deleted..!',  
              toastLength: Toast.LENGTH_LONG,  
              gravity: ToastGravity.BOTTOM,  
              backgroundColor: Colors.blueGrey,  
              textColor: Colors.white);  

              for (var i = 0 ; i <= growableList.length - 1 ; i++){
                  try{
                        await collectionReference.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                        .collection(widget.id).doc(growableList[i]).get()
                        .then((snapshot) {
                          setState(() {
                          id = snapshot.get('id');           
                          imgUrl = snapshot.get('photo');     
                          });
                    });  

                  if (id == user!.email!){
                  
                  await FirebaseStorage.instance.refFromURL(imgUrl).delete(); 

                  }
                  } catch (e){
                  debugPrint("error in image");
                } 


              try{
                  await collectionReference.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                 .collection(widget.id).doc(growableList[i]).get()
                 .then((snapshot) {
                    setState(() {
                    id = snapshot.get('id');           
                    });
                 }); 

                if (id == user!.email!){ 

                  try{
                  await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                  .collection(widget.id).doc(growableList[i]).delete();
                  } catch(e){
                    debugPrint("error in deliting other side mssg");
                  }

                  try{
                  await FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("chat").doc("Users")
                  .collection(user!.email!).doc(growableList[i]).delete();
                  } catch(e){
                    debugPrint("error in deliting our side mssg");
                  }
                }

              } catch (e){
                debugPrint("error in deliting mssg no id ");
             } 


              }

//for home page.............................................................................                                         
                try {
                 FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("friends")
                 .doc(widget.id).update({
                  'msg': "This message has been deleted..!"
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }
//...............................................................................................................

                try {
                 FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("friends")
                 .doc(user!.email!).update({
                  'msg': "This message has been deleted..!"
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }

//...............................................................................................................


            growableList.clear();
//..............................................................................................            
            //Navigator.of(context).pop();  

            }, 
            ),
          ]),
        ]),
        ); 
}
ClearMessage() async{
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text("Do you want to delete all your messages?", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          
          content: Text("This will delete all the messages permenantly for you..! Media will be deleted for both users..!", textAlign: TextAlign.center,
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
              String id = ""; //for saving to other collection with same doc id
              Navigator.of(context).pop();  

                        try{
                        await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                        .collection(Globalid)
                        .get().then((snapshot) {

                          snapshot.docs.forEach((documentSnapshot) async {
                            String thisDocId = documentSnapshot.id;

                            try{
                                  await collectionReference.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                                  .collection(Globalid).doc(thisDocId).get()
                                  .then((snapshot) {
                                    setState(() {
                                    imgUrl = snapshot.get('photo');    
                                    id = snapshot.get('id');             
                                    });
                              });  
                              if (id == user!.email!){
                              await FirebaseStorage.instance.refFromURL(imgUrl).delete(); 
                              }

                          } catch (e){
                                debugPrint("error");
                          } 

                         FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                         .collection(Globalid).doc(thisDocId).delete();

                        });
                        }
                        );
                        }catch(e){
                          Fluttertoast.showToast(  
                          msg: 'error occured..!',  
                          toastLength: Toast.LENGTH_LONG,  
                          gravity: ToastGravity.BOTTOM,  
                          backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                          textColor: Colors.white  
                          );                            
                        }   

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

popFunction() {
  Navigator.of(context).pop();
  try{
  FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
    'isChattingWith': "",
  });
  } catch(e){
  debugPrint("error");
}
}

Future<bool> _onBackPressed() async{
try{
Navigator.of(context).pop();
await FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
  'isChattingWith': "",
  });
} catch(e){
  debugPrint("error");
}

return Future.value(false);

}
//..........................................................................................
    return WillPopScope(
    onWillPop: _onBackPressed,
    child:
    Scaffold(
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
              msg: 'This will clear all the message...! Media will be deleted for both users..!',  
              toastLength: Toast.LENGTH_LONG,  
              gravity: ToastGravity.BOTTOM,  
              backgroundColor: Colors.blueGrey,  
              textColor: Colors.white);        

              ClearMessage();

              } else if (item.name == "itemHideOnline") {
              
              if (showOnline == true) {
                
                FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                  'showOnline': false,
                  'isOnline': false
                });


              setState(() {
              showOnline =  false; 
              });

              } else {

                FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                  'showOnline': true,
                  'isOnline': true
                });


              setState(() {
              showOnline =  true; 
              });

              }

              }
              else if (item.name == "itemDelete") {   
             Fluttertoast.showToast(  
              msg: 'Your are going to delete selected messages...!\n Media will be deleted for both users...!',  
              toastLength: Toast.LENGTH_LONG,  
              gravity: ToastGravity.BOTTOM,  
              backgroundColor: Colors.blueGrey,  
              textColor: Colors.white);        
   

                selectedItem();
              } else {
                Navigator.of(context).pop();
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
        onPressed: () => popFunction(),
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
        builder: (context)=> photoView(url: snapshot.data['img'], date: snapshot.data['name'], about: snapshot.data["about"],))),
        child:  ClipRRect(
         borderRadius: BorderRadius.circular(100),child: 
         Image.network(snapshot.data['img'], width: 40, height: 40, fit: BoxFit.fill,
         errorBuilder: (context, error, stackTrace) => Image.network("https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e",
         width: 40, height: 40, fit: BoxFit.fill,)
        ))
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
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
      .collection(Globalid).orderBy("sortTime").snapshots(),
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
                 InkWell(
                  onLongPress: () async {
                  //if (snapshot.data.docs[index]["id"] != user!.email!){
                    if(snapshot.data.docs[index]["isSelected"] == true){
                     
                     for (var i = 0 ; i <= growableList.length - 1 ; i++){
                     await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                     .collection(widget.id).doc(growableList[i]).update({
                        'isSelected': false                
                      });  
                     }
                     setState(() {                    
                     growableList.clear();
                       
                     });

                    }  
                  //}                 
                  },                    
                  onDoubleTap: () async{ 
                 // if (snapshot.data.docs[index]["id"] != user!.email!){

                    if(snapshot.data.docs[index]["isSelected"] == true){

                     await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                     .collection(widget.id).doc(snapshot.data.docs[index].id).update({
                        'isSelected': false                
                      });  

                     setState(() {                    
                     growableList.remove(snapshot.data.docs[index].id);
                       
                     });

                    } else {

                     await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                     .collection(widget.id).doc(snapshot.data.docs[index].id).update({
                        'isSelected': true                
                      });  

                    setState(() {
                      growableList.add(snapshot.data.docs[index].id);
                     // print("###########################################################");
                      //print(growableList);
                    });                   
                    
                    }
                   // }
                  },

                  child: 
                  Container(
                    color: snapshot.data.docs[index]["isSelected"] == true ?
                   Color.fromARGB(200, 96, 125, 139) : Theme.of(context).scaffoldBackgroundColor ,
                    padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                    child: Align(
                      alignment: (snapshot.data.docs[index]["id"] != user!.email! ? Alignment.topLeft : Alignment.topRight),
                      child: Material(elevation: 7,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
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
                                Image.network(snapshot.data.docs[index]["replyMsg"], width: 30, height: 30,
                                errorBuilder: (context, error, stackTrace) => Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png",
                                width: 30, height: 30,),
                                ))])

                                : Column(children: [  
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child:                               
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Text(snapshot.data.docs[index]["photoname"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonLI'),))])
                               
                                : snapshot.data.docs[index]["cat1"] == 3 ? 
                                Column(children: [  
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child:                               
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Text(snapshot.data.docs[index]["replyMsg"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonLI'),)),
                              ],)

                                 
                                : Column(children: [
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[100],
                                child: 
                                Text(snapshot.data.docs[index]["replyName"], style: TextStyle(color: Colors.blueGrey, fontSize: 10,fontFamily: 'BrandonBI'),)),
                                Container(width: 150,alignment: Alignment.center,
                                color: Colors.blue[50],
                                child: 
                                Text(snapshot.data.docs[index]["replyMsg"], style: TextStyle(color: Colors.blueGrey,fontSize: 15,fontFamily: 'BrandonLI'),))]),

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
                        Image.network(snapshot.data.docs[index]["photo"], width: 150, height: 150,
                        errorBuilder: (context, error, stackTrace) => 
                        Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                        Icon(FontAwesomeIcons.ban, color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, size: 15),
                        Text(" This message has been deleted.", style: TextStyle(fontStyle: FontStyle.italic ,color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, fontSize: 15,fontFamily: 'BrandonLI')),
                        ])
                        //Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png",
                        //width: 150, height: 150,)
                        )
                        :  SizedBox(width: 200,
                        child:
                        Row(
                        children: [
                        Icon(Icons.file_download, color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, size: 30,),
                        SizedBox(width: 10),
                        Expanded(child:
                        Text(snapshot.data.docs[index]["photoname"], style: TextStyle(color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, fontSize: 15,fontFamily: 'BrandonLI'),))]))
                        )
                        
                        : snapshot.data.docs[index]["cat"] == 3 ? 
                        InkWell(
                        onTap: () => _messageView(snapshot.data.docs[index]["date"], snapshot.data.docs[index]["msg"]),
                        child:                          
                        Text(snapshot.data.docs[index]["msg"], style: TextStyle(color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, fontSize: 15,fontFamily: 'BrandonBI'),))

                        : InkWell(
                        onTap: () => _messageView(snapshot.data.docs[index]["date"], snapshot.data.docs[index]["audioname"]),
                        child: Row(
                        children: [   

                        IconButton(onPressed: () {
                          if (snapshot.data.docs[index]["isPlaying"] == true){
                            FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                            .collection(Globalid).doc(snapshot.data.docs[index].id).update({
                              'isPlaying': false
                            });
                            assetsAudioPlayer.pause();
                          } else {
                            playFuncNetwork(snapshot.data.docs[index]["photo"], snapshot.data.docs[index]["audioname"], snapshot.data.docs[index]["name"], snapshot.data.docs[index].id);
                          }
                        }, 
                        icon: Icon(snapshot.data.docs[index]["isPlaying"]== true ? Icons.stop : Icons.play_arrow, color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, size: 30,)),

                        snapshot.data.docs[index]["isPlaying"] == true ? IconButton(onPressed: () {
                          //if (snapshot.data.docs[index]["isPause"] == false){
                           if (isPause == false){
                            // FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                            // .collection(Globalid).doc(snapshot.data.docs[index].id).update({
                            //   'isPause': true
                            // });
                          setState(() {
                            isPause = true;
                          });

                          assetsAudioPlayer.pause();

                          } else {

                            // FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                            // .collection(Globalid).doc(snapshot.data.docs[index].id).update({
                            //   'isPause': false
                            // });

                         setState(() {
                            isPause = false;
                          });


                          assetsAudioPlayer.play();

                          }
                        }, 
                        icon: Icon(isPause == true ? Icons.play_circle_outline : Icons.pause_circle_outline, color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, size: 30,))
                        : Text(""),
                                                
                        Flexible( 
                        child: SizedBox(width: 55, height: 20,
                        child: ElevatedButton(
                        style:  ElevatedButton.styleFrom(
                        primary: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54
                        ),
                          onPressed: (){
                          if (playbackSpeed == 0.5){
                            setState(() {
                              playbackSpeed = 1;
                            });
                          } else if (playbackSpeed == 1){
                            setState(() {
                              playbackSpeed = 1.5;
                            });
                          } else if (playbackSpeed == 1.5){
                            setState(() {
                              playbackSpeed = 2;
                            });
                          } else {
                            setState(() {
                              playbackSpeed = 0.5;
                            });
                          }
                        }, child: Text(playbackSpeed.toString() + "x", style: TextStyle(color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).scaffoldBackgroundColor : Colors.white, fontSize: 10,fontFamily: 'BrandonL',),)
                        ))),
                        
                        snapshot.data.docs[index]["isPlaying"] != true ? SizedBox(width: 20) : Text(""),

                        snapshot.data.docs[index]["isPlaying"] != true ?
                        Flexible(child: 
                        Text(snapshot.data.docs[index]["audioname"], style: TextStyle(color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, fontSize: 15,fontFamily: 'BrandonBI'),))
                        
                        : Text(""),

                        snapshot.data.docs[index]["isPlaying"] == true ?

                        //Flexible(child: 
                        SizedBox(width: 150, height: 80,
                        child: Column(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        assetsAudioPlayer.builderRealtimePlayingInfos(
                            builder: (context, RealtimePlayingInfos? infos) {
                          if (infos == null) {
                            return SizedBox();
                          }

                        return Slider(
                        thumbColor: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54,
                        activeColor: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54,
                        inactiveColor: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54,
                        min: 0,
                        max: infos.duration.inSeconds.toDouble(),
                        value: infos.currentPosition.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await assetsAudioPlayer.seek(position);
                        },
                      );
                      }),
                      //),
                      Row(mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      StreamBuilder(
                        stream: assetsAudioPlayer.currentPosition,
                        builder: (context, AsyncSnapshot<Duration> asyncSnapshot) {
                            final Duration? duration = asyncSnapshot.data ?? Duration(hours: 00, minutes: 00, seconds: 00);

                            return Text(formatDuration(duration), style: TextStyle(color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54,fontSize: 10,fontFamily: 'BrandonL'),);  
                        }),

                        SizedBox(width: 20,)

                        ])

                        ]))

                      : Text("")
                         
                      ],)),
                        
                        
                        //Align(alignment: Alignment.centerRight,
                        //child:
                        SizedBox(width: 80, child:
                        Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Text(snapshot.data.docs[index]["time"], style: TextStyle(color: snapshot.data.docs[index]["id"] != user!.email! ? Theme.of(context).hintColor : Colors.black54, fontSize: 10,fontFamily: 'BrandonLI'),),
                        SizedBox(width: 5,),
                        Icon(Icons.check, color: snapshot.data.docs[index]["color"] == true ? Color.fromARGB(255, 1, 248, 9): Colors.grey[500], size: 15,)
                        ],),)//),

                        ],)
                      ),
       )))),
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
                     } else {
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
                  } else if(snapshot.data.docs[index]["cat"] == 3){
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
                  } else {
                    setState(() {                      
                        reply = ValueNotifier<bool>(true);
                        photoname = snapshot.data.docs[index]["audioname"];
                        replyMsg = snapshot.data.docs[index]["audioname"];
                        replyName = snapshot.data.docs[index]["name"];   
                        category = 4;   
                    });
                    
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
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
      .collection(widget.id).snapshots(),
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
          Icon( _playAudio == true ? CupertinoIcons.stop_circle : CupertinoIcons.mic_solid, color: Theme.of(context).hintColor,),

          ),

          SizedBox(width: 5,),

          IconButton(onPressed: (){

          }, 
          icon: //cat != 2 ? 
          Icon(FontAwesomeIcons.upload, color: Theme.of(context).hintColor,)

          ),


            Expanded(child: Container(
            constraints: BoxConstraints(maxHeight: 200),
             child:
               TextFormField(
                controller: messageController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                ),
                textCapitalization: TextCapitalization.sentences,
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: 'Type down your message',
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
                                Image.network(replyMsg, width: 30, height: 30,
                                errorBuilder: (context, error, stackTrace) => Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png",
                                width: 30, height: 30,)
                                )
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

          SizedBox(width: 1,),
//.........................................................................................................          

          isAudioLoading != true 
          ? IconButton(onPressed: () async{
            setState(() {
              isShowSticker = false;
            });

            _playAudio == true ? stopRecording() : startRecording();
           //startRecording();

          }, 
          icon: Icon( _playAudio == true ? CupertinoIcons.stop_circle : CupertinoIcons.mic_solid, color: Theme.of(context).hintColor,))
          
          : task != null ? buildUploadStatusAudio(task!) : CircularProgressIndicator(color: Colors.blueGrey,),

          SizedBox(width: 1,),

//.........................................................................................................          

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
          : Text(photoname, textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI',fontSize: 10, color: Colors.blueGrey,fontWeight: FontWeight.bold))
          : task != null ? buildUploadStatus(task!) : CircularProgressIndicator(color: Colors.blueGrey,)
          ),
          
          SizedBox(width: 1,),

//.........................................................................................................

              Expanded(child: 
              InkWell(child: Container(
              constraints: BoxConstraints(maxHeight: 50),
              child:
               TextFormField(
                enabled: isAudioLoading != true ? _playAudio != true ?  cat == 1 ? true : false : false: false,
                //  _playAudio != true || isloading != true || isAudioLoading != true 
                // ? cat == 1 ? true : false : false,
                controller: messageController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                ),
                textCapitalization: TextCapitalization.sentences,
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: isAudioLoading != true ? _playAudio != true ? cat == 1? 'Type down your message' : 'Tap here cancel media upload' : 'Tap here cancel recording' : 'Tap here cancel audio upload',
                  border: UnderlineInputBorder(),
                ),
              )),
              onTap: () async{

              try{
              await task!.cancel();
              } catch(e){
                debugPrint('$e');
              }

                if (_playAudio != true) {
                  setState(() {
                    cat = 1;
                  });

                if ( isAudioLoading == true){

                  setState(() {
                    isAudioLoading = false;
                  });
                  
                } 

                } else {

                  recordingSession.closeAudioSession();

                  setState(() {
                    _playAudio = false;
                  });
                  
                  if(!isRecorderReady) return;

                  await recordingSession.stopRecorder();

                } 
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
                  String id = ""; //for saving to other collection with same doc id
                  String isChattingWith = "";

                  try{
                  await collectionReference.collection("Users").doc(widget.id).get()
                    .then((snapshot) {
                    setState(() {
                    isChattingWith = snapshot.get('isChattingWith');                
                  });
                  });
                  } catch (e){
                    debugPrint("error");
                  }


                 try{ 
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                      .collection(widget.id).add({
                        'msg': message,
                        'color': isChattingWith == user!.email! ? true : false,
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
                      }).then((value) =>(

                       id = value.id

                      )).catchError((error) => debugPrint("Failed to add user: $error"));  
                     
                      } catch(e){
                          Fluttertoast.showToast(  
                          msg: 'An error occured..!',  
                          toastLength: Toast.LENGTH_LONG,  
                          gravity: ToastGravity.BOTTOM,  
                          backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                          textColor: Colors.white); 
                      } 
//................................................................................................................                        
                    try{   
                      await FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("chat").doc("Users")
                      .collection(user!.email!).doc(id).set({
                        'msg': message,
                        'color': isChattingWith == user!.email! ? true : false,
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
                          backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                          textColor: Colors.white); 
                      }   

//for home page.............................................................................                                         
                try {
                 FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("friends")
                 .doc(widget.id).update({
                  'msg': message
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }
//...............................................................................................................

                try {
                 FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("friends")
                 .doc(user!.email!).update({
                  'msg': message
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }

//...............................................................................................................


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

    ));

  }



//file select...........................................................................................................

Showbottomsheet (context){
        _playAudio != true ?
          showCupertinoModalPopup<void>(
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

            final result = await FilePicker.platform.pickFiles(allowMultiple: true);
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

          ),)),
              ],
          ),

          SizedBox(height: 10,),

          ],),

        )),)) 
        :     showCupertinoModalPopup<void>(
              context: context,
              builder: (context) => StatefulBuilder(
              builder: (context, state)
              { 
              return Padding(padding: EdgeInsets.only(bottom: 100, left: 20, right: 20),
              child: Material(elevation: 20,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
                ),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Container(
                decoration: BoxDecoration(              
                borderRadius: BorderRadius.circular(100.0),               
                color: Theme.of(context).scaffoldBackgroundColor,
                ),
                height: 50,
                width: 210,
                child: 

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
//.........................................................................................................

          IconButton(onPressed: () async {
            
            Navigator.pop(context);
            stopRecording();

          }, 
          icon: 
          Icon(CupertinoIcons.stop_circle, color: Theme.of(context).hintColor, size: 30,)

          ),
//.........................................................................................................
          
          SizedBox(width: 1,),


          IconButton(onPressed: () async {
            if (isRecPause == true) {
              setState(() {

                state((){

                isRecPause = false;

                });

              });

              recordingSession.resumeRecorder();
            } else  {

              setState(() {

                state((){

                isRecPause = true;

                });

              });

              recordingSession.pauseRecorder();

            }                    
          }, 
          icon: 
          //cat != 2 ? 
          Icon(isRecPause == true ?  CupertinoIcons.play_circle : CupertinoIcons.pause_circle, color: Theme.of(context).hintColor, size: 30,)

          ),

          SizedBox(width: 10,),
          StreamBuilder<RecordingDisposition>(
          stream: recordingStream,
          builder: (context, snapshot){
            if (snapshot.hasData ){
            String formatDuration(Duration duration) {
              String hours = duration.inHours.toString().padLeft(0, '2');
              String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
              String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
              return "$hours:$minutes:$seconds";
            } 
            final duration = snapshot.data!.duration;
            Duration.zero;
            return Text('${formatDuration(duration)}',
            style: TextStyle( color: Theme.of(context).hintColor, fontFamily: 'BrandonLI', fontSize: 18,));
          }
          return Container(
          height: 18,
           child: Center(child:
           AnimatedTextKit(
            animatedTexts: [
            WavyAnimatedText('Recording...',
            textStyle: TextStyle( color: Theme.of(context).hintColor, fontFamily: 'BrandonLI', fontSize: 18,),
            textAlign: TextAlign.center,
            speed: const Duration(milliseconds: 500)
            ),
            WavyAnimatedText('Recording...',
            textStyle: TextStyle( color: Theme.of(context).hintColor, fontFamily: 'BrandonLI', fontSize: 18,),
            speed: const Duration(milliseconds: 500)
            ),],
            isRepeatingAnimation: true,
            repeatForever: true,
            )));
           //Text();
          }
        ),
          //Text(_timerText, style: TextStyle( color: Theme.of(context).hintColor, fontFamily: 'BrandonLI', fontSize: 18,)),
              ],
          ),

          // SizedBox(height: 10,),

          // ],),

        )),
        );
        }));


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
  String id = ""; //for saving to other collection with same doc id
  String isChattingWith = "";

                try{
              await collectionReference.collection("Users").doc(widget.id).get()
                .then((snapshot) {
                setState(() {
                isChattingWith = snapshot.get('isChattingWith');                
              });
              });
              } catch (e){
                debugPrint("error");
              }

                   try{ 

                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                      .collection(widget.id).add({
                        'sticker': sticker,
                        'color': isChattingWith == user!.email! ? true : false,
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
                      }).then((value) =>(

                       id = value.id

                      )).catchError((error) => debugPrint("Failed to add user: $error"));  
                     
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white); 
                                    }    
//................................................................................................................
                   try{ 

                      await FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("chat").doc("Users")
                      .collection(user!.email!).doc(id).set({
                        'sticker': sticker,
                        'color': isChattingWith == user!.email! ? true : false,
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
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white); 
                                    }   
//for home page.............................................................................                                         
                try {
                 FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("friends")
                 .doc(widget.id).update({
                  'msg': sticker
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }
//...............................................................................................................

                try {
                 FirebaseFirestore.instance.collection("Users").doc(widget.id).collection("friends")
                 .doc(user!.email!).update({
                  'msg': sticker
                 });
                } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white);                   
                }

//...............................................................................................................


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
String photoname = "no media";
final growableList = <String>[];



//PhotoView for profile............................................................................................
class photoView extends StatefulWidget {

  final date;
  final url; 
  final about; 
  photoView({Key? key,this.date,this.url,this.about}) : super(key: key);

  @override
  photoViewState createState() => photoViewState();
}

class photoViewState extends State<photoView>{

  double? progress = null;

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
        title:  Column(children:[
        Text(
          widget.date,
          style: TextStyle(
            color: Colors.white,fontFamily: 'BrandonBI',
            fontSize: 18,
          ),
        ),
        Text("about: " + 
          widget.about,
          style: TextStyle(
            color: Colors.white,fontFamily: 'BrandonLI',
            fontSize: 15,
          ),
        )
        ]),
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

  double progress = 0;
  String percentage = "";

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
        actions: [
          progress != 0 ? 
          Container(padding: EdgeInsets.only(right: 20, left: 10),width: 100,
          child: Stack(
          children: <Widget>[
          Center(child:
          CircularProgressIndicator(value: progress , color: Color.fromARGB(255, 0, 255, 8),
          backgroundColor: Color.fromARGB(61, 0, 255, 8),)),
          
          Center(child: Text(percentage, textAlign: TextAlign.end,
          style: TextStyle(
            color: Color.fromARGB(213, 0, 255, 8),
            fontFamily: 'BrandonL',
            fontSize: 10,
          ),)),
          
          ]),)

          : IconButton(
            icon:  Icon(
              Icons.download,
              color: Colors.white, // Change Custom Drawer Icon Color
            ),
            onPressed: () async{
                Permission.storage.request();
                Permission.accessMediaLocation;
                Permission.manageExternalStorage;

                Directory tempDir = await getApplicationDocumentsDirectory();
                String path = '/sdcard/MacsApp/${widget.name}';

                await Dio().download(widget.url, path,
                onReceiveProgress: (received, total){
                  double progress1 = received/ total * 100;

                  setState(() {
                    progress = progress1 / 100;
                    percentage = '${progress1.floor()}%';
                  });
                });

            // print(path);
              OpenFile.open(path, type: "*/*");
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
            color: Colors.white,fontFamily: 'BrandonBI',
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

 

}