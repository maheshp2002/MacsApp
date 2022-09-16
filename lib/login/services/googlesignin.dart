import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:macsapp/homepage/homeScreen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? user;

  Future<User?>  signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        user = userCredential.user;
      
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
    return user;
  }

  Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}


//add details.................................................................................................

class Userdetails extends StatefulWidget {
  Userdetails({Key? key}) : super(key: key);

  @override
  _UserdetailsState createState() => _UserdetailsState();
}

class _UserdetailsState extends State<Userdetails> {
  TextEditingController unameController =  TextEditingController();
  TextEditingController aboutController =  TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  
//..........................................................................................
Future<String> uploadFile(_image) async {

              FirebaseStorage storage = FirebaseStorage.instance;
              Reference ref = storage.ref().child(user!.email! + "- profile -" + DateTime.now().toString());
              await ref.putFile(File(_image.path));
              String returnURL = await ref.getDownloadURL();
              return returnURL;
            }

//..........................................................................................

  Future<void> saveImages(File _image) async {
               
              //_image.forEach((image) async {
              String imageURL = await uploadFile(_image);


              await FirebaseFirestore.instance.collection("Users").doc(user!.email!).set({
                'name': unameController.text.trim(),
                'about': aboutController.text.trim(),
                'img': imageURL,
                'email': user!.email!,
                'pushToken': "",
                'showOnline': true,
                'isOnline': true,
              });   
              
              setState(() {
                showOnline = true;
              });
}
//..........................................................................................

// Image Picker
  File _image = File(''); // Used only if you need a single picture
  late bool? Validation;
  bool isloading = false;
  final collectionReference = FirebaseFirestore.instance;

  @override
  void initState(){
    super.initState();
    fileFromImageUrl();
  }
  
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {      
    Validation = prefs.getBool('validation');
    });
    } catch(e){
    setState(() {      
    Validation = false;
    });
    }

  }
  
  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if(gallery) {
      pickedFile = (await picker.getImage(
          source: ImageSource.gallery,))!;
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

//........................................................................................


  @override
  Widget build(BuildContext context) {
  return Validation == true ? homeScreen()
   : Scaffold(
      backgroundColor: isloading == true ? Colors.black : Colors.white,
      body: isloading == true ? Center(child: Image.asset("assets/loading/loading2.gif"))
      : Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [

//..........................................................................................
SizedBox(height: 10,),
      Column(
        children:[
              Center(child: 
              GestureDetector(
              onTap: () {                
                getImage(true);
              },
              child: Container(
                //radius: 55,
              height: 150.0,
                width: 150.0,
                color: Colors.grey[200],
                child: _image != null
                    ? ClipRRect(
                        //borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          _image,
                          width: 150,
                          height: 150,
                          fit: BoxFit.fill
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(50)),
                        width: 100,
                        height: 100,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            
            )),
            SizedBox(height: 10,),

            Text("Tap this image to change profile pic...!", style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey, fontSize: 10),)
      ]),


//gap btw borders
            const SizedBox(
              height: 16,
            ),


              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
               child:
               TextFormField(
                controller: unameController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                ),
                textCapitalization: TextCapitalization.words,
                decoration:  InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: UnderlineInputBorder(),
                ),
              ),
              ), 

              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
               child:
               TextFormField(
                controller: aboutController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                ),
                textCapitalization: TextCapitalization.words,
                decoration:  InputDecoration(
                  hintText: 'About',
                  prefixIcon: Icon(Icons.border_color),
                  border: UnderlineInputBorder(),
                ),
              ),
              ),     
              
              ElevatedButton(
              style: ElevatedButton.styleFrom(
              primary: Colors.blueGrey
             ),
              onPressed: () async{
              String imgUrl = "";

              setState(() {
              isloading = true;
              });

              try{
                    await collectionReference.collection("Users").doc(user!.email!).get()
                    .then((snapshot) {
                      setState(() {
                      imgUrl = snapshot.get('img');                
                      });
                });  

              deleteFile(imgUrl);
            
            } catch (e){
                  debugPrint("error");
            } 

              
              await saveImages(_image);

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('validation', true);                

              setState(() {
              isloading = false;
              }); 

              Navigator.push(context, 
              MaterialPageRoute(builder: (BuildContext context) => homeScreen(),));               

              },
              child: Text("Enter", style: TextStyle(fontFamily: 'BrandonLI', color: Colors.white),)
              )

      ],),
    );
  }
  Future<void> deleteFile(String url) async {
  try {
    await FirebaseStorage.instance.refFromURL(url).delete();
  } catch (e) {
    print("Error deleting db from cloud: $e");
  }
}
Future<File> fileFromImageUrl() async {
    final response = await http.get(Uri.parse('https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e'));

    final documentDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      
    _image = File(join(documentDirectory.path, 'defaultProfile.png'));

    _image.writeAsBytesSync(response.bodyBytes);
    });

    return _image;
  }

}


    // await FirebaseFirestore.instance.collection("Users").doc(user!.email!).set({
      
    // });