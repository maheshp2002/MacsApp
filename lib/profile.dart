import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:macsapp/homepage/homeScreen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


class UpdateProfile extends StatefulWidget {
  UpdateProfile({Key? key}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController unameController =  TextEditingController();
  TextEditingController aboutController =  TextEditingController();
  final collectionReference = FirebaseFirestore.instance;

  late String image;

  User? user = FirebaseAuth.instance.currentUser;

//..........................................................................................
Future<String> uploadFile(_image) async {

              FirebaseStorage storage = FirebaseStorage.instance;
              Reference ref = storage.ref().child(user!.email! + "/" + "profile" + "/" + user!.email! + "- profile -" + DateTime.now().toString());
              await ref.putFile(File(_image.path));
              String returnURL = await ref.getDownloadURL();
              return returnURL;
            }

//..........................................................................................

  Future<void> saveImages(File _image, String uname, String about) async {
               
              //_image.forEach((image) async {
              String imageURL = await uploadFile(_image);


              await FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                'name': uname,
                'about': about,
                'img': imageURL
              });                
}
//..........................................................................................

// Image Picker
  File _image = File(""); // Used only if you need a single picture
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    fileFromImageUrl();

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isLoading == true ? Color(0xFF1f212d) : Colors.blueGrey,
        centerTitle: true,
        title: Text("Profile", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Colors.white70)),
        leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: isLoading == true ? Color(0xFF1f212d) : Theme.of(context).scaffoldBackgroundColor,
      body: isLoading == true ? Center(child: Image.asset("assets/loading/loading1.gif"))
      : StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {   
        return  Center(child: 
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          //Image.asset("assets/nothing.gif"),
          const Text("Noting is here!", style: TextStyle(color: Colors.grey, fontSize: 20, fontFamily: 'BrandonLI') )
          ],));
        }

      else{
        
      
      return Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [

//..........................................................................................
SizedBox(height: 10,),

      Column(children: [  
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
                child: _image != File("")
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
                        child: Image.network(
                          snapshot.data['img'],
                          width: 100,
                          height: 100,
                        ),
                      ),
              ),
            
            )),
            Text("Tap this image to change profile pic...!", style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor, fontSize: 10),)
      ]),

//gap btw borders
            const SizedBox(
              height: 16,
            ),


              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
               child:
               TextFormField(
                cursorColor: Theme.of(context).hintColor,
                controller: unameController,
                keyboardType: TextInputType.text,
                style:  TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonBI'
                ),
                textCapitalization: TextCapitalization.words,
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: snapshot.data['name'],
                  prefixIcon: Icon(Icons.person),
                  border: UnderlineInputBorder(),
                ),
              ),
              ), 

              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
               child:
               TextFormField(
                cursorColor: Theme.of(context).hintColor,
                controller: aboutController,
                keyboardType: TextInputType.text,
                style:  TextStyle(
                  color: Theme.of(context).hintColor,                
                  fontSize: 16,
                  fontFamily: 'BrandonBI'
                ),
                textCapitalization: TextCapitalization.words,
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: snapshot.data['about'],
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
              
              String uname;
              String about;
              setState(() {
              isLoading = true;
              });
              if (unameController.text.trim().isEmpty)
              {
                uname = snapshot.data['name'];
              } else {
                uname = unameController.text.trim();
              }

              if (aboutController.text.trim().isEmpty)
              {
                about = snapshot.data['name'];
              } else {
                about = aboutController.text.trim();
              }

              try{
              deleteFile(snapshot.data['img']);
              } catch (e){
                debugPrint("error");
              }

              await saveImages(_image, uname, about);
              unameController.clear();
              aboutController.clear();

              setState(() {
              isLoading = false;
              });

              },
              child: Text("Update", style: TextStyle(fontFamily: 'BrandonBI', color: Colors.white),)
              )

      ],);
      }}),
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

    try{
    await collectionReference.collection("Users").doc(user!.email!).get().then((snapshot) {
    image = snapshot.get('img');
     });    
    } catch(e){
      image = 'https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e';
    }
    
    if ( image == "")
    {
     image = 'https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e';
    }

    final response = await http.get(Uri.parse(image));

    final documentDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      
    _image = File(join(documentDirectory.path, 'defaultProfile.png'));

    _image.writeAsBytesSync(response.bodyBytes);
    });

    return _image;
  }
}