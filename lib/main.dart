import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  _MyAppState createState() => _MyAppState();
/// InheritedWidget style accessor to our State object.
/// We can call this static method from any descendant context to find our
/// State object and switch the themeMode field value & call for a rebuild.
static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

/// Our State object
class _MyAppState extends State<MyApp> {
  /// 1) our themeMode "state" field
  ThemeMode _themeMode = ThemeMode.system;
  
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 1), () async{
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    prefs.getBool('isDark') == true ? changeTheme(ThemeMode.dark) : changeTheme(ThemeMode.light);  
    setState(() {
    isDark = prefs.getBool('isDark');
    });
    });
  } 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode, // 2) ← ← ← use "state" field here //////////////
      home: Splash(),
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



class ThemeClass{
 
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(),
    
    cardColor: Colors.grey.shade200,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey,
    )
  );
 
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black45,
    cardColor: Colors.black,
    colorScheme: ColorScheme.dark(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
      )
  );
}


