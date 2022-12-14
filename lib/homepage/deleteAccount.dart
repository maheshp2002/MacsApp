import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macsapp/login/services/googlesignin.dart';
import 'package:macsapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class deleteAccount extends StatefulWidget {
  final email;
  final name;
  deleteAccount({Key? key,this.email,this.name}) : super(key: key);
  @override
  _deleteAccountState createState() => _deleteAccountState();
}

class _deleteAccountState extends State<deleteAccount> {
  bool isDelete = false;
  bool isMail = false;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
            icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).hintColor, // Change Custom Drawer Icon Color
                  ),
            onPressed: () => Navigator.of(context).pop(),
            ),
            title:  Text(
              "Delete account",
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontFamily: 'BrandonBI',
                fontSize: 18,
              ),
            ),
            elevation: 5.0,
            centerTitle: true,
      ),
      body: 
        ListView(
        children: [

        SizedBox(height: 20,),

       // Flexible(child: 
        Container(
        width: 300,
        height: 300,
        child: Image.asset("assets/delete.png", width: 300, height: 300,)
        //)
        ),
        
        SizedBox(height: 20,),

        Text(
              " Hey ${widget.name}..!\nDo you want to delete your account ?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontFamily: 'BrandonBI',
                fontSize: 20,
              ),
            ),
              SizedBox(height: 22,),

              Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: Text(
              "- This will delete your account and all the medias and chats permenantly.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontFamily: 'BrandonLI',
                fontSize: 15,
              ),
            )),
        
                      Padding(padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Text(
              "- If you are unable to delete your account, please send us a mail.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontFamily: 'BrandonLI',
                fontSize: 15,
              ),
            )),

        Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
        //Flexible(child: 
        ElevatedButton(onPressed: () async{
          setState(() {
            isDelete = true;
          });
          
          delete();
          
          Future.delayed(const Duration(seconds: 5), () async{
          
          setState(() {
            isDelete = false;
          });
          
          });

        },
        style:  ElevatedButton.styleFrom(   
        primary: isDelete == true ? Color.fromARGB(255, 252, 17, 1) : Colors.blueGrey
        ),
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center,
        children: [
        Text(
              "Delete",
              style: TextStyle(
                color: Colors.white60,
                fontFamily: 'BrandonLI',
                fontSize: 20,
              ),
            ),

        SizedBox(width: 5,),

        Icon(FontAwesomeIcons.trashCan, color:Colors.white60, size: 15),

        ])),//),

        SizedBox(width: 20,),

        //Flexible(child: 
        ElevatedButton(onPressed: () async{
          setState(() {
            isMail = true;
          });
          
          _sendingMails();

          Future.delayed(const Duration(seconds: 5), () async{
          
          setState(() {
            isMail = false;
          });
          
          });

        },
        style:  ElevatedButton.styleFrom(   
        primary: isMail == true ? Color.fromARGB(255, 252, 17, 1) : Colors.orange
        ),
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center,
        children: [
        Text(
              "Send mail",
              style: TextStyle(
                color: Colors.white60,
                fontFamily: 'BrandonLI',
                fontSize: 20,
              ),
            ),

        SizedBox(width: 5,),

        Icon(FontAwesomeIcons.paperPlane, color:Colors.white60, size: 15),

        ]))//),
        ]),

        ]),
      );
  }
  
  //delete......................................................................................................
   delete()  async{ 
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor ,
          title:  Text("Are you sure about this?", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          actions: <Widget>[
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor 
             ),               
            child:  Text('No',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () {  
              setState(() {
                isDelete = false;
              });
              Navigator.of(context).pop();  
            },  
          ),  
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor 
             ),               
            child:  Text('Yes',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () async { 
            //try{
            setState(() {
              isDelete = true;
            });

  

          //   try{

          //    await FirebaseFirestore.instance.collection("Users").doc(widget.email).delete();

          //   } catch(e){

          //     debugPrint(e.toString());

          //   }  

          //   try{

          //     await FirebaseStorage.instance.ref( widget.email + "/"  + "profile/")
          //         .listAll().then((value) {
          //     FirebaseStorage.instance.ref(value.items.first.fullPath).delete();
          //     });

              
          //     }  catch(e){

          //     debugPrint(e.toString()); 

          //   } 

          //   try{

          //     await FirebaseStorage.instance.ref( widget.email + "/"  + "chat/")
          //       .listAll().then((value) {
          //     FirebaseStorage.instance.ref(value.items.first.fullPath).delete();
          //     });

          //   }  catch(e){

          //     debugPrint(e.toString());

          //   } 

          //   FirebaseService service = new FirebaseService();
          //   await service.signOutFromGoogle();

          //   SharedPreferences prefs = await SharedPreferences.getInstance();
          //   await prefs.setBool('validation', false); 
          //   await  prefs.setBool('isDark', false);   

          //   RestartWidget.restartApp(context);

          //   Navigator.of(context).pop();  
          //   Fluttertoast.showToast(  
          //   msg: 'Account deleted..!',  
          //   toastLength: Toast.LENGTH_LONG,  
          //   gravity: ToastGravity.BOTTOM,  
          //   backgroundColor: Colors.blueGrey,  
          //   textColor: Colors.white  
          //   );  

          //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyApp()));
            
          // } catch(e){

          //     debugPrint(e.toString());
          //     Navigator.of(context).pop();  
          //     Fluttertoast.showToast(  
          //     msg: 'Unable to delete your account..!',  
          //     toastLength: Toast.LENGTH_LONG,  
          //     gravity: ToastGravity.BOTTOM,  
          //     backgroundColor: Color.fromARGB(255, 253, 17, 0),  
          //     textColor: Colors.white  
          //     );  

          // }  

              Navigator.of(context).pop();  
              Fluttertoast.showToast(  
              msg: 'This is under maintenance..!',  
              toastLength: Toast.LENGTH_LONG,  
              gravity: ToastGravity.BOTTOM,  
              backgroundColor: Color.fromARGB(255, 253, 17, 0),  
              textColor: Colors.white  
              ); 
            }, 
            ),

          ],
        ));
  } 

_sendingMails()  {
String encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
final Uri emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'brokencodetech@gmail.com',
  query: encodeQueryParameters(<String, String>{
    'subject': 'Delete account',
    'body' : 'Email-id: ${widget.email} \nUsername: ${widget.name}' 
  }),
);

launchUrl(emailLaunchUri);
}
}