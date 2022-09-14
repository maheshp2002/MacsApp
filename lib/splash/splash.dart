import 'package:flutter/material.dart';
import 'package:macsapp/main.dart';


class Splash extends StatefulWidget {

  _SplashState createState() => _SplashState();
}

  class _SplashState extends State<Splash>{
  @override
  void initState(){
  super.initState();
  _navigatetoHome();
  }

  _navigatetoHome()async{
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp2()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //color: Colors.blueGrey.shade900,
        color: Colors.white,
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

        children: [
           Container(

        child: //Icon(Icons.radio, size: 250, color: Colors.white,),
        Image.asset('assets/logo.png', width:150,height:150),
        ),
           const Padding(
             padding: EdgeInsets.only(top: 1),
           child: Text('MacsApp',
               textAlign: TextAlign.center,
               overflow: TextOverflow.ellipsis,
               style: TextStyle(
               fontFamily: "BrandonBIBI",
               fontSize: 35,
               color: Colors.blueGrey,
             ),)
           ),
      ],
        ),
      ),
      ),
      bottomSheet: Container(color: Colors.white,
        child: 

      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: const [ 
        Text("from - Broken Code\n ", textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontFamily: 'BrandonL'))]),

        ),
    );
}


}