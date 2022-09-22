import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:macsapp/chats/chat.dart';

class Requests extends StatefulWidget {

  final name;
  final about; 
  final img; 
  Requests({Key? key,this.name,this.about,this.img}) : super(key: key);

  @override
  RequestsState createState() => RequestsState();
}

class RequestsState extends State<Requests>{
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
        icon: Icon(
                Icons.arrow_back,
                color: Colors.white24, // Change Custom Drawer Icon Color
              ),
        onPressed: () => Navigator.of(context).pop(),
        ),
        title:  Text(
          "Friend Request",
          style: TextStyle(
            color: Colors.white60,fontFamily: 'BrandonBI',
            fontSize: 18,
          ),
        ),
        elevation: 5.0,
        centerTitle: true,
  ), 
  body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!)
      .collection(user!.email! + "request")
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

        else  if (snapshot.hasData) {
           return ListView(
           children: [
          
            ListView.builder(
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,        
                  itemBuilder: (BuildContext context, int index) {

                    return  Card(elevation: 15,
                    child:
                    ListTile(
                      title: Text(snapshot.data.docs[index]['Requestname'],style:  TextStyle(fontFamily: 'BrandonLI',
                          color: Theme.of(context).hintColor,
                          fontSize: 15,
                        ),),
                      subtitle: Text(snapshot.data.docs[index]['Requestabout'],style:  TextStyle(fontFamily: 'BrandonLI',
                          color: Theme.of(context).hintColor,
                          fontSize: 15,
                        ),),
                      leading:  InkWell(
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),child: 
                      Image.network(snapshot.data.docs[index]['Requestimg'], width: 50, height: 50,)),
                      
                      onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> photoView(url: snapshot.data.docs[index]['Requestimg'], date: snapshot.data.docs[index]['Requestname'])));                        
                      },
                      ),
                      trailing:  
                      SizedBox(width: 150, child:
                      Row(children: [  
                      Expanded(child:                   
                      ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey
                      ),
                      child: Icon(Icons.check, color: Colors.white,),
                      onPressed: () async{
                      
                      try{
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!).collection("friends")
                      .doc(snapshot.data.docs[index]['Requestemail']).set({
                        'name': widget.name,
                        'about': widget.about,
                        'img': widget.img,
                        'email': user!.email!,
                        'id': snapshot.data.docs[index]['Requestemail']
                      });

                      await FirebaseFirestore.instance.collection("Users").doc(snapshot.data.docs[index]['Requestemail']).collection("friends")
                      .doc(user!.email!).set({
                        'name': snapshot.data.docs[index]['Requestname'],
                        'about': snapshot.data.docs[index]['Requestabout'],
                        'img': snapshot.data.docs[index]['Requestimg'],
                        'email': snapshot.data.docs[index]['Requestemail'],   
                        'id': user!.email!                   
                      });  

                      FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection(user!.email! + "request")
                      .doc(snapshot.data.docs[index]['Requestemail']).delete();
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white  
                                );                        
                      }
                                    Fluttertoast.showToast(  
                                    msg: 'Friend added..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white  
                                );                       
                      })),

                      SizedBox(width: 10,),

                      Expanded(child:
                      ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white
                      ),
                      child: Icon(Icons.close, color: Colors.blueGrey,),
                      onPressed: () async{
                      
                      try{
                      FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection(user!.email! + "request")
                      .doc(snapshot.data.docs[index]['Requestemail']).delete();
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                                    textColor: Colors.white  
                                );                        
                      }
                                    Fluttertoast.showToast(  
                                    msg: 'Friend request rejected..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
                                    textColor: Colors.white  
                                );                       
                      }))                      
                      ],),
            )),);
              })]);           
        } else{   
        return Center(child: 
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          //Image.asset("assets/nothing.gif"),
          Text("Noting is here!", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 20, fontFamily: 'BrandonLI') )
          ],));
        }

      })    
    );

}
}
