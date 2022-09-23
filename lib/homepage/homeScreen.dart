import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestore_search/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:macsapp/chats/chat.dart';
import 'package:macsapp/chats/videoCall.dart';
import 'package:macsapp/login/services/googlesignin.dart';
import 'package:macsapp/main.dart';
import 'package:macsapp/profile.dart';
import 'package:macsapp/request/request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class homeScreen extends StatefulWidget {

  @override
  homeScreenState createState() => homeScreenState();
}

late bool? isDark;
bool? showOnline;

class homeScreenState extends State<homeScreen> with WidgetsBindingObserver {
  User? user = FirebaseAuth.instance.currentUser;
  final collectionReference = FirebaseFirestore.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

   Future.delayed(const Duration(milliseconds: 10), () async{

   SharedPreferences prefs = await SharedPreferences.getInstance(); 

   setState(() {
   isDark = prefs.getBool('isDark');
   });

  await FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
       'isOnline': true,
       });

   });
  WidgetsBinding.instance!.addObserver(this);
  registerNotification();
  configLocalNotification();

  }  

//Notification...............................................................................................................

 void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('onMessage: $message');
      if (message.notification != null) {
        showNotification(message.notification!);
      }

      return;
    });

    
    firebaseMessaging.getToken().then((token) {
      debugPrint('push token: $token');
      if (token != null) {
        FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({     
        'pushToken': token
        }); 
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

  }

//Notification...............................................................................................................

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.macsapp.macsapp',
      'Flutter chat demo',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    debugPrint(remoteNotification.toString());

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }
//.....................................................................................................................

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
super.didChangeAppLifecycleState(state);

final isBg = state == AppLifecycleState.paused;
final isClosed = state == AppLifecycleState.detached;
final isScreen = state == AppLifecycleState.resumed;

isBg || isScreen == false || isClosed == true
    ?  CheckOnline(false)

    :  CheckOnline(true);
     // print("################################################");
}


CheckOnline(bool? isOnline) async{
if (isOnline == true){
  try{
    FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
          'isOnline': true,
          });
  } catch(e){
    debugPrint(e.toString());
  }
} else {
  try{
    FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
          'isOnline': false,
          'isChattingWith': "",
          });
  } catch(e){
    debugPrint(e.toString());
  }


}
// print(isOnline);
//  print("################################################");
}

  @override
  Widget build(BuildContext context) {

  return Scaffold(
  floatingActionButton: StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (!snapshot.hasData) {   
        return  FloatingActionButton(
        backgroundColor: Colors.blueGrey, onPressed: () {  },);
        }

        else{
        return FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {          
                        Globalname = snapshot.data['name'];
                        Globalabout = snapshot.data['about'];
                        Globalimg = snapshot.data['img'];
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => 
                        UsersList(name: snapshot.data['name'], about: snapshot.data['about'],
                        img: snapshot.data['img'],)));
    },
    child: Icon(Icons.add, color: Colors.white,size: 30,),
    );
  }}),

  drawer: NavDrawer(),
  appBar: AppBar(
      actions: [
        IconButton(onPressed: () async{

          SharedPreferences prefs = await SharedPreferences.getInstance();   
          
          // print("###################################################");

          if (isDark == false){
          await prefs.setBool('isDark', true);  
          MyApp.of(context).changeTheme(ThemeMode.dark);     
          setState(() {
            isDark = true;
          });      
          } else {
          await prefs.setBool('isDark', false);  
          MyApp.of(context).changeTheme(ThemeMode.light);  
          setState(() {
            isDark = false;
          });  
          }
          


        }, icon: isDark == true ? Icon(Icons.dark_mode,) : Icon(Icons.light_mode,)
        )
      ],
        backgroundColor: Colors.blueGrey,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon:  Icon(
                Icons.menu,
                color: Colors.white24, // Change Custom Drawer Icon Color
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              );}),
        title:  Text(
          "MacsApp",
          style: TextStyle(
            color: Colors.white60,fontFamily: 'BrandonBI',
            fontSize: 18,
          ),
        ),
        elevation: 5.0,
        centerTitle: true,
  ),
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
	body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("friends")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {   
        return  Center(child: 
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          //Image.asset("assets/nothing.gif"),
          Text("Noting is here!", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 20, fontFamily: 'BrandonLI') )
          ],));
        }

        else if (snapshot.hasData) {
           return ListView(
           children: [
          
            ListView.builder(
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,        
                  itemBuilder: (BuildContext context, int index) {

                    return 
                    Card(elevation: 15,
                    
                    child: InkWell(
                      onLongPress: () async{

                        _removefriend(snapshot.data.docs[index].id, snapshot.data.docs[index]['id']);
                      },
                      onTap: () async{
                        bool isOnline = false;
                        await collectionReference.collection("Users").doc(snapshot.data.docs[index]['email']).get()
                        .then((snapshot) {
                          setState(() {
                          Globalname = snapshot.get('name');  
                          isOnline = snapshot.get('isOnline');              
                          });
                        });

                        setState(() {
                        Globalmail = snapshot.data.docs[index]['email'];
                        Globalid = snapshot.data.docs[index]['id'];
                        });

                        FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                              'isChattingWith': snapshot.data.docs[index]['id'],
                      });

                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => 
                        chat(id: snapshot.data.docs[index]['id'], online: isOnline,)));
                       //print("###############################################################################");
                       //print(snapshot.data.docs[index]['id']);
                      },                       
                    child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("Users").doc(snapshot.data.docs[index]['email'])
                    .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
                    if (!snapshot.hasData) {   
                    return 
                    ListTile(
                      title: Text('name',style: const TextStyle(fontFamily: 'BrandonLI',
                          color: Colors.blueGrey,
                          fontSize: 20,
                        ),),
                      subtitle: Text('about',style: const TextStyle(fontFamily: 'BrandonLI',
                          color: Colors.blueGrey,
                          fontSize: 15,
                        ),),                       
                      leading: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> photoView(url: snapshot.data['img'], date: snapshot.data['name']))),
                      child:  

                      ClipRRect(
                      borderRadius: BorderRadius.circular(100),child: 
                      Image.network('https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e',
                       width: 50, height: 50, fit: BoxFit.fill,))),

                      );                      
                    } else {   
                    return 
                    ListTile(
                      title: Text(snapshot.data['name'],style:  TextStyle(fontFamily: 'BrandonLI',
                          color: Theme.of(context).hintColor,
                          fontSize: 20,
                        ),),
                      subtitle: Text(snapshot.data['about'],style:  TextStyle(fontFamily: 'BrandonLI',
                          color: Theme.of(context).hintColor,
                          fontSize: 15,
                        ),),  
                     trailing: snapshot.data['showOnline'] == true ?
                     Text(snapshot.data['isOnline'] == true ? "online" : "offline", 
                     style:  TextStyle(fontFamily: 'BrandonLI',
                          color: snapshot.data['isOnline'] == true ? Color.fromARGB(255, 4, 255, 12) : Colors.grey,
                          fontSize: 15,
                        ),) : Text(""),  

                      leading: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> photoView(url: snapshot.data['img'], date: snapshot.data['name']))),
                      child:  

                      ClipRRect(
                      borderRadius: BorderRadius.circular(100),child: 
                      Image.network(snapshot.data['img'], width: 50, height: 50, fit: BoxFit.fill,))),

                      );
                  }}),
                    ));
              }),
              
              ]);       
          } else {   
        return  Center(child: 
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          //Image.asset("assets/nothing.gif"),
          Text("Noting is here!", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 20, fontFamily: 'BrandonLI') )
          ],));
        }
          
          })

  );
  }

//remove friend......................................................................................................
   _removefriend (String docid, String dltDocid)  async{ 
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor ,
          title:  Text("Do you want to remove this friend?", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          actions: <Widget>[
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor 
             ),               
            child:  Text('Cancel',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          ),  
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor 
             ),            
            child:  Text('Remove',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () async { 
              String imgUrl = "";
                        try{
                        await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                        .collection(dltDocid)
                        .get().then((snapshot) {

                          snapshot.docs.forEach((documentSnapshot) async {
                            String thisDocId = documentSnapshot.id;

                            try{
                                  await collectionReference.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                                  .collection(dltDocid).doc(thisDocId).get()
                                  .then((snapshot) {
                                    setState(() {
                                    imgUrl = snapshot.get('photo');                
                                    });
                              });  
                              await FirebaseStorage.instance.refFromURL(imgUrl).delete(); 

                          } catch (e){
                                debugPrint("error");
                          } 

                         FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("chat").doc("Users")
                         .collection(dltDocid).doc(thisDocId).delete();

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
            await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("friends")
            .doc(docid).delete();
            Navigator.of(context).pop();  
            Fluttertoast.showToast(  
            msg: 'Friend removed!',  
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
}


//navbar.......................................................................................................................
class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  
  User? user = FirebaseAuth.instance.currentUser;
//launch help......................................................................................................
launchURL() async{

  var url = Uri.parse("https://brokencodetech.github.io/");
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
            Fluttertoast.showToast(  
            msg: 'Could not launch website',  
            toastLength: Toast.LENGTH_LONG,  
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.blueGrey,  
            textColor: Colors.white  
            ); 
  }

}
//.................................................................................................................. 
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'MacsApp',
              style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'BrandonBI'),
            ),
            decoration: BoxDecoration(
                color: Colors.blueGrey,
                //Color(0xFF3EB16F),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/login/login2.gif"))),
          ),
          ListTile(
            leading: Icon(Icons.verified_user, color: Theme.of(context).hintColor),
            title: Text('Profile', style: TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor)),
            
            onTap: () async{
              
               Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => UpdateProfile()));},
          ),
          StreamBuilder(
                stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {   
                  return ListTile(
                    leading: Icon(Icons.person_add, color: Theme.of(context).hintColor),
                    title: Text('Requests', style: TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor)),
                    
                    onTap: () async{},
                  );
                  }

                else{
                  return ListTile(
                    leading: Icon(Icons.person_add, color: Theme.of(context).hintColor),
                    title: Text('Requests', style: TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor)),                   
                    onTap: () async{
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => 
                    Requests(name: snapshot.data['name'], about: snapshot.data['about'],
                    img: snapshot.data['img'],)));
              },
              );
            }}), 
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData) {   
                return ListTile(
                  leading: Icon(FontAwesomeIcons.video, color: Theme.of(context).hintColor),
                  title: Text('Video call', style: TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor)),
                    
                  onTap: () async{},
                );
            }
            else{
            return ListTile(
            leading: Icon(FontAwesomeIcons.video, color: Theme.of(context).hintColor, size: 20),
            title: Text('Video call', style: TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor)),
            
            onTap: () async{
              
               Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => VideoCall(username: snapshot.data['name'],)));},
          );
          }}),         
          ListTile(
            leading: Icon(Icons.border_color, color: Theme.of(context).hintColor),
            title: Text('About', style: TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor)),
            onTap: () => {
              launchURL()
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Theme.of(context).hintColor),
            title: Text('Logout', style: TextStyle(fontFamily: 'BrandonBI', color: Theme.of(context).hintColor)),
            onTap: () async{ 
              await _logout();
              
           },
          ),
        ],
      ),
    );
  }
  //logout......................................................................................................
   _logout()  async{ 
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor ,
          title:  Text("Do you want to logout?", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          actions: <Widget>[
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor 
             ),               
            child:  Text('Cancel',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          ),  
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor 
             ),               
            child:  Text('Logout',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () async { 

            FirebaseService service = new FirebaseService();
            await service.signOutFromGoogle();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('validation', false); 
            await  prefs.setBool('isDark', false);   

            try{
              FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                    'isOnline': false,
                    });
            } catch(e){
              debugPrint(e.toString());
            }   

            RestartWidget.restartApp(context);

            Navigator.of(context).pop();  
            Fluttertoast.showToast(  
            msg: 'Signed out!',  
            toastLength: Toast.LENGTH_LONG,  
            gravity: ToastGravity.BOTTOM,  
            backgroundColor: Colors.blueGrey,  
            textColor: Colors.white  
            );  

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyApp()));

            }, 
            ),

          ],
        ));
  } 
}  

String Globalname = " ";
String Globalabout = " ";
String Globalimg = " ";
String Globalid = " ";
String Globalmail= " ";

//Users list............................................................................................
class UsersList extends StatefulWidget {

  final name;
  final about; 
  final img; 
  UsersList({Key? key,this.name,this.about,this.img}) : super(key: key);

  @override
  UsersListState createState() => UsersListState();
}

class UsersListState extends State<UsersList>{

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor ,
        actions: [
          new IconButton(
          icon: new Icon(Icons.search, color: Colors.grey,),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchFeed()),
            );
          },
        ),

        ],       
        leading: IconButton(
              icon:  Icon(
                Icons.arrow_back,
                color: Colors.grey, // Change Custom Drawer Icon Color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },),
        title:  Text(
          "Friends",
          style: TextStyle(
            color: Colors.grey,fontFamily: 'BrandonBI',
            fontSize: 18,
          ),
        ),
        elevation: 5.0,
        centerTitle: true,
      ),      

      body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").where('email', isNotEqualTo: user!.email!).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
         if (!snapshot.hasData) {   
        return  Center(child: 
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          //Image.asset("assets/nothing.gif"),
          const Text("Noting is here!", style: TextStyle(color: Colors.grey, fontSize: 20, fontFamily: 'BrandonLI') )
          ],));
        }

        else if (snapshot.hasData) {
           return ListView(
           children: [
          
            ListView.builder(
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,        
                  itemBuilder: (BuildContext context, int index) {

                    return  
                    Card(elevation: 15,
                    child:
                    ListTile(
                      title: Text(snapshot.data.docs[index]['name'],style:  TextStyle(fontFamily: 'BrandonLI',
                          color: Theme.of(context).hintColor,
                          fontSize: 20,
                        ),),
                      subtitle: Text(snapshot.data.docs[index]['about'],style:  TextStyle(fontFamily: 'BrandonLI',
                          color: Theme.of(context).hintColor,
                          fontSize: 15,
                        ),),
                      leading: InkWell(
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),child: 
                      Image.network(snapshot.data.docs[index]['img'], width: 50, height: 50, fit: BoxFit.fill,),),
                      onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> photoView(url: snapshot.data.docs[index]['img'], date: snapshot.data.docs[index]['name'])));                        
                      },
                      ),
                      trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey
                      ),
                      child: Text("Add", style: const TextStyle(fontFamily: 'BrandonBI',
                          color: Colors.white,
                          fontSize: 15,
                        ),),
                      onPressed: () async{
                      try{
                      await FirebaseFirestore.instance.collection("Users").doc(snapshot.data.docs[index]['email']).collection(snapshot.data.docs[index]['email'] + "request").doc(user!.email!).set({
                        'Requestname': widget.name,
                        'Requestabout': widget.about,
                        'Requestimg': widget.img,
                        'Requestemail': user!.email!,

                        'Username': snapshot.data.docs[index]['name'],
                        'Userabout': snapshot.data.docs[index]['about'],
                        'Userimg': snapshot.data.docs[index]['img'],
                        'Useremail': snapshot.data.docs[index]['email'],                        
                      });  
                                    Fluttertoast.showToast(  
                                    msg: 'Friend request sent!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white  
                                );                        
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white  
                                );      
                      }                                                                                      
                      }),
            ));
              })]);           
        } else {
            return Container(color: Theme.of(context).scaffoldBackgroundColor,
            child: 
            Center(
              child:  Text('Nothing is here..!', style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor),),
            ));
          }
      })
    );

  }
}


//search.................................................................................................................

class DataModel {
  final String name;
  final String about;
  final String img;
  final String email;
  final String docid;


  DataModel({required this.name, required this.about, required this.img, required this.email, required this.docid});

  //Create a method to convert QuerySnapshot from Cloud Firestore to a list of objects of this DataModel
  //This function in essential to the working of FirestoreSearchScaffold

  List<DataModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;

      return DataModel(
          name: dataMap['name'],
          about: dataMap['about'],
          img: dataMap['img'],
          email: dataMap['email'],
          docid: snapshot.id
      );
    }).toList();
  }
}



class SearchFeed extends StatefulWidget {

  @override
  _SearchFeedState createState() => _SearchFeedState();
}

class _SearchFeedState extends State<SearchFeed> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FirestoreSearchScaffold(
      appBarBackgroundColor: Colors.blueGrey,
      
      searchBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      searchTextColor: Theme.of(context).hintColor,
      clearSearchButtonColor: Theme.of(context).hintColor,
      searchTextHintColor: Theme.of(context).hintColor,
      searchIconColor: Theme.of(context).hintColor,

      appBarTitle: "Search",
      firestoreCollectionName: "Users",
      searchBy: 'name',
      scaffoldBody: Container(color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
        child: Text("Search for friends..!", style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor),)),
      ),

      dataListFromSnapshot: DataModel(docid: '', email: '', img: '', about: '', name: '').dataListFromSnapshot,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DataModel> dataList = snapshot.data;
          if (dataList.isEmpty) {
            return Container(color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Text('No Results Returned..!', style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor),),
            ));
          }
          return Container(color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final DataModel data = dataList[index];

                return 
                 Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(color: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 15,
                    child: ListTile(
                      leading: InkWell(
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child:
                       Image.network(
                        '${data.img}',
                        width: 55,
                        height: 80,
                        fit: BoxFit.fill,
                      )),
                      onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> photoView(url: data.img, date: data.name)));                        
                      },
                      ),
                      trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey
                      ),
                      child: Text("Add", style: const TextStyle(fontFamily: 'BrandonBI',
                          color: Colors.white,
                          fontSize: 15,
                        ),),
                      onPressed: () async{
                      try{
                      await FirebaseFirestore.instance.collection("Users").doc(data.email).collection(data.email + "request").doc(user!.email!).set({
                        'Requestname': Globalname,
                        'Requestabout': Globalabout,
                        'Requestimg': Globalimg,
                        'Requestemail': user!.email!,

                        'Username': data.name,
                        'Userabout': data.about,
                        'Userimg': data.img,
                        'Useremail': data.email,                        
                      });  
                                    Fluttertoast.showToast(  
                                    msg: 'Friend request sent!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white  
                                );                        
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white  
                                );      
                      }                                                                                      
                      }),
                      title: Text('${data.name}',style:  TextStyle(fontFamily: 'BrandonBI',
                          color: Theme.of(context).hintColor,
                          fontSize: 20,
                        ),),
                      subtitle:  Text('${data.about}',style:  TextStyle(fontFamily: 'BrandonBI',
                          color: Theme.of(context).hintColor,
                          fontSize: 15,
                        ),),
                    ),),

                  ],
                );
              }));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) {
            return Container(color: Theme.of(context).scaffoldBackgroundColor,
            child: 
            Center(
              child:  Text('No Results found..!', style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor),),
            ));
          }
        }
        return Container(color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
          child: CircularProgressIndicator(color: Theme.of(context).hintColor,)),
        );
      },
    );
  }
}

