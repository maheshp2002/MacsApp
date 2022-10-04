import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:macsapp/homepage/homeScreen.dart';
import 'package:macsapp/login/login.dart';
import 'package:macsapp/splash/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(RestartWidget(
  child:  MyApp()));
}


class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
/// InheritedWidget style accessor to our State object.
/// We can call this static method from any descendant context to find our
/// State object and switch the themeMode field value & call for a rebuild.
static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}
  late var user;
/// Our State object
class MyAppState extends State<MyApp> {
  /// 1) our themeMode "state" field
  ThemeMode _themeMode = ThemeMode.system;
  final FirebaseAuth auth = FirebaseAuth.instance;
  
 @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1), () async{
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    prefs.getBool('isDark') == true ? changeTheme(ThemeMode.dark) : changeTheme(ThemeMode.light);  
    setState(() {
    isDark = prefs.getBool('isDark');
    });
    });
    getCurrentUser();
  } 
    Future getCurrentUser() async {
    setState(() {
        
    user =  FirebaseAuth.instance.currentUser ?? "notSigned";
    });

    return user;}

HideOnline () async{
                          try{
                            await FirebaseFirestore.instance.collection("Users").doc(user!.email!).get()
                            .then((snapshot) {
                                      showOnline = snapshot.get('showOnline');
                                      Globalname = snapshot.get('name');
                                    });
                        }catch(e){
                          Fluttertoast.showToast(  
                          msg: 'error occured..!',  
                          toastLength: Toast.LENGTH_LONG,  
                          gravity: ToastGravity.BOTTOM,  
                          backgroundColor: Colors.blueGrey,  
                          textColor: Colors.white  
                          );                            
                        }   

}
   
    
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MacsApp',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode, // 2) ← ← ← use "state" field here //////////////
      home: 
      Splash(),
    );
  }

  /// 3) Call this to change theme from any context using "of" accessor
  /// e.g.:
  /// MyApp.of(context).changeTheme(ThemeMode.dark);
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

}

class MyApp2 extends StatefulWidget {

  @override
  MyApp2State createState() => MyApp2State();
}

class MyApp2State extends State<MyApp2>{
  
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


//Theme........................................................................................................
class ThemeClass{
 
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: Colors.blueGrey,
    hintColor: Colors.blueGrey,
    colorScheme: ColorScheme.light(),
    cardColor: Colors.grey.shade200,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey,
    )
  );
 
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black45,
    primarySwatch: Colors.blueGrey,
    cardColor: Colors.black,
    hintColor: Colors.white60,
    colorScheme: ColorScheme.dark(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
      )
  );
}


