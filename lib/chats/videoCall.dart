import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

// Creating Page
class VideoCall extends StatefulWidget {
  final username;
  VideoCall({Key? key,this.username}) : super(key: key);
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              "Video call",
              style: TextStyle(
                color: Colors.white60,fontFamily: 'BrandonBI',
                fontSize: 18,
              ),
            ),
            elevation: 5.0,
            centerTitle: true,
      ),
      body: Center(
        child:
        Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [

        SizedBox(height: 20,),

        //Flexible(child: 
        Container(
        width: 300,
        height: 300,
        child: Image.asset("assets/videoCall/vc1.png", width: 300, height: 300,)
        //)
        ),
        
        SizedBox(height: 20,),

        //Row(mainAxisAlignment: MainAxisAlignment.center,
        //children: [
        SizedBox(
        height: 64.0,
        width: double.maxFinite,
        child:
        ElevatedButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
        newMeet(username: widget.username,)));
        },
        style:  ElevatedButton.styleFrom(   
        primary: Colors.blueGrey
        ),
        child:Text(
              "START NEW MEET",
              style: TextStyle(
                color: Colors.white60,
                fontFamily: 'BrandonBI',
                fontSize: 20,
              ),
            ),)),

        SizedBox(height: 20,),

        SizedBox(
        height: 64.0,
        width: double.maxFinite,
        child:
        ElevatedButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
        existingMeet(username: widget.username,)));
        },
        style:  ElevatedButton.styleFrom(   
        primary: Colors.orange,
        ),
        child:Text(
              "JOIN A MEET",
              style: TextStyle(
                color: Colors.white60,
                fontFamily: 'BrandonBI',
                fontSize: 20,
              ),
            ),)),

        ])),
      );
  }
  
}
class newMeet extends StatefulWidget {
  final username;
  newMeet({Key? key,this.username}) : super(key: key);
  @override
  _newMeetState createState() => _newMeetState();
}

class _newMeetState extends State<newMeet> {
  final serverText = TextEditingController();
  final roomText = TextEditingController();
  final subjectText = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  //final emailText = TextEditingController(text: "Type down your email");
  // final iosAppBarRGBAColor =
  //     TextEditingController(text: "#0080FF80"); //transparent blue 
  bool isAudioOnly = true;
  bool isAudioMuted = true;
  bool isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              "Start new meet",
              style: TextStyle(
                color: Colors.white60,fontFamily: 'BrandonBI',
                fontSize: 18,
              ),
            ),
            elevation: 5.0,
            centerTitle: true,
      ), 
        body: Center(
        child:
        ListView(
        children: [

        SizedBox(height: 20,),

        //Flexible(child: 
        Container(
        width: 300,
        height: 300,
        child: Image.asset("assets/videoCall/vc3.png", width: 300, height: 300,)
        //)
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: kIsWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.30,
                      child: meetConfig(),
                    ),
                    Container(
                        width: width * 0.60,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              color: Colors.white54,
                              child: SizedBox(
                                width: width * 0.60 * 0.70,
                                height: width * 0.60 * 0.70,
                                child: JitsiMeetConferencing(
                                  extraJS: [
                                    // extraJs setup example
                                    '<script>function echo(){console.log("echo!!!")};</script>',
                                    '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                  ],
                                ),
                              )),
                        ))
                  ],
                )
              : meetConfig(),
        ),
      ]),
    )));
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          // TextField(
          //   controller: serverText,
          //   style: TextStyle(
          //   color: Theme.of(context).hintColor,
          //   fontSize: 16,
          //   fontFamily: 'BrandonLI'
          //   ),
          //   decoration: InputDecoration(
          //       labelStyle: TextStyle(
          //       color: Theme.of(context).hintColor,
          //       fontFamily: 'BrandonBI'
          //       ),
          //       hintStyle: TextStyle(
          //       color: Theme.of(context).hintColor,
          //       fontFamily: 'BrandonLI'
          //       ),
          //       border: OutlineInputBorder(),
          //       labelText: "Server URL",
          //       hintText: "Hint: Leave empty for meet.jitsi.si"),
          // ),
          SizedBox(
            height: 14.0,
          ),
              Container(
                width: 350,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: roomText,
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BrandonLI',
                    color: Colors.blueGrey
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(FontAwesomeIcons.peopleRoof, color: Colors.blueGrey),
                      hintText: "Type down room name..!",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'BrandonLI',
                        color: Colors.blueGrey
                      ),
                      ),
                ),
              ),

              // Container(
              //   width: 350,
              //   height: 60,
              //   decoration: BoxDecoration(
              //     color: Color(0xfff3f3f3),
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: TextField(
              //     controller: subjectText,
              //     maxLines: 1,
              //     keyboardType: TextInputType.name,
              //     textCapitalization: TextCapitalization.words,
              //     textAlignVertical: TextAlignVertical.center,
              //     textAlign: TextAlign.left,
              //     style: TextStyle(
              //       fontSize: 18,
              //       fontFamily: 'BrandonBI',
              //       color: Colors.blueGrey
              //     ),
              //     decoration: InputDecoration(
              //         border: InputBorder.none,
              //         contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
              //         errorBorder: InputBorder.none,
              //         enabledBorder: InputBorder.none,
              //         focusedBorder: InputBorder.none,
              //         disabledBorder: InputBorder.none,
              //         suffixIcon: Icon(FontAwesomeIcons.peopleRoof, color: Colors.blueGrey),
              //         hintText: "Name"),
              //   ),
              // ),

          SizedBox(
            height: 30.0,
          ),

          Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [

                  GestureDetector(
                    onTap: () {
                     _onAudioMutedChanged(!isAudioMuted);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isAudioMuted
                              ? Color(0xffD64467)
                              : Color(0xffffffff),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: Offset(0, 4)),
                          ]),
                      width: 72,
                      height: 72,
                      child: Icon(
                        isAudioMuted
                            ? FontAwesomeIcons.microphoneSlash
                            : FontAwesomeIcons.microphone,
                        color: isAudioMuted ? Colors.white : Colors.blueGrey,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20,),

                  GestureDetector(
                    onTap: () {
                      _onVideoMutedChanged(!isVideoMuted);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isVideoMuted
                              ? Color(0xffD64467)
                              : Color(0xffffffff),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: Offset(0, 4)),
                          ]),
                      width: 72,
                      height: 72,
                      child: Icon(
                        isVideoMuted
                            ? FontAwesomeIcons.videoSlash
                            : FontAwesomeIcons.video,
                        color: isVideoMuted ? Colors.white : Colors.blueGrey,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20,),

                  GestureDetector(

                    onTap: () {
                      _onAudioOnlyChanged(!isAudioOnly);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isAudioOnly
                              ? Color(0xffD64467)
                              : Color(0xffffffff),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: Offset(0, 4)),
                          ]),
                      width: 72,
                      height: 72,
                      child: Icon(
                        isAudioOnly
                            ? FontAwesomeIcons.phoneSlash
                            : FontAwesomeIcons.phone,
                        color: isAudioOnly ? Colors.white : Colors.blueGrey,
                      ),
                    ),
                  ),
          ],),

          Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          GestureDetector(
              onTap: () {
                if (roomText.text.trim().isEmpty) 
                {

                  Fluttertoast.showToast(  
                  msg: 'No room name..! Please enter a room name..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                } 
                // else if (subjectText.text.trim().isEmpty){

                //   Fluttertoast.showToast(  
                //   msg: 'No subject..! Please enter a subject..!',  
                //   toastLength: Toast.LENGTH_LONG,  
                //   gravity: ToastGravity.BOTTOM,  
                //   backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                //   textColor: Colors.white); 

                // }
                else if (roomText.text.trim().length < 3 ) 
                { 
                  
                  Fluttertoast.showToast(  
                  msg: 'Room name should contain atleast 3 character..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                } else {

                  _startMeeting();

                }
                
              },
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                            color: Color(0xffAA66CC),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.06),
                                  offset: Offset(0, 4)),
                            ]),
                        width: 174,
                        height: 72,
                        child: Center(
                          child: Text(
                            "START NEW MEET",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
                  ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _startMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: roomText.text)
      ..serverURL = serverUrl
      ..subject = subjectText.text
      ..userDisplayName = widget.username
      ..userEmail = user!.email!
      ..iosAppBarRGBAColor = '#00607D8B'
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": widget.username}
      };

    debugPrint("JitsiMeetingOptions: $options");
    try{
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
    } catch (e) {
      Fluttertoast.showToast(  
      msg: 'Error occured..!\nEither server url is incorrect, or any other issue..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 248, 17, 0),  
      textColor: Colors.white); 

      Future.delayed(const Duration(seconds: 3), () async{
      await Fluttertoast.showToast(  
      msg: 'Try again by leaving server url field as empty..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 248, 17, 0),  
      textColor: Colors.white); 
       });
    }
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {

    Fluttertoast.showToast(  
    msg: '$error',  
    toastLength: Toast.LENGTH_LONG,  
    gravity: ToastGravity.BOTTOM,  
    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
    textColor: Colors.white); 

    debugPrint("_onError broadcasted: $error");
    
  }
}

//existing meet....................................................................................................

class existingMeet extends StatefulWidget {
  final username;
  existingMeet({Key? key,this.username}) : super(key: key);
  @override
  _existingMeetState createState() => _existingMeetState();
}

class _existingMeetState extends State<existingMeet> {
  final serverText = TextEditingController();
  final roomText = TextEditingController();
  final subjectText = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  bool isAudioOnly = true;
  bool isAudioMuted = true;
  bool isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              "Join meet",
              style: TextStyle(
                color: Colors.white60,fontFamily: 'BrandonBI',
                fontSize: 18,
              ),
            ),
            elevation: 5.0,
            centerTitle: true,
      ), 
        body: Center(
        child:
        ListView(
        children: [

        SizedBox(height: 20,),

        //Flexible(child: 
        Container(
        width: 300,
        height: 300,
        child: Image.asset("assets/videoCall/vc2.png", width: 300, height: 300,)
        //)
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: kIsWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.30,
                      child: meetConfig(),
                    ),
                    Container(
                        width: width * 0.60,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              color: Colors.white54,
                              child: SizedBox(
                                width: width * 0.60 * 0.70,
                                height: width * 0.60 * 0.70,
                                child: JitsiMeetConferencing(
                                  extraJS: [
                                    // extraJs setup example
                                    '<script>function echo(){console.log("echo!!!")};</script>',
                                    '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                  ],
                                ),
                              )),
                        ))
                  ],
                )
              : meetConfig(),
        ),
      ]),
    )));
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
              Container(
                width: 350,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: serverText,
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BrandonLI',
                    color: Colors.blueGrey
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(FontAwesomeIcons.link, color: Colors.blueGrey),
                      hintText: "Paste meeting url..!",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'BrandonLI',
                        color: Colors.blueGrey
                      ),
                      ),
                ),
              ),

          SizedBox(
            height: 10.0,
          ),

              Container(
                width: 350,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: roomText,
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BrandonLI',
                    color: Colors.blueGrey
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(FontAwesomeIcons.peopleRoof, color: Colors.blueGrey),
                      hintText: "Type down room name..!",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'BrandonLI',
                        color: Colors.blueGrey
                      ),
                      ),
                ),
              ),

          SizedBox(
            height: 30.0,
          ),

          Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [

                  GestureDetector(
                    onTap: () {
                     _onAudioMutedChanged(!isAudioMuted);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isAudioMuted
                              ? Color(0xffD64467)
                              : Color(0xffffffff),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: Offset(0, 4)),
                          ]),
                      width: 72,
                      height: 72,
                      child: Icon(
                        isAudioMuted
                            ? FontAwesomeIcons.microphoneSlash
                            : FontAwesomeIcons.microphone,
                        color: isAudioMuted ? Colors.white : Colors.blueGrey,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20,),

                  GestureDetector(
                    onTap: () {
                      _onVideoMutedChanged(!isVideoMuted);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isVideoMuted
                              ? Color(0xffD64467)
                              : Color(0xffffffff),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: Offset(0, 4)),
                          ]),
                      width: 72,
                      height: 72,
                      child: Icon(
                        isVideoMuted
                            ? FontAwesomeIcons.videoSlash
                            : FontAwesomeIcons.video,
                        color: isVideoMuted ? Colors.white : Colors.blueGrey,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20,),

                  GestureDetector(

                    onTap: () {
                      _onAudioOnlyChanged(!isAudioOnly);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isAudioOnly
                              ? Color(0xffD64467)
                              : Color(0xffffffff),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.06),
                                offset: Offset(0, 4)),
                          ]),
                      width: 72,
                      height: 72,
                      child: Icon(
                        isAudioOnly
                            ? FontAwesomeIcons.phoneSlash
                            : FontAwesomeIcons.phone,
                        color: isAudioOnly ? Colors.white : Colors.blueGrey,
                      ),
                    ),
                  ),
          ],),

          Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          GestureDetector(
              onTap: () {
                if (serverText.text.trim().isEmpty && roomText.text.trim().isEmpty){

                  Fluttertoast.showToast(  
                  msg: 'Please make sure all fields are filled ..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                }
                else if (roomText.text.trim().isEmpty) 
                {

                  Fluttertoast.showToast(  
                  msg: 'No room name..! Please enter a room name..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                } 
                else if (serverText.text.trim().isEmpty){

                  Fluttertoast.showToast(  
                  msg: 'Server url is empty..! Please enter server url..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                }  
                else if (roomText.text.trim().length < 3 ) 
                { 
                  
                  Fluttertoast.showToast(  
                  msg: 'Room name should contain atleast 3 character..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                } else {

                  _joinMeeting();

                }
                
              },
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                            color: Color(0xffAA66CC),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.06),
                                  offset: Offset(0, 4)),
                            ]),
                        width: 174,
                        height: 72,
                        child: Center(
                          child: Text(
                            "JOIN MEET",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
                  ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: roomText.text)
      ..serverURL = serverUrl
      ..subject = subjectText.text
      ..userDisplayName = widget.username
      ..userEmail = user!.email!
      ..iosAppBarRGBAColor = '#00607D8B'
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": widget.username}
      };

    debugPrint("JitsiMeetingOptions: $options");
    try{
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
    } catch (e) {
      Fluttertoast.showToast(  
      msg: 'Error occured..!\nEither server url is incorrect, or any other issue..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 248, 17, 0),  
      textColor: Colors.white); 

      Future.delayed(const Duration(seconds: 3), () async{
      await Fluttertoast.showToast(  
      msg: 'Try again by leaving server url field as empty..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 248, 17, 0),  
      textColor: Colors.white); 
       });
    }
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {

    Fluttertoast.showToast(  
    msg: '$error',  
    toastLength: Toast.LENGTH_LONG,  
    gravity: ToastGravity.BOTTOM,  
    backgroundColor: Color.fromARGB(255, 248, 17, 0),  
    textColor: Colors.white); 

    debugPrint("_onError broadcasted: $error");
    
  }
}