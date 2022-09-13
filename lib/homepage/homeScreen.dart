import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_search/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:macsapp/chats/chat.dart';
import 'package:macsapp/login/services/googlesignin.dart';
import 'package:macsapp/main.dart';
import 'package:macsapp/profile.dart';
import 'package:macsapp/request/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homeScreen extends StatefulWidget {

  @override
  homeScreenState createState() => homeScreenState();
}

class homeScreenState extends State<homeScreen>{
  User? user = FirebaseAuth.instance.currentUser;
  final collectionReference = FirebaseFirestore.instance;

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
            color: Colors.white60,fontFamily: 'BrandonBIBI',
            fontSize: 18,
          ),
        ),
        elevation: 5.0,
        centerTitle: true,
  ),
  backgroundColor: Colors.white,
	body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection(user!.email! + "friends")
          .snapshots(),
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
                        try{
                        await FirebaseFirestore.instance.collection(snapshot.data.docs[index]['id']).where('id', isEqualTo: user!.email!)
                        .get().then((snapshot) {
                          snapshot.docs.forEach((documentSnapshot) async {
                            //There must be a field in document snapshot that represents this doc Id
                            String thisDocId = documentSnapshot['docId'];
                          
                          FirebaseFirestore.instance.collection("chats").doc(thisDocId).delete();
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
                        _removefriend(snapshot.data.docs[index].id);
                      },
                      onTap: () async{
                        await collectionReference.collection("Users").doc(snapshot.data.docs[index]['email']).get()
                        .then((snapshot) {
                          setState(() {
                          Globalname = snapshot.get('name');                
                          });
                        });

                        Globalmail = snapshot.data.docs[index]['email'];
                        Globalid = snapshot.data.docs[index]['id'];

                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => 
                        chat(id: snapshot.data.docs[index]['id'],)));
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
                      builder: (context)=> PhotoView(url: snapshot.data['img'], date: snapshot.data['name']))),
                      child:  

                      ClipRRect(
                      borderRadius: BorderRadius.circular(100),child: 
                      Image.network('https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e',
                       width: 50, height: 50, fit: BoxFit.fill,))),

                      );                      
                    } else {   
                    return 
                    ListTile(
                      title: Text(snapshot.data['name'],style: const TextStyle(fontFamily: 'BrandonLI',
                          color: Colors.blueGrey,
                          fontSize: 20,
                        ),),
                      subtitle: Text(snapshot.data['about'],style: const TextStyle(fontFamily: 'BrandonLI',
                          color: Colors.blueGrey,
                          fontSize: 15,
                        ),),  
                      // trailing: IconButton(
                      // icon: Icon(Icons.delete_sweep, color: Colors.blueGrey, size: 30,),
                      // onPressed: () {
                      //   // _removefriend(snapshot.data.docs[index].id);
                      // }
                      // ),                      
                      leading: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> PhotoView(url: snapshot.data['img'], date: snapshot.data['name']))),
                      child:  

                      ClipRRect(
                      borderRadius: BorderRadius.circular(100),child: 
                      Image.network(snapshot.data['img'], width: 50, height: 50, fit: BoxFit.fill,))),

                      );
                  }}),
                    ));
              }),
              
              ]);       
          }})

  );
  }

//remove friend......................................................................................................
   _removefriend (String docid)  async{ 
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color.fromARGB(223, 255, 254, 254),
          title: const Text("Do you want to remove this friend?", textAlign: TextAlign.center,
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
            child: const Text('Remove',style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey)),  
            onPressed: () async { 
            await FirebaseFirestore.instance.collection(user!.email! + "friends").doc(docid).delete();
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
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            
            onTap: () async{
              
               Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => UpdateProfile()));},
          ),
          StreamBuilder(
                stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {   
                  return ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Requests'),
                    
                    onTap: () async{},
                  );
                  }

                else{
                  return ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Requests'),                   
                    onTap: () async{
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => 
                    Requests(name: snapshot.data['name'], about: snapshot.data['about'],
                    img: snapshot.data['img'],)));
              },
              );
            }}),          
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('About'),
            onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => homeScreen()))},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
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
          backgroundColor: const Color.fromARGB(223, 255, 254, 254),
          title: const Text("Do you want to logout?", textAlign: TextAlign.center,
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
            child: const Text('Logout',style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey)),  
            onPressed: () async { 

            FirebaseService service = new FirebaseService();
            await service.signOutFromGoogle();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('validation', false);         
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
        backgroundColor: Colors.white,
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
            color: Colors.grey,fontFamily: 'BrandonBIBI',
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

        else{
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
                      title: Text(snapshot.data.docs[index]['name'],style: const TextStyle(fontFamily: 'BrandonLI',
                          color: Colors.blueGrey,
                          fontSize: 20,
                        ),),
                      subtitle: Text(snapshot.data.docs[index]['about'],style: const TextStyle(fontFamily: 'BrandonLI',
                          color: Colors.blueGrey,
                          fontSize: 15,
                        ),),
                      leading: ClipRRect(
                      borderRadius: BorderRadius.circular(100),child: 
                      Image.network(snapshot.data.docs[index]['img'], width: 50, height: 50, fit: BoxFit.fill,),),
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
                      await FirebaseFirestore.instance.collection(snapshot.data.docs[index]['email'] + "request").doc(user!.email!).set({
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
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white  
                                );      
                      }                                                                                      
                      }),
            ));
              })]);           
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
      appBarTitle: "Search",
      firestoreCollectionName: "Users",
      searchBy: 'name',
      scaffoldBody: Center(
        child: Text("Search for product", style: TextStyle(color: Colors.grey),),
      ),

      dataListFromSnapshot: DataModel(docid: '', email: '', img: '', about: '', name: '').dataListFromSnapshot,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DataModel> dataList = snapshot.data;
          if (dataList.isEmpty) {
            return const Center(
              child: Text('No Results Returned'),
            );
          }
          return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final DataModel data = dataList[index];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(elevation: 15,
                    child: ListTile(
                      leading:
                      ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child:
                       Image.network(
                        '${data.img}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.fill,
                      )),
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
                      await FirebaseFirestore.instance.collection(data.email + "request").doc(user!.email!).set({
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
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white  
                                );      
                      }                                                                                      
                      }),
                      title: Text('${data.name}',style: const TextStyle(fontFamily: 'BrandonBI',
                          color: Colors.blueGrey,
                          fontSize: 20,
                        ),),
                      subtitle:  Text('${data.about}',style: const TextStyle(fontFamily: 'BrandonBI',
                          color: Colors.blueGrey,
                          fontSize: 15,
                        ),),
                    ),),

                  ],
                );
              });
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Results found'),
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}