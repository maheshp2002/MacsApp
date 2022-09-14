import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
              Reference ref = storage.ref().child(user!.email! + "- profile -" + DateTime.now().toString());
              await ref.putFile(File(_image.path));
              String returnURL = await ref.getDownloadURL();
              return returnURL;
            }

//..........................................................................................

  Future<void> saveImages(File _image) async {
               
              //_image.forEach((image) async {
              String imageURL = await uploadFile(_image);


              await FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                'name': unameController.text.trim(),
                'about': aboutController.text.trim(),
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
        leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading == true ? Center(child: CircularProgressIndicator(color: Colors.blueGrey,))
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
              onPressed: () async{

              setState(() {
              isLoading = true;
              });

              deleteFile(snapshot.data['img']);

              await saveImages(_image);
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

    await collectionReference.collection("Users").doc(user!.email!).get().then((snapshot) {
    image = snapshot.get('img');
     });    

    final response = await http.get(Uri.parse(image));

    final documentDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      
    _image = File(join(documentDirectory.path, 'defaultProfile.png'));

    _image.writeAsBytesSync(response.bodyBytes);
    });

    return _image;
  }
}