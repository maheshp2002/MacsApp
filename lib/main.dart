import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:macsapp/login/login.dart';
import 'package:macsapp/splash/splash.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(RestartWidget(
  child:  MyApp()));
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Splash(),
    );
  }
}

class MyApp2 extends StatefulWidget {

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp2>{
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFd2c4b5),
      body:  Container(
        decoration: const BoxDecoration(
              gradient: LinearGradient(
               colors: [Color(0xFFd2c4b5),Color(0xFFd2c4b5),Color(0xFFdbcab5), Color(0xFFd7c6b4)],
              begin: Alignment.topLeft,
               end: Alignment.bottomRight,
          )),
      child:
      Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Image.asset("assets/login/login3.gif"),

      SizedBox(height: 10,),
      
      Text("Please login..!", style: TextStyle(fontSize: 25, fontFamily: 'BrandonBI', color: Colors.grey),),

      SizedBox(height: 10,),

      Center(child: 
      GoogleSignIn(),),

      ],)
      ),
      
    );
  }

}


//restart app......................................................................................................
class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    final State<RestartWidget>? state = context.findAncestorStateOfType<State<RestartWidget>>();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}


