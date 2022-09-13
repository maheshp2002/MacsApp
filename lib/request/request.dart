import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
            color: Colors.white60,fontFamily: 'BrandonBIBI',
            fontSize: 18,
          ),
        ),
        elevation: 5.0,
        centerTitle: true,
  ), 
  body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection(user!.email! + "request")
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

                    return  Card(elevation: 15,
                    child:
                    ListTile(
                      title: Text(snapshot.data.docs[index]['Requestname'],style: const TextStyle(fontFamily: 'BrandonLI',
                          color: Colors.blueGrey,
                          fontSize: 15,
                        ),),
                      subtitle: Text(snapshot.data.docs[index]['Requestabout'],style: const TextStyle(fontFamily: 'BrandonLI',
                          color: Colors.blueGrey,
                          fontSize: 15,
                        ),),
                      leading: Image.network(snapshot.data.docs[index]['Requestimg'], width: 50, height: 50,),
                      trailing: Expanded(child: 
                      SizedBox(width: 150, child:
                      Row(children: [                     
                      ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey
                      ),
                      child: Icon(Icons.check, color: Colors.white,),
                      onPressed: () async{
                      
                      try{
                      await FirebaseFirestore.instance.collection(snapshot.data.docs[index]['Requestemail'] + "friends").doc(user!.email!).set({
                        'name': widget.name,
                        'about': widget.about,
                        'img': widget.img,
                        'email': user!.email!,
                        'id': user!.email! + snapshot.data.docs[index]['Requestemail']
                      });

                      await FirebaseFirestore.instance.collection(user!.email! + "friends").doc(snapshot.data.docs[index]['Requestemail']).set({
                        'name': snapshot.data.docs[index]['Requestname'],
                        'about': snapshot.data.docs[index]['Requestabout'],
                        'img': snapshot.data.docs[index]['Requestimg'],
                        'email': snapshot.data.docs[index]['Requestemail'],   
                        'id': user!.email! + snapshot.data.docs[index]['Requestemail']                     
                      });  

                      FirebaseFirestore.instance.collection(user!.email! + "request")
                      .doc(snapshot.data.docs[index]['Requestemail']).delete();
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
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
                      }),

                      SizedBox(width: 10,),

                      ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white
                      ),
                      child: Icon(Icons.close, color: Colors.blueGrey,),
                      onPressed: () async{
                      
                      try{
                      FirebaseFirestore.instance.collection(user!.email! + "request")
                      .doc(snapshot.data.docs[index]['Requestemail']).delete();
                      } catch(e){
                                    Fluttertoast.showToast(  
                                    msg: 'An error occured..!',  
                                    toastLength: Toast.LENGTH_LONG,  
                                    gravity: ToastGravity.BOTTOM,  
                                    backgroundColor: Colors.blueGrey,  
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
                      })                      
                      ],),
            )),),);
              })]);           
        }
      })    
    );

}
}
